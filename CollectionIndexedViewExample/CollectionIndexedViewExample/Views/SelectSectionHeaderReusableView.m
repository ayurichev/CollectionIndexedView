//
//  SelectSectionHeaderReusableView.m
//  CollectionIndexedViewExample
//
//  Created by Anton Yurichev on 4/9/14.
//  All rights reserved.
//

#import "SelectSectionHeaderReusableView.h"
@interface SelectSectionHeaderReusableView ()

@property (copy, nonatomic) HeaderViewTapBlock tapBlock;
@property (retain, nonatomic) IBOutlet UIButton *btnSectionTap;
@property (retain, nonatomic) IBOutlet UILabel *lblSectionHeaderTitle;

@end

@implementation SelectSectionHeaderReusableView

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
	self.tapBlock = nil;
	[_btnSectionTap release];
	[_lblSectionHeaderTitle release];
	[super dealloc];
}

- (void)applyTitle:(NSString *)title backgroundColor:(UIColor *)backgroundColor tapBlock:(HeaderViewTapBlock)tapBlock
{
	self.tapBlock = tapBlock;
    self.btnSectionTap.backgroundColor = backgroundColor;
	self.lblSectionHeaderTitle.text = title;
}

- (IBAction)btnHeader_Click:(UIButton *)sender
{
	if (self.tapBlock)
		self.tapBlock();
}

@end
