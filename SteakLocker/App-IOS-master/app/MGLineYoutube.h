//
//  Created by matt on 28/09/12.
//

#import "MGLine.h"
#import "MGScrollView.h"

@interface MGLineYoutube : MGLine

@property (nonatomic, strong) NSString *mediaUuid;
@property (nonatomic, strong) NSString *mediaUrl;
@property (nonatomic, strong) NSString *contextUuid;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) MGScrollView* scroller;
@property (nonatomic) CGSize boxSize;

//+ (MGLineMedia*)mediaBoxFor:(Media*)media size:(CGSize)size;
- (void)loadPhoto;

@end
