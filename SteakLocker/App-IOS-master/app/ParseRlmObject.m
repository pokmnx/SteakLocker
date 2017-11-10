//
//

#import "ParseRlmObject.h"
#import "Sync.h"
#import "ELA.h"
#import <Parse/Parse.h>

@implementation ParseRlmObject


+ (NSString *)primaryKey {
    return @"uuid";
}

+ (NSArray *)indexedProperties {
    return @[@"uuid", @"objectId"];
}
+ (NSDictionary *)defaultPropertyValues
{
    return @{
             @"dirty": @NO
             };
}
+ (NSString*) getType
{
    return Nil;
}

+ (NSTimeInterval) getSyncWindow
{
    double hours = 0.25;
    return (3600 * hours);
}

+ (void) checkSync
{
    NSDate *updatedAt     = Nil;
    NSString *type        = [self getType];
    NSTimeInterval window = [self getSyncWindow];
    if (type != Nil && window > 0) {
        updatedAt = [Sync shouldUpdate: type window:window];
        if (updatedAt != Nil) {
            [self processDeletes:type date:updatedAt];
            [self getUpdates:type date:updatedAt];

        }
    }
}

+ (void) resetSync
{
    [Sync resetLastUpdate: [self getType]];
}

+ (void) getUpdates: (NSString*)type date:(NSDate*) updatedAt
{
    dispatch_async([ELA getAsyncQueue], ^{
        PFQuery *query = [PFQuery queryWithClassName: type];
        [query whereKey:@"updatedAt" greaterThanOrEqualTo: updatedAt];
        
        if (![self modifyUpdatesQuery:query]) {
            return;
        }
        
        // Query for new results from the network
        [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError *error) {
            if (!error) {
                [self syncObjects:type objects:objects];
            }
        }];
    });
}

+ (void) syncObjects:(NSString*)cacheKey objects:(NSArray*)objects
{
    [Sync setLastUpdate:cacheKey date:[NSDate date]];
    for (PFObject* object in objects) {
        [self getOrSync: object];
    }
    if (objects.count > 0) {
        [ELA emit: [NSString stringWithFormat:@"updated%@", cacheKey]];
    }
}


+ (BOOL)modifyUpdatesQuery:(PFQuery *)query
{
    return YES;
}

- (void)safeAddObject:(RLMObject *)object toArray:(RLMArray *)array {
    if (object.realm != array.realm && array.realm != nil) {
        // If the object isn't in this Realm - bring it in
        RLMObject *newlyCreatedObject = [[object class] createOrUpdateInRealm: array.realm withValue:object];
        [array addObject:newlyCreatedObject];
    } else {
        // If the object is already in this Realm, it's safe to just add a link to it
        [array addObject:object];
    }
}


+ (instancetype) getByObjectId: (NSString*) objectId
{
    if (objectId != nil && [objectId length] > 0) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"objectId == %@", objectId];
        RLMResults *items = [self objectsWithPredicate:pred];
        return (items.count > 0) ? items[0] : Nil;
    }
    return nil;
}

+ (void) deleteById: (NSString*) uuid
{
    ParseRlmObject* obj = [self objectForPrimaryKey: uuid];
    if (obj != nil) {
        RLMRealm *realm = [self startSave];
        [realm deleteObject:obj];
        [self commitSave:realm];
    }
}

+ (void) deleteFromPFObject: (PFObject*) object
{
    ParseRlmObject *rlmObj = nil;
    NSString *uuid = [object objectForKey:@"uuid"];
    if (uuid != Nil) {
        rlmObj = [self objectForPrimaryKey:uuid];
    }
    else {
        rlmObj = [self getByObjectId: [object objectForKey:@"deleteId"]];
    }
    if (rlmObj != nil) {
        RLMRealm *realm = [self startSave];
        [realm deleteObject: rlmObj];
        [self commitSave:realm];
    }
}


+ (void) processDeletes: (NSString*)type date:(NSDate*) updatedAt
{
    NSDate * now = [NSDate date];
    PFQuery *query = [PFQuery queryWithClassName: @"Deletes"];
    [query whereKey: @"type" equalTo: type];
    [query whereKey: @"updatedAt" greaterThanOrEqualTo: updatedAt];
    
    if (![self modifyDeletesQuery:query]) {
        return;
    }
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    // Query for new results from the network
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError *error) {
        if (!error) {
            for (PFObject* object in objects) {
                [realm transactionWithBlock:^{
                    [self deleteFromPFObject:object];
                }];
            }
            [Sync setLastDelete:type date:now];
        }
    }];
    
}

+ (BOOL)modifyDeletesQuery:(PFQuery *)query
{
    return YES;
}



+ (instancetype) createNew
{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSDate *now = [NSDate date];
    return [[self alloc] initWithValue: @{@"uuid" : uuid, @"createdAt": now, @"updatedAt": now }];
}

+ (instancetype) createFromPFObject: (PFObject*) object
{
    ParseRlmObject * me = [self alloc];
    return [me initFromPFObject:object];
}


- (instancetype) syncFromPFObject: (PFObject*)object
{
    RLMRealm *realm = [ParseRlmObject startSave];
    
    self.objectId = object.objectId;
    self.updatedAt = object.updatedAt;
    self.dirty = NO;
    
    [ParseRlmObject commitSave:realm];

    return self;
}

- (void) syncFromPFObjectAsync: (PFObject*)object
{
    //dispatch_async([Pocket getAsyncQueue], ^{
        [object fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (error == nil) {
      //          dispatch_async(dispatch_get_main_queue(), ^{
                    [self syncFromPFObject:object];
        //        });
            }
        }];
    //});
}


- (instancetype) save
{
    RLMRealm *realm = [ParseRlmObject startSave];
    [realm addOrUpdateObject: self];
    [ParseRlmObject commitSave:realm];
    return self;
}

+ (RLMRealm *)startSave
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    if (![realm inWriteTransaction]) {
        [realm beginWriteTransaction];
    }
    return realm;
}
+ (void)commitSave: (RLMRealm *)realm
{
    if ([realm inWriteTransaction]) {
        [realm commitWriteTransaction];
    }
}


- (instancetype) initFromPFObject: (PFObject*) object withUuid: (NSString*)uuid
{
    return [[self initWithValue:@{@"uuid" : uuid,
                                  @"objectId": object.objectId,
                                  @"createdAt": object.createdAt,
                                  @"updatedAt": object.updatedAt
                                  }] save];
}

- (instancetype) initFromPFObject: (PFObject*) object
{
    NSString *uuid = [object objectForKey:@"uuid"];
    if (uuid == Nil){
        uuid = object.objectId;
    }
    
    return [[self initWithValue:@{@"uuid" : uuid,
                                 @"objectId": object.objectId,
                                 @"createdAt": object.createdAt,
                                 @"updatedAt": object.updatedAt
                                 }] save];
}


+ (instancetype) getOrSync: (PFObject*)object
{
    return [self getOrSync:[object objectForKey:@"uuid"] object:object];
}

+ (instancetype) getOrSync: (NSString*)uuid object: (PFObject*)object
{
    ParseRlmObject *obj = [self objectForPrimaryKey:uuid];
    if (obj == Nil) {
        obj = [self createFromPFObject:object];
    }
    else {
        obj = [obj syncFromPFObject:object];
    }
    return obj;
}

+ (instancetype) getOrSyncUser: (PFUser*)user
{
    NSString *uuid = user.objectId;
    return [self getOrSync:uuid object: user];
}


@end
