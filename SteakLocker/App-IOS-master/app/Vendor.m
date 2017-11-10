
#import "Vendor.h"
#import "Sync.h"
#import "ELA.h"
#import <Parse/Parse.h>

@implementation Vendor

+ (NSString*) getType
{
    return @"Vendor";
}

+ (NSArray *)indexedProperties {
    return @[@"uuid", @"objectId"];
}

+ (NSDictionary *)defaultPropertyValues {
    return @{@"isPro" : @NO};
}


+ (NSTimeInterval) getSyncWindow
{
    double hours = 0.001;
    return (3600 * hours);
}


+ (instancetype) getOrSync: (PFObject*)object
{
    return [self getOrSync:object.objectId object:object];
}

+ (instancetype) createFromPFObject: (PFObject*) object
{
    if (![object isDataAvailable]) {
        [object fetchIfNeeded];
    }
    
    Vendor *me = [[self alloc] initFromPFObject:object withUuid: object.objectId];
    
    return [me syncFromPFObject:object];
}

- (instancetype) syncFromPFObject:(PFObject *)object
{
    [super syncFromPFObject:object];
    
    RLMRealm *realm = [ParseRlmObject startSave];
    
    self.title = [object objectForKey:@"title"];
    
    NSNumber *value = [object objectForKey:@"active"];
    self.active = [value boolValue];
    
    self.website = [object objectForKey:@"website"];
    self.address = [object objectForKey:@"address"];
    self.city = [object objectForKey:@"city"];
    self.state = [object objectForKey:@"state"];
    self.zip = [object objectForKey:@"zip"];
    value = [object objectForKey:@"isPro"];
    self.isPro = [value boolValue];
    
    [realm addOrUpdateObject: self];
    [ParseRlmObject commitSave:realm];
    
    return self;
}


+ (RLMResults *) getAll
{
    return ([ELA isProUser]) ? [self getAllPro] : [self getAllNonPro];
}

+ (RLMResults *) getAllNonPro
{
    return [[Vendor objectsWhere  : @"active = YES AND isPro = NO"] sortedResultsUsingKeyPath:@"title" ascending:YES];
}

+ (RLMResults *) getAllPro
{
    return [[Vendor objectsWhere  : @"active = YES AND isPro = YES"] sortedResultsUsingKeyPath:@"title" ascending:YES];
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


@end
