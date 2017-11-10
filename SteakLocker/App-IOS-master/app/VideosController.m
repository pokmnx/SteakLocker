//
//  ProfileController.m
//  app
//
//  Created by Jared Ashlock on 10/7/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import "VideosController.h"
#import <Parse/Parse.h>
#import "ELA.h"
#import <Foundation/Foundation.h>

#import "MGScrollView.h"
#import "MGTableBoxStyled.h"
#import "MGLineStyled.h"
#import "SLModels.h"
#import "MGLineYoutube.h"
#import "UIImageView+WebCache.h"

#define IPHONE_PORTRAIT_PHOTO  (CGSize){148, 148}
#define IPHONE_LANDSCAPE_PHOTO (CGSize){152, 152}

#define IPHONE_PORTRAIT_GRID   (CGSize){312, 0}
#define IPHONE_LANDSCAPE_GRID  (CGSize){160, 0}
#define IPHONE_TABLES_GRID     (CGSize){320, 0}

#define IPAD_PORTRAIT_PHOTO    (CGSize){128, 128}
#define IPAD_LANDSCAPE_PHOTO   (CGSize){122, 122}

#define IPAD_PORTRAIT_GRID     (CGSize){136, 0}
#define IPAD_LANDSCAPE_GRID    (CGSize){390, 0}
#define IPAD_TABLES_GRID       (CGSize){624, 0}

@interface VideosController () <MBProgressHUDDelegate>

@end

@implementation VideosController
@synthesize hud;
@synthesize hudMsg;
MGBox *tablesGrid, *table;
dispatch_queue_t asyncQueueVideo;
UIImage *arrow;
BOOL phone;
NSArray *blogPosts;

- (dispatch_queue_t) getAsyncQueue
{
	if (asyncQueueVideo == nil) {
		asyncQueueVideo = dispatch_queue_create("SerialQueue", DISPATCH_QUEUE_SERIAL);
	}
	return asyncQueueVideo;
}


- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.theMenu = [ELA initDropMenuAndAdd:self];
	
	self.view.backgroundColor = [ELA getColorBGLight];
	
	
	//BlogScroller * scroll = [[BlogScroller alloc] initWithFrame:[ELA getScreen]];
	//[self.view addSubview:scroll];
	
	CGRect frame = self.view.frame;
	
	//float h = 64;
	
	float h = [ELA getHeaderHeight:self];
	
	frame.size.height -= h;
	//frame.size.height -= 50; // for tab bar
	self.scroller = [[MGScrollView alloc] initWithFrame:frame];
	[self.view addSubview:self.scroller];
	
	// setup the main scroller (using a grid layout)
	self.scroller.contentLayoutMode = MGLayoutGridStyle;
	//self.scroller.bottomPadding = 65;
	
	
	[self reloadFeed];
	
	[ELA loadTipsTricks:^(BOOL success, NSArray *objects){
		blogPosts = objects;
		[self reloadFeed];
	}];
}

- (void)addLoadingBox
{
	CGRect scrn = [ELA getScreen];
	CGSize rowSize  = CGSizeMake(scrn.size.width, 50);
	
	// intro section
	MGTableBox *box = MGTableBox.box;
	[table.boxes addObject:box];
	
	
	MGLineStyled *header = [MGLineStyled lineWithLeft: @"Loading..." right:nil size: rowSize];
	[header setFont: [ELA getFont:20]];
	[box.topLines addObject:header];
}


