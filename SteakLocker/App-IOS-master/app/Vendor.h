//
//  Vendor
//
//

#import "ParseRlmObject.h"


@interface Vendor : ParseRlmObject


@property NSString *title;
@property BOOL active;
@property NSString * website;

@property NSString * address;
@property NSString * city;
@property NSString * state;
@property NSString * zip;
@property BOOL isPro;

+ (RLMResults *)getAll;
+ (RLMResults *)getAllNonPro;
+ (RLMResults *)getAllPro;

@end

