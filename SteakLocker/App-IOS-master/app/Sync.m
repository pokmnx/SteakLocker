//
//

#import "Sync.h"
#import "ParseRlmObject.h"
@implementation Sync

@dynamic type;
@dynamic updatedAt;

+ (NSString *)primaryKey {
    return @"type";
}

+ (NSArray *)indexedProperties {
    return @[@"type", @"updatedAt"];
}

+ (NSDate *) defaultDate
{
    return  [NSDate dateWithTimeIntervalSince1970: 0];
}

+ (NSDate *) shouldUpdate: (NSString *)type window:(NSTimeInterval)seconds;
{
    // Query using an NSPredicate
    NSDate *updatedAt = Nil;
    Sync *sync = [Sync objectInRealm:[RLMRealm defaultRealm] forPrimaryKey: type];

    if (sync == Nil) {
        updatedAt = [self defaultDate];
    }
    else {
        NSDate *compareAt = [[NSDate alloc] initWithTimeIntervalSinceNow: -1 * seconds];
        NSComparisonResult result = [sync.updatedAt compare: compareAt];
        if (result == NSOrderedAscending) {
            updatedAt = sync.updatedAt;
        }
    }
    
    return updatedAt;
}

+ (void)setLastUpdate: (NSString*) type
{
    [self setLastUpdate: type date:[NSDate date]];
}

+ (void)resetLastUpdate: (NSString*) type
{
    [self setLastUpdate: type date:[NSDate dateWithTimeIntervalSince1970: 0]];
}

+ (void)setLastDelete: (NSString*) type
{
    [self setLastDelete: type date:[NSDate date]];}

+ (void)setLastUpdate: (NSString*)type date: (NSDate*)updatedAt
{
    RLMRealm *realm = [ParseRlmObject startSave];
    [Sync createOrUpdateInRealm:realm withValue:@{@"type": type, @"updatedAt": updatedAt}];
    [ParseRlmObject commitSave:realm];
}

+ (void)setLastDelete: (NSString*)type date: (NSDate*)deletedAt
{
    RLMRealm *realm = [ParseRlmObject startSave];
    [Sync createOrUpdateInRealm:realm withValue:@{@"type": type, @"deletedAt": [NSDate date]}];
    [ParseRlmObject commitSave:realm];
}


@end
