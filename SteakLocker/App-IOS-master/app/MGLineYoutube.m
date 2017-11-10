//
//  Created by matt on 28/09/12.
//

#import "MGLineYoutube.h"
#import "ELA.h"

@implementation MGLineYoutube

#pragma mark - Init

- (void)setup {
    // positioning
    self.topMargin = 0;
    self.leftMargin = 0;
    
    // background
    self.backgroundColor = [UIColor lightGrayColor];
}

#pragma mark - Factories
/*
+ (instancetype)mediaBoxFor:(Media*)media size:(CGSize)rowSize
{
    MGLineMedia *row = [MGLineMedia lineWithSize:rowSize];
    row.mediaUuid   = media.uuid;
    row.mediaUrl    = media.imageUrl;
    row.contextUuid = media.contextUuid;
    row.boxSize     = rowSize;
    
    if (media.imageUrl != nil) {
        // do the photo loading async, because internets
        __weak id wrow = row;
        row.asyncLayoutOnce = ^{
            [wrow loadPhoto];
        };
    }
    
    return row;
}
 

#pragma mark - Photo box loading

- (void)loadPhoto
{
    UIImage *image = nil;
    NSData *imageData = nil;
    CGSize size;
    float ratio;
    
    imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString: self.mediaUrl]];
    if (imageData != nil) {
        image = [UIImage imageWithData:imageData];
        size = image.size;
        ratio = image.size.width / image.size.height;
        size = CGSizeMake(self.boxSize.width, self.boxSize.width / ratio);
        self.boxSize = size;
        self.image = [Pocket imageResize:image andResizeTo:size];
    }
    else {
        size = self.boxSize;
    }
    
    // do UI stuff back in UI land
    dispatch_async(dispatch_get_main_queue(), ^{
        // failed to get the photo?
        if (!imageData) {
            return;
        }
        
        Media *media = [Media objectForPrimaryKey:self.mediaUuid];
        if (media != nil) {
            [media saveImage: self.image];
        }
        
        
        // got the photo, so lets show it
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
        imageView.frame = CGRectMake(0, 0, size.width, size.height);
        imageView.alpha = 0;
        [imageView setContentMode: UIViewContentModeScaleAspectFit];
        imageView.clipsToBounds = YES;
        self.clipsToBounds = YES;
        [self addSubview:imageView];
        
        // fade the image in
        [UIView animateWithDuration:0.2 animations:^{
            imageView.alpha = 1;
        }];
    });
}
*/
@end
