//
//  SelectDepartCityViewControllerNew.m
 //
//
//  Created by Anton Yurichev on 4/10/14.
//  All rights reserved.
//

#import "CitiesViewController.h"
#import "SelectCityCollectionViewCell.h"
#import "SearchBarReusableView.h"
#import "SelectSectionHeaderReusableView.h"

static const CGFloat kSelectDepartCityViewControllerCellHeight = 44.0f;
static const CGFloat kSearchBarHeight = 44.0f;

@interface CitiesViewController ()

@property (retain, nonatomic) NSArray *sectionNames;
@property (retain, nonatomic) NSArray *cities;
@property (retain, nonatomic) NSArray *filteredCities;
@property (retain, nonatomic) NSArray *popularCities;

@property (retain, nonatomic) NSArray *indexLetters;
@property (retain, nonatomic) NSArray *indexesOfCitiesForLetters;
@property (assign, nonatomic) NSInteger staticSectionsNumber;
@property (assign, nonatomic) NSInteger numberOfSections;

@property (retain, nonatomic) IBOutlet CollectionIndexedView *cvCities;
@property (retain, nonatomic) IBOutlet UIButton *btnLostFocus;
@property (retain, nonatomic) IBOutlet UISearchBar *searchDepartCities;

@end

@implementation CitiesViewController

#pragma mark - Lifecycle
- (id)init
{
	self = [super init];
	if (self)
	{
		[self loadLocalization];
		
		// Index of last section. Section = section names count + 1 for empty section with search bar
		_staticSectionsNumber = self.sectionNames.count;
	}
	return self;
}

