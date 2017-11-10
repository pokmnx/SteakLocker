//
//  BlogScroller.h
//  Steak Locker
//
//  Created by Jared Ashlock on 10/27/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#ifndef Steak_Locker_BlogScroller_h
#define Steak_Locker_BlogScroller_h

@interface BlogScrollerItemLabel : UILabel

@end

@interface BlogScroller : UIView <UIScrollViewDelegate>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) NSMutableArray *items;
@property (assign) CGRect subViewRect;

- (instancetype)initWithFrame:(CGRect)frame title: (NSString*)title;
- (void)setItems: (NSMutableArray*)objects;
- (IBAction)handleScrollTap:(UITapGestureRecognizer *)recognizer;
@end


@interface BlogScrollerItem : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) PFImageView *imageView;
@property (nonatomic, strong) BlogScrollerItemLabel *labelTitle;

- (void)initTitle: (NSString*)stitle url:(NSString*)url image:(PFFile*)file;
@end





#endif
