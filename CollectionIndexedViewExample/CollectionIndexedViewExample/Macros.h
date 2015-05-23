#import "float.h"

#ifndef Macros_h
#define Macros_h

#ifndef RGBA
	#define RGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:(a)/255.f]
#endif

#ifndef RGB
	#define RGB(r, g, b) [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f  alpha:1.0]
#endif

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_IOS6 ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
#define IS_RETINA (([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && [[UIScreen mainScreen] scale] == 2.0 ? YES : NO))
#define SCREEN_SCALE [UIScreen mainScreen].scale

#define IS_IPHONE_DEVICE ([[UIDevice currentDevice].model rangeOfString:@"iPhone"].location != NSNotFound)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4 [UIScreen mainScreen].bounds.size.height <= 480
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#endif
