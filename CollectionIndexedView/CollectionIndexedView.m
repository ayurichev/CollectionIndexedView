//
//  CollectionIndexedView.m
//  ExampleCollectionViewExpandableCollapsableHeaders
//
//  Created by Anton Yurichev on 4/8/14.
//  All rights reserved.
//

#import "CollectionIndexedView.h"
#import "CollectionViewExpandableFlowLayout.h"

#define kMaxTitlesCount (IS_IPHONE_5 ? 25 : 20)

@interface CollectionIndexedView ()

@property (retain, nonatomic) NSArray *indexTitles;
@property (retain, nonatomic) UIView *indexView;
@property (assign, nonatomic) NSInteger currentIndex;
@property (retain, nonatomic) UITapGestureRecognizer *indexTapRecognizer;
@property (retain, nonatomic) UIPanGestureRecognizer *indexPanRecognizer;
@property (nonatomic) BOOL isNotFirstLoad;

@end

@implementation CollectionIndexedView

@dynamic dataSource;

#pragma  mark - Lifecycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.indexView = [self buildIndexView];
    }
    return self;
}

- (void)dealloc
{
	self.delegate = nil;
	[_sectionIndexColor release];
	[_sectionIndexBackgroundColor release];
	[_sectionIndexFont release];
	[_indexTitles release];
	[_indexView release];
	[_indexTapRecognizer release];
	[_sectionIndexSearchImage release];
	[_indexPanRecognizer release];
	[super dealloc];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	// Reload indexes in this method just for first time because we need right frames/bounds values
	if (!self.isNotFirstLoad)
	{
		[self reloadIndexes];
		self.isNotFirstLoad = YES;
	}
}

#pragma mark - Overloaded UICollectionView methods
- (void)reloadData
{
	[super reloadData];
	if (self.isNotFirstLoad)
	{
		[self reloadIndexes];
	}
}

- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL))completion
{
	// Update indexed view after performing batch updates
	[super performBatchUpdates:updates completion:completion];
	if (self.isNotFirstLoad)
	{
		[self reloadIndexes];
	}
}

#pragma  mark - UI functionality
- (void)reloadIndexes
{
	// Forced reload indexes
	[self.indexView removeFromSuperview];
	if ([self.dataSource respondsToSelector:@selector(sectionIndexTitlesForCollectonView:)])
		self.indexTitles = [self.dataSource sectionIndexTitlesForCollectonView:self];
	self.indexView = [self buildIndexView];
	[self.superview addSubview:self.indexView];
}

- (UIView *)buildIndexView
{
	// Bild new indexView
	CGRect indexViewFrame = CGRectMake(CGRectGetWidth(self.frame) - self.sectionIndexInsets.right - self.sectionIndexWidth,
									   self.frame.origin.y + self.sectionIndexInsets.top,
									   self.sectionIndexWidth,
									   self.frame.size.height - self.sectionIndexInsets.top - self.sectionIndexInsets.bottom);
    
	UIView *indexView = [[[UIView alloc] initWithFrame:indexViewFrame] autorelease];
	
	// Add labels with index titles
	NSArray *newIndices = [self newIndexTitles:self.indexTitles];
	
	for (int i = 0; i < newIndices.count; i++)
	{
		UIView *tiledIndexView = nil;
		
		CGFloat indexLabelHeight = indexViewFrame.size.height / newIndices.count;
		CGRect indexLabelFrame = CGRectMake(self.sectionIndexWidth - kCollectionIndexedViewDefaultSectionTileWidth, 0, kCollectionIndexedViewDefaultSectionTileWidth, indexLabelHeight);
		if (i == 0 && [newIndices[0] isEqualToString:kCollectionIndexedViewDefaultSearchIconConst])
		{
			UIImageView *indexSearchImage = [[[UIImageView alloc] initWithFrame:indexLabelFrame] autorelease];
			indexSearchImage.contentMode = UIViewContentModeCenter;
			indexSearchImage.image = [UIImage imageNamed:self.sectionIndexSearchImage];
			tiledIndexView = indexSearchImage;
		}
		else
		{
			UILabel *indexLabel = [[[UILabel alloc] initWithFrame:indexLabelFrame] autorelease];
			indexLabel.textColor = self.sectionIndexColor ?: [UIColor grayColor];
			indexLabel.textAlignment = NSTextAlignmentCenter;
			indexLabel.font = self.sectionIndexFont;
			indexLabel.backgroundColor = [UIColor clearColor];

			NSString *labelText = newIndices[i];
			if ([labelText isKindOfClass:[NSString class]])
				indexLabel.text = labelText;
			else
			{
				NSLog(@"index title is not NSString! It's %@", NSStringFromClass(labelText.class));
			}
			tiledIndexView = indexLabel;
		}
		UIView *wrapView = [[[UIView alloc] initWithFrame:CGRectMake(0, i * indexLabelHeight, self.sectionIndexWidth, indexLabelHeight)] autorelease];
		wrapView.backgroundColor = [UIColor clearColor];
		[wrapView addSubview:tiledIndexView];
		NSInteger oldIndex = [self.indexTitles indexOfObject:newIndices[i]];
		wrapView.tag = oldIndex;
		
		//[indexView addSubview:tiledIndexView];
		[indexView addSubview:wrapView];
	}
	
	// Set other visual parameters & add tap and pan gesture recognizers
	indexView.backgroundColor = self.sectionIndexBackgroundColor;
	if (!self.indexTapRecognizer)
	{
		self.indexTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleIndexTap:)] autorelease];
		self.indexTapRecognizer.delegate = self;
	}
	if (!self.indexPanRecognizer)
	{
		self.indexPanRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleIndexPan:)] autorelease];
		self.indexTapRecognizer.delegate = self;
	}
	[indexView addGestureRecognizer:self.indexTapRecognizer];
	[indexView addGestureRecognizer:self.indexPanRecognizer];

	return indexView;
}

