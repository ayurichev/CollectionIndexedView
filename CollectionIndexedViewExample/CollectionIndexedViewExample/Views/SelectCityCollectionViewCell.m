//
//  SelectDepartCityCell.m
//  CollectionIndexedViewExample
//
//  Created by Anton Yurichev on 4/10/14.
//  All rights reserved.
//

#import "SelectCityCollectionViewCell.h"

@interface SelectCityCollectionViewCell ()

@property (retain, nonatomic) IBOutlet UIView *viewSeparator;
@property (retain, nonatomic) IBOutlet UILabel *lblDepartCityName;

@end

@implementation SelectCityCollectionViewCell

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
	[_viewSeparator release];
	[_lblDepartCityName release];
	[super dealloc];
}

#pragma mark - Custom accessors
- (void)setSeparator:(BOOL)hasSeparator
{
    _hasSeparator = hasSeparator;
    if (_hasSeparator)
        self.viewSeparator.hidden = NO;
    else
        self.viewSeparator.hidden = YES;
}

- (void)setDepartCity:(City *)departCity
{
	if (_departCity)
	{
		[_departCity release];
		_departCity = nil;
	}
	_departCity = [departCity retain];
	self.lblDepartCityName.text = _departCity.name;
}


@end
