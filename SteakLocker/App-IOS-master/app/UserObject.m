
#import "UserObject.h"
#import "Sync.h"
#import "ELA.h"
#import <Parse/Parse.h>

@implementation UserObject

+ (NSString*) getType
{
    return @"UserObject";
}

+ (NSArray *)indexedProperties {
    return @[@"uuid", @"objectId", @"objectObjectId", @"deviceObjectId"];
}

+ (NSTimeInterval) getSyncWindow
{
    double hours = 0.001;
    return (3600 * hours);
}


+ (instancetype) getOrSync: (PFObject*)object
{
    NSString *uuid = [object objectForKey:@"uuid"];
    if (uuid == nil) {
        uuid = object.objectId;
    }
    return [self getOrSync:uuid object:object];
}

+ (instancetype) createFromPFObject: (PFObject*) object
{
    if (![object isDataAvailable]) {
        [object fetchIfNeeded];
    }
    
    UserObject *me = [[self alloc] initFromPFObject:object];
    
    return [me syncFromPFObject:object];
}


- (void)initFinishedAt
{
    NSDate *now = (self.startedAt != nil) ? self.startedAt : [NSDate date];
    
    // set up date components
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay: self.days];
    
    // create a calendar
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    self.finishedAt = [gregorian dateByAddingComponents:components toDate:now options:0];
}

- (NSDate *)backfillStartDate
{
    NSDate *date = self.finishedAt;
    
    // set up date components
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay: -self.days];
    
    // create a calendar
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [gregorian dateByAddingComponents:components toDate:date options:0];
}


- (instancetype) syncFromPFObject:(PFObject *)object
{
    [super syncFromPFObject:object];
    
    RLMRealm *realm = [ParseRlmObject startSave];
    
    PFObject *pfObj;
    
    
    id val = [object objectForKey:@"nickname"];
    self.nickname = (val == Nil || val == [NSNull null]) ? Nil : val;
    val = [object objectForKey:@"quality"];
    self.quality = (val == Nil || val == [NSNull null]) ? Nil : val;
    
    NSNumber *value = [object objectForKey:@"active"];
    self.active = [value boolValue];
    
    value = [object objectForKey:@"days"];
    self.days = [value intValue];
    value = [object objectForKey:@"cost"];
    self.cost = [value floatValue];
    value = [object objectForKey:@"weight"];
    self.weight = [value floatValue];
    value = [object objectForKey:@"weightEnd"];
    self.weightEnd = [value floatValue];
    self.weightType = [object objectForKey:@"weightType"];
    self.currency = [object objectForKey:@"currency"];
    
    value = [object objectForKey:@"servingSize"];
    self.servingSize = [value floatValue];
    value = [object objectForKey:@"servingPrice"];
    self.servingPrice = [value floatValue];
    value = [object objectForKey:@"expectedLoss"];
    self.expectedLoss = [value floatValue];
    
    
    pfObj = [object objectForKey:@"user"];
    self.userObjectId = (pfObj != nil && pfObj != [NSNull null]) ? pfObj.objectId : nil;
    
    pfObj = [object objectForKey:@"device"];
    self.deviceObjectId = (pfObj != nil && pfObj != [NSNull null]) ? pfObj.objectId : nil;
    
    pfObj = [object objectForKey:@"object"];
    self.objectObjectId = (pfObj != nil && pfObj != [NSNull null]) ? pfObj.objectId : nil;
    
    pfObj = [object objectForKey:@"vendor"];
    self.vendorObjectId = (pfObj != nil && pfObj != [NSNull null]) ? pfObj.objectId : nil;
    self.customVendor = [object objectForKey:@"customVendor"];
    

    val = [object objectForKey:@"startedAt"];
    self.startedAt = (val == Nil || val == [NSNull null]) ? Nil : val;
    val = [object objectForKey:@"finishedAt"];
    self.finishedAt = (val == Nil || val == [NSNull null]) ? Nil : val;
    val = [object objectForKey:@"removedAt"];
    self.removedAt  = (val == Nil || val == [NSNull null]) ? Nil : val;
    
    [realm addOrUpdateObject: self];
    [ParseRlmObject commitSave:realm];
    
    return self;
}


+ (RLMResults *) getAll
{
    PFUser *user = [PFUser currentUser];
    return [[UserObject objectsWhere  : @"active = YES AND userObjectId = %@", user.objectId] sortedResultsUsingKeyPath:@"finishedAt" ascending:YES];
}

+ (RLMResults *) getAllForDeviceId:(NSString *)deviceId
{
    PFUser *user = [PFUser currentUser];
    return [[UserObject objectsWhere  : @"active = YES AND userObjectId = %@ AND deviceObjectId = %@", user.objectId, deviceId] sortedResultsUsingKeyPath:@"finishedAt" ascending:YES];
}