- (void)scrollToSectionHeaderAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
	CGRect cellFrame = CGRectMake(0, 0, 0, 0);
	if (indexPath.section > 0)
		cellFrame = [self layoutAttributesForItemAtIndexPath:indexPath].frame;
	// Calculate right scroll point
	CGFloat headerHeights = [self layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath].frame.size.height * (indexPath.section);
	CGFloat contentInsetY = self.contentInset.top;
	CGFloat sectionInsetY = ((UICollectionViewFlowLayout *)self.collectionViewLayout).sectionInset.top;
	
	CGPoint scrolledContentOffset = CGPointMake(self.contentOffset.x, cellFrame.origin.y + contentInsetY - sectionInsetY - headerHeights);
	//NSLog(@"scrolled content offset: %@", NSStringFromCGPoint(scrolledContentOffset));
	[self setContentOffset:scrolledContentOffset animated:animated];
}

- (NSArray *)newIndexTitles: (NSArray *)indexTitles
{
	if (indexTitles.count <= kMaxTitlesCount)
		return indexTitles;
	
	double ratio = 2.2f;
	NSMutableArray *indicesLeft = [[[NSMutableArray alloc] init] autorelease];
	NSMutableArray *newIndexTitles = [[[NSMutableArray alloc] init] autorelease];
	
	do
	{
		[indicesLeft removeAllObjects];
		[newIndexTitles removeAllObjects];
		
		ratio += 0.1;
		NSInteger currentIndex = 0;
		NSInteger i = 0;
		while (currentIndex < indexTitles.count - 2)
		{
			currentIndex = round(i * ratio + 2);
			[indicesLeft addObject:@(currentIndex)];
			++i;
		}
		
		//Build new index
		for (NSInteger i = 0; i < indexTitles.count; ++i)
		{
			NSString *dotString = @"\U00002022"; //@"•";//[NSString stringWithFormat:@"%c", 7];
			
			if (i == 0 || i == 1 || i == indexTitles.count - 1 || i == indexTitles.count - 2)
				[newIndexTitles addObject:indexTitles[i]];
			else if ([indicesLeft containsObject:@(i)])
				[newIndexTitles addObject:indexTitles[i]];
			else if (![[newIndexTitles lastObject] isEqualToString:dotString])
				[newIndexTitles addObject:dotString];
		}
		
		//NSLog(@"ratio = %f", ratio);
		//NSLog(@"Indices initial: %@", indexTitles);
		//NSLog(@"Indices new: %@", newIndexTitles);
	}
	while (newIndexTitles.count > kMaxTitlesCount);
	
    return newIndexTitles;
}

- (void)newIndexForPoint:(CGPoint)point
{
    for (UIView *subview in self.indexView.subviews)
	{
        if (CGRectContainsPoint(subview.frame, point))
		{
			NSUInteger newIndex = subview.tag;
			if (newIndex != NSNotFound && newIndex != self.currentIndex)
				self.currentIndex = newIndex;
		}
	}
}

