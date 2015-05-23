//
//  SelectSectionHeaderReusableView.h
//  CollectionIndexedViewExample
//
//  Created by Anton Yurichev on 4/9/14.
//  All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSelectSectionHeaderReuseID @"SelectSectionHeaderReuseID"

typedef void (^HeaderViewTapBlock)(void);

@interface SelectSectionHeaderReusableView : UICollectionReusableView

- (void)applyTitle:(NSString *)title backgroundColor:(UIColor *)backgroundColor tapBlock:(HeaderViewTapBlock)tapBlock;

@end
