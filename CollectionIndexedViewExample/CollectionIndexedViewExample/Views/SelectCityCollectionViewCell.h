//
//  SelectDepartCityCell.h
//  CollectionIndexedViewExample
//
//  Created by Anton Yurichev on 4/10/14.
//  All rights reserved.
//

#import <UIKit/UIKit.h>
#import "City.h"

#define kSelectDepartCityReuseID @"SelectDepartCityCellReuseID"

@interface SelectCityCollectionViewCell : UICollectionViewCell

@property (assign, nonatomic, setter = setSeparator:) BOOL hasSeparator;
@property (retain, nonatomic) City *departCity;

@end
