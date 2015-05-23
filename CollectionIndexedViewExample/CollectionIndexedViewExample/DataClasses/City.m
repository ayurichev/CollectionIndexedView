//
//  DepartCity.m
 //
//
//  Created by Class Generator by Anton Yurichev on 26.02.2014.
//  All rights reserved.
//

#import "City.h"

@implementation City

#pragma mark - Lifecycle
- (id)init
{
	return [self initWithName:nil isPopular:NO];
}

- (id)initWithName:(NSString *)name
			 isPopular:(BOOL)isPopular

{
	if ((self = [super init]))
	{
		self.name = name;
		self.isPopular = isPopular;
	}	
	return self;
}

- (void)dealloc
{
	[_name release];
	[super dealloc];
}

#pragma mark - Overriding
- (BOOL)isEqual:(id)object
{
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:self.class])
        return NO;
    City *anotherDepartCity = (City *)object;
    if ([self.name isEqualToString:anotherDepartCity.name])
        return YES;
    return NO;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Name: %@, IsPopular: %@",
            _name,
            _isPopular ? @"YES" : @"NO"
            ];
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone
{
	City *copy = [[[self class] allocWithZone:zone] init];
	if (copy)
	{
        copy.name = [[self.name copyWithZone:zone] autorelease];
		copy.isPopular = self.isPopular;
	}
	return copy;
}

#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self)
	{
		self.name = [aDecoder decodeObjectForKey:@"name"];
		self.isPopular = [aDecoder decodeBoolForKey:@"isPopular"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
	[aCoder encodeObject:self.name forKey:@"name"];
	[aCoder encodeBool:self.isPopular forKey:@"isPopular"];
}

#pragma mark - Static methods
+ (instancetype)getFromDictionary:(NSDictionary *)jsonData
{
	if(![jsonData isKindOfClass:[NSDictionary class]])
        return nil;
    
    City *item = [[City alloc] initWithName:jsonData[@"name"] isPopular:[jsonData[@"isPopular"] boolValue]];
	return [item autorelease];
}

+ (NSArray *)getFromDataArray:(NSArray *)jsonData
{
	NSMutableArray *items = [[NSMutableArray alloc] init];
	for (NSDictionary *jsonDataItem in jsonData)
	{
		NSObject *item = [self getFromDictionary:jsonDataItem];
		if (item)
			[items addObject:item];
	}	
    return [NSArray arrayWithArray:items];
}

@end