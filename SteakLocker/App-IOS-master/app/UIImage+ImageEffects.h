//
//  UIImage+ImageEffects.h
//  Steak Locker
//
//  Created by Jared Ashlock on 10/18/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#ifndef Steak_Locker_UIImage_ImageEffects_h
#define Steak_Locker_UIImage_ImageEffects_h

@interface UIImage (ImageEffects)

- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end


#endif
