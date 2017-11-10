
#import "Object.h"
#import "Sync.h"
#import "ELA.h"
#import <Parse/Parse.h>

@implementation Object

+ (NSString*) getType
{
    return @"Object";
}

+ (NSArray *)indexedProperties {
    return @[@"uuid", @"objectId"];
}

+ (NSArray *)ignoredProperties {
    return @[@"image",@"imagePath"];
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

+ (Object*) createFromPFObject: (PFObject*) object
{
    if (![object isDataAvailable]) {
        [object fetchIfNeeded];
    }

    Object *me = [[self alloc] initFromPFObject:object withUuid: object.objectId];
    
    return [me syncFromPFObject:object];
}

- (instancetype) syncFromPFObject:(PFObject *)object
{
    [super syncFromPFObject:object];
    
    RLMRealm *realm = [ParseRlmObject startSave];

    self.type = [object objectForKey:@"type"];
    self.title = [object objectForKey:@"title"];

    NSNumber *value = [object objectForKey:@"active"];
    self.active = [value boolValue];

    
    PFFile *file = [object objectForKey:@"image"];
    if (file != Nil) {
        self.imageUrl = file.url;
    }
    
    value = [object objectForKey:@"defaultDays"];
    self.defaultDays = [value intValue];
    value = [object objectForKey:@"expectedLoss"];
    self.expectedLoss = [value floatValue];
    value = [object objectForKey:@"suggestedServingSize"];
    self.suggestedServingSize = [value floatValue];
    
    
    self.servingSize = [object objectForKey:@"servingSize"];
    self.calories = [object objectForKey:@"calories"];
    self.caloriesFromFat = [object objectForKey:@"caloriesFromFat"];
    self.totalFat = [object objectForKey:@"totalFat"];
    self.saturatedFat = [object objectForKey:@"saturatedFat"];
    self.transFat = [object objectForKey:@"transFat"];
    self.cholesterol = [object objectForKey:@"cholesterol"];
    self.sodium = [object objectForKey:@"sodium"];
    self.carbohydrates = [object objectForKey:@"carbohydrates"];
    self.dietaryFiber = [object objectForKey:@"dietaryFiber"];
    self.sugars = [object objectForKey:@"sugars"];
    self.protein = [object objectForKey:@"protein"];
    self.vitaminA = [object objectForKey:@"vitaminA"];
    self.vitaminC = [object objectForKey:@"vitaminC"];
    self.calcium = [object objectForKey:@"calcium"];
    self.iron = [object objectForKey:@"iron"];
    self.information = [object objectForKey:@"information"];
    
    [realm addOrUpdateObject: self];
    [ParseRlmObject commitSave:realm];
    
    return self;
}


+ (RLMResults *) getAll
{
    return [[Object objectsWhere  : @"active = YES"] sortedResultsUsingKeyPath:@"title" ascending:YES];
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


- (NSString*)getAgingType
{
    return ([self.type isEqualToString: TYPE_CHARCUTERIE]) ? TYPE_CHARCUTERIE : TYPE_DRYAGING;
}

- (BOOL) isAgingType: (NSString*)agingType
{
    NSString *type = [self getAgingType];
    return [type isEqualToString:agingType];
}

@end
