//
//  DepartCity.h
 //
//
//  Created by Class Generator by Anton Yurichev on 26.02.2014.
//  All rights reserved.
//

#import <Foundation/Foundation.h>

@interface City : NSObject <NSCoding, NSCopying>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) BOOL isPopular;

- (id)initWithName:(NSString *)name
         isPopular:(BOOL)isPopular;

+ (instancetype)getFromDictionary: (NSDictionary *)jsonDictionary;
+ (NSArray *)getFromDataArray: (NSArray *)jsonData;

@end