- (void)addBoxForMedia: (SLTipTrick*)post {
	CGRect scrn = [ELA getScreen];
	CGSize rowSize  = CGSizeMake(scrn.size.width-16, 50);
	
	NSError *error = NULL;
	NSRegularExpression *regex =
	[NSRegularExpression regularExpressionWithPattern:@".*v=([^&]+)"
											  options:NSRegularExpressionCaseInsensitive
												error:&error];
	NSTextCheckingResult *match = [regex firstMatchInString:post.url
													options:0
													  range:NSMakeRange(0, [post.url length])];
	
	// Only display Youtube videos
	
	if (([[NSURL URLWithString:post.url].host isEqualToString: @"www.youtube.com"]) && match) {
		
		// intro section
		MGTableBoxStyled *box = MGTableBoxStyled.box;
		box.topMargin = 15;
		box.bottomMargin = 15;
		[table.boxes addObject:box];
		
		// Populate image with fetched image
		CGSize imageSize = CGSizeMake(rowSize.width, rowSize.width * (9.0f/16.0f));
		UIImageView *videoPicture =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
		[videoPicture setContentMode:UIViewContentModeScaleAspectFill];
		
		NSRange videoIDRange = [match rangeAtIndex:1];
		NSString *substringForFirstMatch = [post.url substringWithRange:videoIDRange];
		
		NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/hqdefault.jpg", substringForFirstMatch]];
		NSURLSessionDownloadTask *downloadPhotoTask = [[NSURLSession sharedSession]
													   
													   downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
														   
														   UIImage *downloadedImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:location]];
														   
														   
														   if (!error && [(NSHTTPURLResponse *) response statusCode] == 200) {
															   
															   
															   dispatch_async(dispatch_get_main_queue(), ^{
																   videoPicture.image = downloadedImage;
															   });
														   }
														   
														   
													   }];
		[downloadPhotoTask resume];
		
		// Configure row
		MGLine *row = [MGLine lineWithLeft:videoPicture right:nil size:imageSize];
		row.onTap = ^{
			NSURL *urlToOpen = [NSURL URLWithString: post.url];
			[[UIApplication sharedApplication] openURL:urlToOpen];
		};
		if (row != nil) {
			[box.topLines addObject:row];
		}
		
		// header line
		NSString *title = post.title;
		if (title != nil) {
			MGLine *row = [MGLineStyled lineWithMultilineLeft: title right:nil width: rowSize.width minHeight:rowSize.height];
			row.onTap = ^{
				NSURL *urlToOpen = [NSURL URLWithString: post.url];
				[[UIApplication sharedApplication] openURL:urlToOpen];
			};
			
			[row setBackgroundColor:[UIColor whiteColor]];
			[row setFont: [ELA getFont: 15]];
			[box.topLines addObject:row];
		}
	}
	
	
	/*
	 
	 UIImage * image = [media getImage];
	 UIImage* imageSized = nil;
	 
	 if (image != nil) {
	 float ratio = image.size.width / image.size.height;
	 CGSize size = CGSizeMake(rowSize.width, rowSize.width/ratio);
	 imageSized = [Pocket imageResize:image andResizeTo:size];
	 
	 
	 MGLine *row = [MGLine lineWithLeft:imageSized right:nil size:size   ];
	 
	 if (row != nil) {
	 [box.topLines addObject:row];
	 }
	 }
	 else if (media.imageUrl != nil) {
	 MGLineMedia * row = [MGLineMedia mediaBoxFor:media size:CGSizeMake(rowSize.width, rowSize.width)];
	 row.scroller = self.scroller;
	 if (row != nil) {
	 [box.topLines addObject:row];
	 }
	 }
	 
	 
	 if (!IsEmpty(media.message)) {
	 // layout menu line
	 MGLineStyled *msgLine = [MGLineStyled multilineWithText:media.message font:nil width:rowSize.width
	 padding:UIEdgeInsetsMake(16, 16, 16, 16)];
	 [box.topLines addObject:msgLine];
	 }
	 
	 // convenience features menu line
	 NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	 [formatter setDateStyle:NSDateFormatterMediumStyle];
	 [formatter setTimeStyle:NSDateFormatterShortStyle];
	 
	 rowSize  = CGSizeMake(scrn.size.width-16, 30);
	 MGLineStyled *date = [MGLineStyled lineWithLeft: [formatter stringFromDate:media.createdAt] right:arrow size:rowSize];
	 [date setFont: [Pocket getFont:12]];
	 [box.topLines addObject: date];
	 */
}


- (void)reloadFeed
{
	[self.scroller.boxes removeAllObjects];
	
	CGRect scrn = [ELA getScreen];
	CGSize gridSize  = CGSizeMake(scrn.size.width, 0);
	
	// iPhone or iPad?
	UIDevice *device = UIDevice.currentDevice;
	phone = device.userInterfaceIdiom == UIUserInterfaceIdiomPhone;
	
	// the tables grid
	tablesGrid = [MGBox boxWithSize:gridSize];
	tablesGrid.contentLayoutMode = MGLayoutTableStyle;
	[self.scroller.boxes addObject:tablesGrid];
	
	// the features table
	table = MGBox.box;
	[tablesGrid.boxes addObject:table];
	table.sizingMode = MGResizingShrinkWrap;
	
	
	if (blogPosts != nil) {
		
		for (SLTipTrick *data in blogPosts) {
			[self addBoxForMedia:data];
		}
	}
	else {
		[self addLoadingBox];
	}
	
	/*
	 RLMResults *results = [Feed getAll];
	 
	 if (results.count > 0) {
	 for (Feed *feed in results) {
	 if ([feed.type isEqualToString:@"Media"]) {
	 [self addBoxForMedia: feed];
	 }
	 else if ([feed.type isEqualToString:@"Message"]) {
	 [self addBoxForMessage:feed];
	 }
	 
	 
	 //[self addBoxForMedia:msg];
	 }
	 }
	 else {
	 [self addBoxNoFeed];
	 }
	 */
	
	[self.scroller layout];
}

- (void)viewDidAppear:(BOOL)animated {
	
	[self.view setBackgroundColor:[ELA getColorBGLight]];
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


- (IBAction)onMenu: (id)sender
{
	self.theMenu.activeItemName = @"Videos";
	if (self.theMenu.showing) {
		[self.theMenu hideMenu];
		[self.theMenu setAlpha:0.0f];
		[self.view sendSubviewToBack:self.theMenu];
	}
	else {
		[self.view bringSubviewToFront:self.theMenu];
		[self.theMenu setAlpha:1.0f];
		[self.theMenu showMenu];
	}
	
	
}


#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hudWhat {
	
	if (hud) {
		// Remove HUD from screen when the HUD was hidded
		[hud removeFromSuperview];
		hud = nil;
	}
	if (hudMsg) {
		[hudMsg removeFromSuperview];
		hudMsg = nil;
	}
}

@end
