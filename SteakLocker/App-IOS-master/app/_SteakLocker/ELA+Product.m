// ELA+Product.h
#import "ELA+Product.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@implementation ELA (Product)


+ (UIColor*)getColorAccent
{
    return [UIColor colorWithRed:255.0f/255.0f green:114.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    
}

+ (UIColor *)getColorTemp
{
    return [UIColor colorWithRed:255.0f/255.0f green:114.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}

+ (UIColor *)getColorHumid
{
    return [UIColor colorWithRed:0.0f/255.0f green:192.0/255.0f blue:255.0f/255.0f alpha:1.0f];
}

+ (NSString * _Nonnull)getDeviceWifiName
{
    return @"🐮 Steak Locker";
}

+ (NSString * _Nonnull)getLockerType
{
    return @"steaklocker";
}
@end
