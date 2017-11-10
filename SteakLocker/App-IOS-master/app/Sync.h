//
//  Sync.h
//

#ifndef Sync_h
#define Sync_h

#import <Realm/Realm.h>

@interface Sync : RLMObject

@property NSString *type;
@property NSDate * updatedAt;
@property NSDate * deletedAt;

+ (NSDate*) defaultDate;
+ (NSDate*) shouldUpdate: (NSString*) type window:(NSTimeInterval)seconds;
+ (void)setLastUpdate: (NSString*) type;
+ (void)resetLastUpdate: (NSString*) type;
+ (void)setLastDelete: (NSString*) type;
+ (void)setLastUpdate: (NSString*) type date:(NSDate*) updatedAt;
+ (void)setLastDelete: (NSString*) type date:(NSDate*) deletedAt;
@end


#endif /* Sync_h */
