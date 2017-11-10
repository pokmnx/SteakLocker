//
//  UserObject
//
//

#import "ParseRlmObject.h"


@interface Object : ParseRlmObject

@property NSString *type;
@property NSString *title;
@property BOOL active;
@property NSString * imageUrl;


@property int defaultDays;
@property NSString *servingSize;
@property NSString *calories;
@property NSString *caloriesFromFat;
@property NSString *totalFat;
@property NSString *saturatedFat;
@property NSString *transFat;
@property NSString *cholesterol;
@property NSString *sodium;
@property NSString *carbohydrates;
@property NSString *dietaryFiber;
@property NSString *sugars;
@property NSString *protein;
@property NSString *vitaminA;
@property NSString *vitaminC;
@property NSString *calcium;
@property NSString *iron;
@property NSString *information;

@property float expectedLoss;
@property float suggestedServingSize;


+ (RLMResults *)getAll;
- (NSString*)getAgingType;
- (BOOL) isAgingType: (NSString*)agingType;

@end