#pragma  mark - Custom accessors
- (void)setCurrentIndex:(NSInteger)currentIndex
{
	_currentIndex = currentIndex;
	if ([self.dataSource respondsToSelector:@selector(collectionView:indexPathForItemAtIndex:title:)])
	{
		NSIndexPath *indexPathForScroll = [self.dataSource collectionView:self indexPathForItemAtIndex:_currentIndex title:self.indexTitles[_currentIndex]];
		if (indexPathForScroll)
		{
			CGRect scrollElementFrame;
			if ([self numberOfItemsInSection:indexPathForScroll.section] > 0)
				scrollElementFrame = [self layoutAttributesForItemAtIndexPath:indexPathForScroll].frame;
			else
				scrollElementFrame = [self layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPathForScroll].frame;
			
			// Get cell frame and calculate offset correction for show cell just below pinned headers
			//CGFloat pinnedHeadersHeights1 = ((CollectionViewExpandableFlowLayout *)self.collectionViewLayout).pinnedHeaderHeights;
			
			CGFloat pinnedHeadersHeights = 0.0f;
			for (int i = 1; i <= indexPathForScroll.section; i++)
			{
				UICollectionViewLayoutAttributes *attrs = [self  layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
				pinnedHeadersHeights += attrs.frame.size.height;
			}
			
			CGFloat contentInsetY = self.contentInset.top;
			CGFloat sectionInsetY = ((UICollectionViewFlowLayout *)self.collectionViewLayout).sectionInset.top;
			CGPoint scrolledContentOffset = CGPointMake(self.contentOffset.x, scrollElementFrame.origin.y + contentInsetY - sectionInsetY - pinnedHeadersHeights);
			
			// Use scrollRectToVisible because
			[self scrollRectToVisible:CGRectMake(0, scrolledContentOffset.y, self.frame.size.width, self.frame.size.height) animated:self.isAnimateIndexScrolling];
			//[self setContentOffset:scrolledContentOffset animated:self.isAnimateIndexScrolling];
		}
	}
}

- (CGFloat)sectionIndexWidth
{
	if (_sectionIndexWidth == 0)
		_sectionIndexWidth = kCollectionIndexedViewDefaultSectionIndexWidth;
	return _sectionIndexWidth;
}

- (UIFont *)sectionIndexFont
{
	if (!_sectionIndexFont)
		_sectionIndexFont = [UIFont systemFontOfSize:kCollectionIndexedViewDefaultSectionIndexFontSize];
	return _sectionIndexFont;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	/*if ([gestureRecognizer isEqual:self.panRecognizer] && [otherGestureRecognizer isEqual:self.tapRecognizer])
	 return NO;
	 if ([gestureRecognizer isEqual:self.tapRecognizer] && [otherGestureRecognizer isEqual:self.panRecognizer])
	 return NO;*/
	return YES;
}
#pragma  mark - Handlers
- (void)handleIndexTap:(UITapGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateEnded)
	{
		[self newIndexForPoint:[recognizer locationInView:self.indexView]];
	}
}

- (void)handleIndexPan:(UIPanGestureRecognizer *)panRecognizer
{
	//CGPoint translationPoint = [panRecognizer translationInView:self.indexView];
	CGPoint locationPoint = [panRecognizer locationInView:self.indexView];
	//NSLog(@"translation point: %@, location point: %@", NSStringFromCGPoint(translationPoint), NSStringFromCGPoint(locationPoint));
	
	// set X to 0 because we want to recognizer will not cancel and keep working if we move finger outside of index view
	locationPoint.x = 0.0f;
	[self newIndexForPoint:locationPoint];
	//[self logRecognizerState:panRecognizer];
}

/*- (void)logRecognizerState:(UIGestureRecognizer *)rec
{
	switch (rec.state)
	{
		case UIGestureRecognizerStateBegan:
			NSLog(@"recognizer began");
			break;
		case UIGestureRecognizerStateChanged:
			NSLog(@"recognizer changed");
			break;
		case UIGestureRecognizerStatePossible:
			NSLog(@"gesture recognizer possible");
			break;
		case UIGestureRecognizerStateCancelled:
			NSLog(@"recognizer cancelled");
			break;
		case UIGestureRecognizerStateEnded:
			NSLog(@"recognizer ended");
			break;
		case UIGestureRecognizerStateFailed:
			NSLog(@"recognizer failed");
			break;
		default:
			break;
	}
}*/
@end