- (void)dealloc
{
	[_cvCities release];
	[_searchDepartCities release];
	[_btnLostFocus release];
	
	[_sectionNames release];
	[_cities release];
	[_filteredCities release];
	[_popularCities release];
	
	[_indexLetters release];
	[_indexesOfCitiesForLetters release];
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self loadLocalization];
     self.automaticallyAdjustsScrollViewInsets = NO;
	self.btnLostFocus.enabled = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
	// Setting up UI for index
	// Register nib for cell, header and search bar
	[self.cvCities registerNib:[UINib nibWithNibName:NSStringFromClass([SelectCityCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:kSelectDepartCityReuseID];
	[self.cvCities registerNib:[UINib nibWithNibName:NSStringFromClass([SelectSectionHeaderReusableView class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSelectSectionHeaderReuseID];
	[self.cvCities registerNib:[UINib nibWithNibName:NSStringFromClass([SearchBarReusableView class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSearchBarViewReuseID];
	
	// Set index parameters
	self.cvCities.sectionIndexColor = RGB(129.0f, 129.0f, 129.0f);
	self.cvCities.sectionIndexBackgroundColor = [UIColor clearColor];
	self.cvCities.sectionIndexInsets =  IS_IPHONE_5 ? UIEdgeInsetsMake(71, 0, 40, 0) : UIEdgeInsetsMake(45, 0, 20, 0);
	self.cvCities.sectionIndexWidth = 30.0f;
	self.cvCities.sectionIndexFont = [UIFont fontWithName:@"GillSans" size:12.0f];
	self.cvCities.isAnimateIndexScrolling = YES;
    
    NSString *jsonCitiesFilePath = [[NSBundle mainBundle] pathForResource:@"cities" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonCitiesFilePath];
    
    __block typeof(self) _self = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *jsonParsingError = nil;
        NSDictionary *parsedJson = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonParsingError];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (jsonParsingError)
            {
                NSLog(@"error parsing json: %@", jsonParsingError);
            }
            else if (![parsedJson isKindOfClass:[NSDictionary class]])
            {
                NSLog(@"error: parsed data from file: %@ is not NSDictionary!", jsonCitiesFilePath);
            }
            else
            {
                NSArray *jsonCities = parsedJson[@"data"];
                
                if (!jsonCities || ![jsonCities isKindOfClass:[NSArray class]])
                {
                    NSLog(@"error: parsed dictionary does not contain NSArray by key 'data'");;
                }
                else
                {
                    _self.cities = [City getFromDataArray:(NSArray *)jsonCities];
                    [_self applyFilterWithSearchString:nil];
                }
                
            }
        });
    });

}

#pragma mark - UI utilities
- (void)loadLocalization
{
	self.title = @"ВЫБЕРИТЕ ГОРОД";
	self.sectionNames = @[@"ПОПУЛЯРНЫЕ ГОРОДА", @"ВСЕ ГОРОДА"];
}

#pragma mark - Functionality
- (NSArray *)selectPopularCities:(NSArray *)allCities
{
	// Add popular cities to different array
	NSIndexSet *popularCitiesIndexes = [allCities indexesOfObjectsPassingTest:^BOOL(City *departCity, NSUInteger idx, BOOL *stop) {
		return departCity.isPopular;
	}];
	NSArray *popularCities = [allCities objectsAtIndexes:popularCitiesIndexes];
	return popularCities;
}

- (void)applyFilterWithSearchString:(NSString *)searchString;
{
	// Seacrh in cities names and rebuild all data sources and index
	if (searchString.length > 0)
	{
		NSIndexSet *filteredIndexes = [self.cities indexesOfObjectsPassingTest:^BOOL(City *departCity, NSUInteger idx, BOOL *stop) {
			NSRange searchRange = [departCity.name rangeOfString:searchString options:NSCaseInsensitiveSearch];
			return (searchRange.location != NSNotFound);
		}];
		
		// Sort all cities by name, but popular cities must be ordered exactly how they come from JSON
		NSArray *filteredCities = [self.cities objectsAtIndexes:filteredIndexes];
		self.filteredCities = [filteredCities sortedArrayUsingComparator:^NSComparisonResult(City *departCity1, City *departCity2) {
			return [departCity1.name compare:departCity2.name options:NSCaseInsensitiveSearch | NSLiteralSearch];
		}];
		self.popularCities = filteredCities;
	}
	else
	{
		// If no search string, filtetered cities is all cities but sorted in alphabetical order
		self.filteredCities = [self.cities sortedArrayUsingComparator:^NSComparisonResult(City *city1, City *city2) {
			return [city1.name compare:city2.name options:NSCaseInsensitiveSearch | NSLiteralSearch];
		}];
		self.popularCities = [self selectPopularCities:self.cities];
	}
    [self buildIndexArrayWithSource:self.filteredCities];
	[self.cvCities reloadData];
}


#pragma mark --- Build index
- (void)buildIndexArrayWithSource:(NSArray *)sourceArray
{
	// Create a set of first letters (for index) and dictionary which contains number of depart cities with name that begins from this letter
	NSMutableDictionary *lettersCounts = [NSMutableDictionary dictionary];
	
	for (City *departCity in sourceArray)
	{
		// Get first letter of depart city name and add it to dictionary with count;
		NSString *firstLetter = [[departCity.name substringWithRange:NSMakeRange(0, 1)] uppercaseString];
		if (firstLetter)
		{
			// Increment count of letter on 1. If dictionary has not that letter, letterCount will be 0
			NSInteger letterCount = [lettersCounts[firstLetter] integerValue];
			letterCount++;
			lettersCounts[firstLetter] = @(letterCount);
		}
	};
	
	// Sort array in alphabetical order
	NSMutableArray *firstLettersArray = [NSMutableArray arrayWithArray:[lettersCounts allKeys]];
	[firstLettersArray sortUsingComparator:^NSComparisonResult(NSString *string1, NSString *string2) {
		return [string1 compare:string2 options:NSLiteralSearch | NSCaseInsensitiveSearch];
	}];
	
	// Add the last index letter for moving to the end of countries list
	[firstLettersArray insertObject:kCollectionIndexedViewDefaultSearchIconConst atIndex:0];
	[firstLettersArray addObject:@"#"];
	self.indexLetters = [NSArray arrayWithArray:firstLettersArray];
	
	// Build an array with index numbers. Every number means just an index in source array.
	// From this index we start counting countries in source array (for our letter table section).
	// Last index equals a source array count
	NSMutableArray *indexesForRows = [NSMutableArray array];
	NSInteger indexForRow = 0;
	[indexesForRows addObject:@(indexForRow)];
	
	// Start from 2 for excluding "search" section and first section (index for first section always 0)
	for (int i = 2; i < firstLettersArray.count; i++)
	{
		NSInteger count = [lettersCounts[firstLettersArray[i - 1]] integerValue];
		indexForRow = (i < firstLettersArray.count - 1) ? indexForRow + count : sourceArray.count;
		[indexesForRows addObject:@(indexForRow)];
	}
	self.indexesOfCitiesForLetters = [NSArray arrayWithArray:indexesForRows];
}


#pragma mark - CollectionIndexedViewDataSource, UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	// + 1 is for search bar section
	NSInteger numberOfSections = self.staticSectionsNumber + 1;
	if (self.indexLetters.count == 0)
		return 0;
	self.numberOfSections = numberOfSections;
	return numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	// Search bar is in section 0, and it's obviously have 0 rows. Section 1 has one row with nearest location
	NSInteger numberOfRows = 0;
	if (section == 1)
		numberOfRows = self.popularCities.count;
	if (section == 2)
		numberOfRows = self.filteredCities.count;
	return numberOfRows;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	SelectCityCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSelectDepartCityReuseID forIndexPath:indexPath];
	
	// Pass city to cell
	City *departCity = nil;
	if (indexPath.section == 1)
		departCity = self.popularCities[indexPath.row];
	if (indexPath.section == 2)
		departCity = self.filteredCities[indexPath.row];
    
	// Hide separator for last cell in section (excluding last cell in last section)
	if ((indexPath.row == ([collectionView numberOfItemsInSection:indexPath.section] - 1)) &&
		(indexPath.section < (self.numberOfSections - 1)))
		cell.hasSeparator = NO;
	else
		cell.hasSeparator = YES;
	
	cell.departCity = departCity;
	return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    NSInteger section = indexPath.section;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        if (section == 0)
        {
            // Return header with search bar
            SearchBarReusableView *searchBarView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kSearchBarViewReuseID forIndexPath:indexPath];
            reusableView = searchBarView;
        }
        else
        {
            SelectSectionHeaderReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kSelectSectionHeaderReuseID forIndexPath:indexPath];
            if (section > self.staticSectionsNumber || (section < self.staticSectionsNumber && [collectionView numberOfItemsInSection:section] == 0) || (section == self.staticSectionsNumber && self.filteredCities.count == 0))
            {
                headerView.hidden = YES;
            }
            else
            {
                UIColor *headerBackgroundColor = nil;
                switch (section)
                {
                    case 1:
                        headerBackgroundColor = [UIColor blueColor];
                        break;
                    case 2:
                        headerBackgroundColor = [UIColor blackColor];
                        break;
                    default:
                        headerBackgroundColor = nil;
                        break;
                }
                headerView.hidden = NO;
                __block typeof(self) _self = self;
                [headerView applyTitle:self.sectionNames[section - 1] backgroundColor:headerBackgroundColor tapBlock:^{
                    [_self.cvCities scrollToSectionHeaderAtIndexPath:indexPath animated:YES];
                }];
            }
            reusableView = headerView;
        }
    }
    return reusableView;
}

