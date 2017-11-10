//
//  UserObject
//
//

#import "ParseRlmObject.h"
#import "Object.h"

@interface UserObject : ParseRlmObject


@property NSString *userObjectId;
@property NSString *deviceObjectId;
@property NSString *objectObjectId;
@property NSString *vendorObjectId;
@property NSString *customVendor;

@property long days;
@property float cost;
@property float weight;
@property float weightEnd;
@property NSString *nickname;
@property NSString *quality;
@property NSDate *startedAt;
@property NSDate *finishedAt;
@property NSDate *removedAt;
@property BOOL active;

@property NSString *weightType;
@property NSString *currency;

@property float servingSize;
@property float servingPrice;
@property float expectedLoss;

- (float)getActualLoss;

- (void)initFinishedAt;
- (NSDate*)backfillStartDate;

- (void)syncToRemote: (PFObjectResultBlock)block;
+ (RLMResults *) getAll;
+ (RLMResults *) getAllForDeviceId: (NSString*)deviceId;
+ (RLMResults *) getUnremovedForDeviceId:(NSString *)deviceId;
+ (RLMResults *) getRemovedForDeviceId:(NSString *)deviceId;
+ (RLMResults *) getItemsAfterDate:(NSDate*)date object:(NSString * _Nullable)objectId device:(NSString * _Nullable)deviceId;
+ (RLMResults *) getItemsAfterDateNoLimit:(NSString * _Nullable) objectId device:(NSString * _Nullable)deviceId;
+ (BOOL) existsForObject:(NSString*)objectObjectId device:(NSString *)deviceId;

- (long)getTotalDays;
- (int)getCurrentDay;
- (int)getDaysLeft;
- (NSString * _Nonnull)getDaysLeftString;
- (int) getDaysAged;
- (NSDate*)getStartDate;
- (BOOL)isInLocker;

- (float)getWeight;
- (float)getCost;
- (float)getCostTotal;
- (float)getCostNet;
- (float)getExpectedLossPercent;
- (float)getExpectedLossWeight;
- (float)getServingSalePrice;
- (float)getExpectedServings;
- (float)getServingCost;
- (float)getServingNetCost;
- (float)getServingSize;


- (Object *)object;

@end

