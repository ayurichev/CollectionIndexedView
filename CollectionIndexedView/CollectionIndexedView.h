//
//  CollectionIndexedView.h
//  ExampleCollectionViewExpandableCollapsableHeaders
//
//  Created by Anton Yurichev on 4/8/14.
//  All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCollectionIndexedViewDefaultSectionIndexFontSize 9.0f
#define kCollectionIndexedViewDefaultSearchIconConst @"_search"
#define kCollectionIndexedViewDefaultSectionTileWidth 15.0f
#define kCollectionIndexedViewDefaultSectionIndexWidth 30.0f

@protocol CollectionIndexedViewDataSource <UICollectionViewDataSource>

@optional
- (NSArray *)sectionIndexTitlesForCollectonView:(UICollectionView *)collectionView;
- (NSInteger)collectionView:(UICollectionView *)collectionView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;
- (NSIndexPath *)collectionView:(UICollectionView *)collectionView indexPathForItemAtIndex:(NSInteger)index title:(NSString *)title;

@end

@interface CollectionIndexedView : UICollectionView <UIGestureRecognizerDelegate>

@property (assign, nonatomic) id<CollectionIndexedViewDataSource> dataSource;
@property (assign, nonatomic) CGFloat sectionIndexWidth;
@property (assign, nonatomic) UIEdgeInsets sectionIndexInsets;
@property (assign, nonatomic) BOOL isAnimateIndexScrolling;
@property (retain, nonatomic) UIColor *sectionIndexColor;
@property (retain, nonatomic) UIColor *sectionIndexBackgroundColor;
@property (retain, nonatomic) UIFont *sectionIndexFont;
@property (retain, nonatomic) NSString *sectionIndexSearchImage;

- (void)scrollToSectionHeaderAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)reloadIndexes;

@end
