//
//  ParseRlmObject.h
//

#ifndef ParseRlmObject_h
#define ParseRlmObject_h

#import <Realm/Realm.h>
#import <Parse/Parse.h>
#import "Sync.h"

@interface ParseRlmObject : RLMObject

@property NSString * uuid;
@property NSString * objectId;
@property NSDate * createdAt;
@property NSDate * updatedAt;
@property BOOL dirty;

- (instancetype) initFromPFObject: (PFObject*) object withUuid: (NSString*)uuid;
- (instancetype) initFromPFObject: (PFObject*) object;
- (instancetype) syncFromPFObject: (PFObject*) object;
- (void) syncFromPFObjectAsync: (PFObject*) object;
- (instancetype) save;
+ (RLMRealm *)startSave;
+ (void)commitSave: (RLMRealm *)realm;


- (void)safeAddObject:(RLMObject *)object toArray:(RLMArray *)array;

+ (NSString*) getType;
+ (NSTimeInterval) getSyncWindow;
+ (void) checkSync;
+ (void) resetSync;
+ (void) getUpdates: (NSString*)type date:(NSDate*) updatedAt;
+ (void) getUpdates: (NSString*)type date:(NSDate*) updatedAt block: (nullable PFQueryArrayResultBlock)block;
+ (void) processDeletes: (NSString*)type date:(NSDate*) updatedAt;
+ (void) syncObjects:(NSString*)cacheKey objects:(NSArray*)objects;

+ (BOOL) modifyUpdatesQuery: (PFQuery*)query;
+ (BOOL) modifyDeletesQuery: (PFQuery*)query;

+ (instancetype) createFromPFObject: (PFObject*) object;

+ (instancetype) createNew;
+ (void) deleteFromPFObject: (PFObject*) object;
+ (void) deleteById: (NSString*) uuid;
+ (instancetype) getByObjectId: (NSString*) objectId;
+ (instancetype) getOrSync: (PFObject*)object;
+ (instancetype) getOrSync: (NSString*)uuid object: (PFObject*)object;
+ (instancetype) getOrSyncUser: (PFUser*)user;

@end

#endif /* ParseRlmObject_h */