#pragma mark --- Layout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
	// For searchbar
	if (section == 0)
	{
		return CGSizeMake(collectionView.frame.size.width, 44.0f);
	}
	if (section > self.staticSectionsNumber)
	{
		return CGSizeZero;
	}
	else
	{
		// If section has empty data source array, we hide it. Otherwise, return needed value
		if (section == 1 && self.popularCities.count == 0)
			return CGSizeZero;
		if (section == 2 && self.filteredCities.count == 0)
			return CGSizeZero;
		return CGSizeMake(collectionView.frame.size.width, kSelectDepartCitySectionHeight);
	}
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return CGSizeMake(self.cvCities.frame.size.width, kSelectDepartCityViewControllerCellHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	SelectCityCollectionViewCell *selectedDepartCityCell = (SelectCityCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	City *city = selectedDepartCityCell.departCity;
    NSLog(@"selected city: %@", city);
}

#pragma mark --- Index search
- (NSArray *)sectionIndexTitlesForCollectonView:(UICollectionView *)collectionView
{
	return self.indexLetters;
}

- (NSIndexPath *)collectionView:(UICollectionView *)collectionView indexPathForItemAtIndex:(NSInteger)index title:(NSString *)title
{
	// We need to sсroll to 0 section if index == 0, because it's search bar
	if (index == 0)
		return [NSIndexPath indexPathForItem:0 inSection:0];
	
	// Else return index path for first city row with name that starts from given index letter
	NSInteger row = 0;
	if (index == (self.indexLetters.count - 1))
		row = [collectionView numberOfItemsInSection: self.staticSectionsNumber] - 1;
	else
		row = [self.indexesOfCitiesForLetters[index - 1] integerValue];
	NSIndexPath *indexPathForItem = [NSIndexPath indexPathForItem:row inSection:self.staticSectionsNumber];
	return indexPathForItem;
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	[self applyFilterWithSearchString:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[self.view endEditing:NO];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	self.btnLostFocus.enabled = YES;
	[self.view bringSubviewToFront:self.btnLostFocus];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	// Needed hack. Because if we add searchBar like a supplementary view to UICollectionView, it cause errors with update
	// calling reloadData cause keyboard disappearance, calling reloadSections cause internal error in UICollectionView
	// http://stackoverflow.com/questions/14540291/how-to-reload-only-data-section-of-uicollectionview
    CGFloat y = scrollView.contentOffset.y;
	CGSize searchBarSize = self.searchDepartCities.frame.size;
	
    if (y < kSearchBarHeight)
	{
        self.searchDepartCities.frame = CGRectMake(0, -y, searchBarSize.width, searchBarSize.height);
        self.searchDepartCities.hidden = NO;
    }
	else
	{
        self.searchDepartCities.hidden = YES;
    }
}

#pragma mark - Handlers
- (IBAction)btnLostFocus_Click:(UIButton *)sender
{
	sender.enabled = NO;
	[self.view endEditing:YES];
}

@end