+ (RLMResults *) getUnremovedForDeviceId:(NSString *)deviceId
{
    PFUser *user = [PFUser currentUser];
    return [[UserObject objectsWhere  : @"active = YES AND removedAt == nil AND userObjectId = %@ AND deviceObjectId = %@", user.objectId, deviceId] sortedResultsUsingKeyPath:@"finishedAt" ascending:YES];
}

+ (RLMResults *) getRemovedForDeviceId:(NSString *)deviceId
{
    PFUser *user = [PFUser currentUser];
    return [[UserObject objectsWhere  : @"active = YES AND removedAt != nil AND userObjectId = %@ AND deviceObjectId = %@", user.objectId, deviceId] sortedResultsUsingKeyPath:@"finishedAt" ascending:YES];
}



+ (RLMResults *) getItemsAfterDate:(NSDate*)date object:(NSString * _Nullable)objectId device:(NSString * _Nullable)deviceId
{
    NSDate *now = [NSDate date];
    
    RLMResults *results = [UserObject objectsWhere : @"active = YES AND (finishedAt BETWEEN {%@,%@} OR removedAt BETWEEN {%@,%@})", date, now, date, now];
    
    if (objectId != nil) {
        results = [results objectsWhere:@"objectObjectId = %@", objectId];
    }
    if (deviceId != nil) {
        results = [results objectsWhere:@"deviceObjectId = %@", deviceId];
    }
    
    return [results sortedResultsUsingKeyPath:@"finishedAt" ascending:YES];
}

+ (RLMResults *) getItemsAfterDateNoLimit:(NSString * _Nullable)objectId device:(NSString * _Nullable)deviceId
{
    RLMResults *results = [UserObject objectsWhere : @"active = YES"];
    
    if (objectId != nil) {
        results = [results objectsWhere:@"objectObjectId = %@", objectId];
    }
    if (deviceId != nil) {
        results = [results objectsWhere:@"deviceObjectId = %@", deviceId];
    }
    
    return [results sortedResultsUsingKeyPath:@"finishedAt" ascending:YES];
}


+ (BOOL) existsForObject:(NSString*)objectId device:(NSString *)deviceId
{
    RLMResults *results;
    if (objectId==nil) {
        results = [UserObject objectsWhere  : @"objectObjectId = nil AND deviceObjectId = %@", deviceId];
    }
    else {
        results = [UserObject objectsWhere  : @"objectObjectId = %@ AND deviceObjectId = %@", objectId, deviceId];
    }
    
    return results.count > 0;
}


+ (BOOL)modifyUpdatesQuery:(PFQuery *)query
{
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
    return YES;
}

+ (void) checkSync
{
    NSDate *updatedAt     = Nil;
    NSString *type        = [self getType];
    NSTimeInterval window = [self getSyncWindow];
    if (type != Nil && window > 0) {
        updatedAt = [Sync shouldUpdate: type window:window];
        if (updatedAt != Nil) {
            [self getUpdates:type date:updatedAt];
        }
    }
}



- (void)syncToRemote: (PFObjectResultBlock)block
{
    PFObject *obj;
    BOOL isMetric = [ELA isMetric];
    PFObject *device = (self.deviceObjectId != nil) ? [PFObject objectWithoutDataWithClassName:@"Device" objectId:self.deviceObjectId] : nil;
    PFObject *object = (self.objectObjectId != nil) ? [PFObject objectWithoutDataWithClassName:@"Object" objectId:self.objectObjectId] : nil;
    PFObject *vendor = (self.vendorObjectId != nil) ? [PFObject objectWithoutDataWithClassName:@"Vendor" objectId:self.vendorObjectId] : nil;
    PFUser *user = (self.userObjectId != nil) ? [PFUser objectWithoutDataWithObjectId:self.userObjectId] : nil;
    
    
    if (self.objectId == nil) {
        obj = [PFObject objectWithClassName:@"UserObject"];
    }
    else {
        obj = [PFObject objectWithoutDataWithClassName:@"UserObject" objectId:self.objectId];
    }
    
    [obj setObject: self.uuid forKey:@"uuid"];
    [obj setObject: ((device != nil) ? device : [NSNull null]) forKey:@"device"];
    [obj setObject: ((object != nil) ? object : [NSNull null]) forKey:@"object"];
    [obj setObject: ((vendor != nil) ? vendor : [NSNull null]) forKey:@"vendor"];
    [obj setObject: user forKey:@"user"];
    
    [obj setObject: ((self.nickname != nil) ? self.nickname : [NSNull null]) forKey:@"nickname"];
    [obj setObject: ((self.quality != nil) ? self.quality : [NSNull null]) forKey:@"quality"];
    [obj setObject:[NSNumber numberWithBool:self.active] forKey:@"active"];

    [obj setObject:[NSNumber numberWithInt:(int)self.days] forKey:@"days"];
    [obj setObject:[NSNumber numberWithFloat:self.cost] forKey:@"cost"];
    [obj setObject:[NSNumber numberWithFloat:self.weight] forKey:@"weight"];
    [obj setObject:[NSNumber numberWithFloat:self.weightEnd] forKey:@"weightEnd"];
    [obj setObject:(isMetric ? @"metric" : @"us") forKey:@"weightType"];
    [obj setObject:[[ELA getCurrencyFormatter] currencyCode] forKey:@"currency"];
    
    [obj setObject:[NSNumber numberWithFloat:self.servingSize] forKey:@"servingSize"];
    [obj setObject:[NSNumber numberWithFloat:self.servingPrice] forKey:@"servingPrice"];
    [obj setObject:[NSNumber numberWithFloat:self.expectedLoss] forKey:@"expectedLoss"];
    
    if (self.startedAt != nil) {
        [obj setObject:self.startedAt forKey:@"startedAt"];
    }
    if (self.finishedAt != nil) {
        [obj setObject:self.finishedAt forKey:@"finishedAt"];
    }
    if (self.removedAt != nil) {
        [obj setObject:self.removedAt forKey:@"removedAt"];
    }
    
    [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        block(succeeded ? obj : nil, error);
    }];
}

