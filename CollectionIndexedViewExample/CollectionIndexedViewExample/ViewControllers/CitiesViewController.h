//
//  SelectDepartCityViewControllerNew.h
 //
//
//  Created by Anton Yurichev on 05/22/2015.
//  Copyright (c) 2014 Anton Yurichev. All rights reserved
//

#import <UIKit/UIKit.h>
#import "CollectionIndexedView.h"

#define kSelectDepartCitySectionHeight 23.0f

@interface CitiesViewController : UIViewController <CollectionIndexedViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>


- (IBAction)btnLostFocus_Click:(UIButton *)sender;

@end
