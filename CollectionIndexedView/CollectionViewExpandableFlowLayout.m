//
//  CollectionViewExpandableFlowLayout.m
//  ExampleCollectionViewExpandableCollapsableHeaders
//
//  Created by Anton Yurichev on 4/7/14.
//  All rights reserved.
//

#import "CollectionViewExpandableFlowLayout.h"

@implementation CollectionViewExpandableFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *layoutAttributesInRect = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    UICollectionView * const cv = self.collectionView;
    CGPoint const contentOffset = cv.contentOffset;
	
	// Get indexes of visible sections
	NSMutableIndexSet *existsSections = [NSMutableIndexSet indexSet];
	[layoutAttributesInRect enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *layoutAttributes, NSUInteger idx, BOOL *stop) {
		 if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader])
			 [existsSections addIndex:layoutAttributes.indexPath.section];
	}];
	
	// Find minimum visible sections index
	NSUInteger __block minIndex = cv.numberOfSections;
	[existsSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		if (idx < minIndex)
			minIndex = idx;
	}];
	
	// Added layout attributes for sections that are not "visible"
	// (they does not exist in layout attributes array that we've got from superclass)
	for (int i = 0; i < minIndex; i++)
	{
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:i];
		
        UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
		if (layoutAttributes)
			[layoutAttributesInRect insertObject:layoutAttributes atIndex:i];
	}
	
	// Enumerate all header views attributes
	CGFloat pinnedHeaderHeights = 0;
	for (UICollectionViewLayoutAttributes *layoutAttributes in layoutAttributesInRect) {
		
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader] && layoutAttributes.indexPath.section > 0)
		{
            NSInteger section = layoutAttributes.indexPath.section;
            NSIndexPath *firstElementIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
			//NSLog(@"index path for layout attributes: section: %ld item: %ld", (long)firstElementIndexPath.section, (long)firstElementIndexPath.item);
			
			BOOL firstCellExist = [cv numberOfItemsInSection:section] > 0;
			
			UICollectionViewLayoutAttributes *firstElementAttrs = firstCellExist ? [self layoutAttributesForItemAtIndexPath:firstElementIndexPath] : [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:layoutAttributes.indexPath];
			
			CGFloat headerHeight = CGRectGetHeight(layoutAttributes.frame);
			CGPoint origin = layoutAttributes.frame.origin;
			
			//NSLog(@"header heights: %.2f", headerHeights);
			// Check what's bigger: "pinned" Y-position or position on top of first cell in section
			// Warning: this code will work for header views with equal heights only
			
			CGFloat pinnedY = contentOffset.y + pinnedHeaderHeights;//(section - 1) * headerHeight;
			CGFloat floatY = CGRectGetMinY(firstElementAttrs.frame) - headerHeight;
			if (pinnedY > floatY)
			{
				origin.y = pinnedY;
				pinnedHeaderHeights += headerHeight;
			}
			else
				origin.y = floatY;
			
			//NSLog(@"section: %ld, y : %.2f, content offset: %.2f", (long)section, origin.y, contentOffset.y);
			layoutAttributes.zIndex = section;
			layoutAttributes.frame = (CGRect){
				.origin = origin,
				.size = layoutAttributes.frame.size
			};
			//NSLog(@"section: %ld, layout %@, zIndex: %ld, alpha: %.2f", (long)section, NSStringFromCGRect(layoutAttributes.frame),(long)layoutAttributes.zIndex, layoutAttributes.alpha);
		}
    }
	self.pinnedHeaderHeights = pinnedHeaderHeights;
    return layoutAttributesInRect;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBound
{
    return YES;
}

@end