- (long)getTotalDays
{
    return self.days;
}
- (int)getDaysLeft
{
    int left = (int)[self getTotalDays];
    int curr = MIN([self getCurrentDay], left);
    return left - curr;
}
- (int)getCurrentDay
{
    NSDate *now = [NSDate date];
    NSDate *start = (self.startedAt != nil) ? self.startedAt : self.createdAt;
    
    NSTimeInterval secs = [now timeIntervalSinceDate: start];
    int days = (int)floorf(secs / (60*60*24));
    
    if (days < 1) {
        days = 1;
    }
    
    return days;
}

- (NSString*)getDaysLeftString
{
    NSString * value;
    int left = [self getDaysLeft];
    if (left == 1) {
        value = @"1 day left";
    }
    else {
        value = [NSString stringWithFormat:@"%d days left", left];
    }
    return value;
}

- (NSDate*)getStartDate
{
    return (self.startedAt == nil) ? self.createdAt : self.startedAt;
}

- (int) getDaysAged
{
    
    NSTimeInterval secondsBetween = [self.removedAt timeIntervalSinceDate:[self getStartDate]];
    
    return (int)round(secondsBetween / 86400);
}

- (BOOL)isInLocker
{
    return (self.removedAt == nil);
}

- (float)getActualLoss
{
    float loss = (self.weight > 0 && self.weightEnd > 0) ? self.weight - self.weightEnd : 0;
    return (self.weight > 0) ? (100 * loss / self.weight) : 0;
}


- (float)getWeight
{
    return self.weight;
}
- (float)getCost
{
    return self.cost;
}
- (float)getCostTotal
{
    return [self getWeight] * [self getCost];
}
- (float)getCostNet
{
    float totalCost = [self getCostTotal];
    float expectedLoss = [self getExpectedLossPercent];
    return (totalCost * (1+expectedLoss));
}


- (float)getExpectedLossPercent
{
    float expectedLoss = self.expectedLoss;
    if (expectedLoss > 1.0) {
        expectedLoss = expectedLoss / 100.0f;
    }
    return expectedLoss;
}
- (float)getExpectedLossWeight
{
    float weight = [self getWeight];
    float expectedLoss = [self getExpectedLossPercent];
    return (weight > 0 && expectedLoss > 0) ? (weight * expectedLoss) : 0;
}

- (float)getServingSalePrice
{
    return self.servingPrice;
}

- (float)getExpectedServings
{
    float endWeight = [self getWeight] - [self getExpectedLossWeight];
    float servingSize = [self getServingSize];
    
    if (endWeight > 0 && servingSize > 0) {
        if ([ELA isMetric]) {
            return (endWeight * 1000 / servingSize);
        }
        else {
            return (endWeight * 16 / servingSize);
        }
    }
    return 0;
}


- (float)getServingCost
{
    float costTotal = [self getCostTotal];
    float expectedServings = [self getExpectedServings];
    return (expectedServings > 0) ? (costTotal / expectedServings) : 0;
}
- (float)getServingNetCost
{
    float costTotal = [self getCostNet];
    float expectedServings = [self getExpectedServings];
    return (expectedServings > 0) ? (costTotal / expectedServings) : 0;
}

- (float)getServingSize
{
    return self.servingSize;
}




- (Object *)object
{
    return (self.objectObjectId != nil) ? [Object getByObjectId:self.objectObjectId] : nil;
}


@end
