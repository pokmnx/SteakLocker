//
//  BlogScroller.m
//  Steak Locker
//
//  Created by Jared Ashlock on 10/27/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BlogScroller.h"
#import "ELA.h"
#import "SLModels.h"
#import "DashboardController.h"



@interface BlogScrollerItemLabel ()

@end

@implementation BlogScrollerItemLabel
- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 10, 0, 10};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}
@end




@interface BlogScrollerItem ()

@end

@implementation BlogScrollerItem
@synthesize title;
@synthesize url;
@synthesize labelTitle;
@synthesize imageView;


- (void)initTitle: (NSString*)stitle url:(NSString*)surl image:(PFFile*)file
{
    self.url = surl;
    
    float width = self.frame.size.width - 15;
    float height = self.frame.size.height;
    
    imageView = [[PFImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    //creature.image = [UIImage imageNamed:@"1.jpg"]; // placeholder image
    imageView.file = file;
    [imageView loadInBackground];
    [self addSubview:imageView];
    
    
    labelTitle = [[BlogScrollerItemLabel alloc] initWithFrame:CGRectMake(0, height-60, width, 60)];
    [labelTitle setTextColor:[UIColor whiteColor]];
    [labelTitle setBackgroundColor:[ELA getColorAccent]];
    [labelTitle setText: stitle];
    [labelTitle setNumberOfLines:2];
    [labelTitle setFont:[ELA getFont:16]];
    [self addSubview:labelTitle];
}


@end




@interface BlogScroller ()
- (void)commonInit: (NSString*)stitle;

@end



@implementation BlogScroller
@synthesize title;
@synthesize labelTitle;
@synthesize scrollView;
@synthesize subViewRect;
@synthesize items;

- (instancetype)initWithFrame:(CGRect)frame title:(NSString*)stitle;
{
    self = [super initWithFrame:frame];
    self.title = stitle;
    self.frame = frame;
    
    items = [[NSMutableArray alloc] init];
    
    [self commonInit:stitle];
    return self;
}

- (void)commonInit: (NSString*)stitle
{
    CGRect scrn = [ELA getScreen];
    
    
    labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, scrn.size.width-30, 30)];
    labelTitle.text = stitle;
    labelTitle.textColor = [ELA getColorAccent];
    labelTitle.font = [ELA getFont:22.0f];
    [self addSubview: labelTitle];
    

    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(15, 60, scrn.size.width-45, 210)];
    //scrollView.pagingEnabled = YES;
    //scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = YES;
    scrollView.clipsToBounds = NO;
    scrollView.userInteractionEnabled = NO;
    scrollView.delegate = self;
    [self addSubview:scrollView];
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        return self.scrollView;
    }
    return nil;
}
- (void)setItems: (NSMutableArray*)objects
{
    int count = 0;
    float itemWidth = scrollView.frame.size.width;
    CGRect frameItem = CGRectMake(0, 0, itemWidth, scrollView.frame.size.height);
    BlogScrollerItem * item = nil;
    
    
    
    
    [[scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    for (SLTipTrick *data in objects) {
        frameItem.origin.x = count * itemWidth;
        item = [[BlogScrollerItem alloc] initWithFrame:frameItem];
        item.userInteractionEnabled = YES;
        [item initTitle: data.title url:data.url image: data.image];
        [scrollView addSubview:item];
        [scrollView bringSubviewToFront:item];

        [items addObject:item];
        
        UITapGestureRecognizer *tapRecognizer;
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleScrollTap:)];
        [self addGestureRecognizer: tapRecognizer];
        
        count++;
    }
    
    scrollView.contentSize = CGSizeMake((itemWidth * [objects count]), frameItem.size.height);
}


- (IBAction)handleScrollTap:(UITapGestureRecognizer *)recognizer
{
    BlogScroller * me = (BlogScroller*)recognizer.view;

    for (BlogScrollerItem *item in me.items) {
        
        if (CGRectContainsPoint([item frame], [recognizer locationInView:me.scrollView])) {
            NSURL *urlToOpen = [NSURL URLWithString:item.url];
            [[UIApplication sharedApplication] openURL:urlToOpen];
        }
    }


}


@end
