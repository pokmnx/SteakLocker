//
//  ELA.h
//  app
//
//  Created by Jared Ashlock on 10/9/14.
//  Copyright (c) 2014 Steak Locker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <Bolts/Bolts.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "UIImage+ImageEffects.h"
#import "DropMenu.h"
#import <ParseUI/ParseUI.h>
#import <EventEmitter/EventEmitter.h>
#import "SDNetworkActivityIndicator.h"
#import <Realm/Realm.h>

#ifndef app_ELA_h
#define app_ELA_h

#define CELSIUS = 0;
#define FAHRENHEIT = 1;

extern NSString *const _Nonnull TYPE_DRYAGING_MEAT;
extern NSString *const _Nonnull TYPE_DRYAGING_PRO;
extern NSString *const _Nonnull TYPE_DRYAGING;
extern NSString *const _Nonnull TYPE_CHARCUTERIE;

@class ELADevice;


@interface ELA : NSObject


+ (dispatch_queue_t _Nonnull)getAsyncQueue;
+(void)load;
+ (void)registerNotifications;

+ (AppDelegate * _Nonnull) getApp;
+ (UIViewController * _Nonnull) getRootView;

+ (CGRect)getScreen;
+ (int)getStatusBarHeight;
+ (int)getHeaderHeight: (UIViewController* _Nonnull)controller;
+ (int)getOffsetBottom: (UIViewController* _Nonnull)controller offset:(int)height;

+ (UIImageView * _Nonnull)addImage: (NSString* _Nonnull)file frame:(CGRect)frame;
+ (UIImageView * _Nonnull)addImage: (NSString* _Nonnull)file X:(int)x Y:(int)y W:(int)w H:(int)h;
+ (PFImageView * _Nonnull)addPFImage: (NSString* _Nonnull)file frame:(CGRect)frame;
+ (PFImageView * _Nonnull)addPFImage: (NSString* _Nonnull)file X:(int)x Y:(int)y W:(int)w H:(int)h;

+ (NSString * _Nonnull)getAPIKey;
+ (NSString * _Nonnull)getGlobalPlanId;

+ (UIImage * _Nonnull)imageWithColor:(UIColor * _Nonnull)color;
+ (UIColor * _Nonnull)getColorText;
+ (UIColor * _Nonnull)getColorBGDark;
+ (UIColor * _Nonnull)getColorBGDarker;
+ (UIColor * _Nonnull)getColorBGLight;
+ (UIColor * _Nonnull)getColorBGLightest;
+ (UIColor * _Nonnull)getColorTypeWarning;
+ (UIFont * _Nonnull)getFont: (int)size;
+ (UIFont * _Nonnull)getFontThin: (int)size;
+ (UIFont * _Nonnull)getFontMedium: (int)size;
+ (UIFont * _Nonnull)getFontBold: (int)size;
+ (UIFont * _Nonnull)getFontItalic: (int)size;

+ (void) saveDevice:(NSString * _Nonnull)impeeId planId:(NSString * _Nullable)planId agentUrl:(NSString * _Nullable)agentUrl callback:(void (^)())callback;
//+ (void)loadUserDevice:(void (^)(BOOL, PFObject *))callback;
+ (void)setUserDevice: (PFObject* _Nullable)device;
+ (PFObject * _Nullable)getUserDevice;
+ (PFObject * _Nullable)getUserDeviceById: (NSString* _Nonnull)objectId;
+ (PFObject * _Nullable)getUserDeviceByImpeeId: (NSString* _Nonnull)impeeId;
+ (NSArray* _Nullable)getUserDevices;

+ (PFObject * _Nullable)updateUserDevice: (PFObject * _Nullable)device latestMeasurement:(PFObject * _Nullable)measurement;

+ (int)getDeviceCount;
+ (void)loadUserDevices:(void (^)(NSArray * _Nullable objects, NSError * _Nullable error))callback;
+ (void)reloadUserDevices:(void (^)(NSArray * _Nullable objects, NSError * _Nullable error))callback;
+ (BOOL)isDeviceActive:(PFObject * _Nonnull)device;


+ (NSNumberFormatter * _Nonnull)getCurrencyFormatter;
+ (NSString * _Nonnull)formatCurrency:(float)value;

+ (float)gramsToOunces: (float)grams;
+ (float)ouncesToGrams: (float)ounces;


+ (NSString * _Nonnull) getAgingType;
+ (NSString * _Nonnull) getDeviceAgingType: (PFObject * _Nullable)device;
+ (float) getDeviceTemperature: (PFObject * _Nullable)device;
+ (float) getDeviceHumidity: (PFObject* _Nullable)device;
+ (BOOL) userHasCharcuterieEnabled;
+ (void) userEnableCharcuterie;
+ (void) userSetAgingType:(NSString * _Nullable)agingType;
+ (void) userSetTemperature: (float)fahrenheit;
+ (void) userSetHumidity: (float)humidity;
+ (void) deviceSetNickname:(PFObject* _Nonnull)device nickname:(NSString * _Nonnull)nickname;
+ (void) deviceSetAgingType:(PFObject * _Nonnull)device agingType:(NSString* _Nullable)agingType;
+ (void) deviceSetTemperature:(PFObject* _Nonnull)device temp:(float)fahrenheit;
+ (void) deviceSetHumidity:(PFObject* _Nonnull)device humidity:(float)humidity;


+ (void) loadConfig:(void (^)(BOOL, PFConfig *))callback;
+ (PFConfig*)getConfig;

+ (int)getConfigInt:(NSString*)key;
+ (float)getConfigFloat:(NSString*)key;
+ (BOOL)getConfigBool:(NSString*)key;
+ (NSString *)getConfigString: (NSString*)key;

+ (NSArray*)getTipsTricks;
+ (void) loadTipsTricks:(void (^)(BOOL, NSArray *))callback;


+ (void) getUserImpeeId:(void (^)(BOOL, NSString *))callback;
+ (void) getLatestMeasurement:(NSString*)impeeId callback:(void (^)(BOOL, PFObject *))callback;

+ (float)celsiusToFahrenheit:(float)celsius;
+ (float)celsiusToFahrenheit:(float)celsius round:(bool)round;
+ (float)fahrenheitToCelsius:(float)fahrenheit;

+ (NSArray *) getLatestUserObjects;
+ (int) getCountLatestUserObjects: (NSString *)ignoreAgingType;


+ (UIImage* _Nonnull)blurredSnapshot: (UIView* _Nonnull)imageView frame: (CGRect)frame;
+ (UIImage* _Nonnull)blurredSnapshot: (UIView* _Nonnull)imageView size: (CGSize)size frame: (CGRect)frame radius:(float)radius;



+ (DropMenu *)initDropMenuAndAdd:(id)controller;
+ (DropMenu *)initDropMenu:(id)controller;
+ (void)addDropMenu:(DropMenu*)theMenu controller:(id)controller;

+ (BOOL)isUseFahrenheit;
+ (void)setUseFahrenheit:(BOOL)value;
+ (BOOL)isMetric;
+ (void)setUseMetric:(BOOL)value;

+ (BOOL)isAlertsEnabled;
+ (void)setAlertsEnabled:(BOOL)value;

+ (void)saveInstallationUser;

+ (void)logOut: (UIViewController* _Nonnull) controller;

+ (BOOL)isEmpty: (id _Nullable) thing;

+ (void)supportEmail;

+ (void)updateUserFromFacebook;
+ (void)updateUserFromFacebook:(void (^)(BOOL))callback;
+ (void)onSuccessfulLogin: (BOOL)newUser controller: (UIViewController *)context;

+ (void)onUserSet;
+ (void)onUserSet:(BOOL)sync;
+ (void)syncStuff;


+ (UIViewController *)initStoryboard: (NSString*)storyboard;
+ (void)loadStoryboard: (id)context storyboard:(NSString*)storyboard;
+ (void)loadStoryboard: (id)context storyboard:(NSString*)storyboard animated:(BOOL)animated;
+ (void)dismissStoryboard: (id)context;
+ (void)dismissStoryboard: (id)context animated:(BOOL)animated;

+ (void)startAddNewDevice: (id _Nonnull )context;


+ (void) on: (NSString * _Nonnull)event notify: (EventEmitterNotifyCallback)callback;
+ (void) on: (NSString * _Nonnull)event callback: (EventEmitterDefaultCallback)callback;
+ (void) emit: (NSString * _Nonnull)event;
+ (void) emit: (NSString * _Nonnull)event data: (_Nonnull id) arg0;

+ (void)startNetworkActivity;
+ (void)stopNetworkActivity;


+ (BOOL)isProUser;
+ (float)getAveragePricePerWeight:(int)days object:(NSString * _Nullable)objectId device:(NSString* _Nullable)deviceId;
+ (float)getAverageLossPercentage:(int)days object:(NSString * _Nullable)objectId device:(NSString* _Nullable)deviceId;
+ (float)getAverageActualLossPercentage:(int)days object:(NSString * _Nullable)objectId device:(NSString* _Nullable)deviceId;
+ (float)getAverageServingSize:(int)days object:(NSString * _Nullable)objectId device:(NSString* _Nullable)deviceId;
+ (float)getAverageCostPercentage:(int)days object:(NSString * _Nullable)objectId device:(NSString* _Nullable)deviceId;
+ (float)getAverageSalePrice:(int)days object:(NSString * _Nullable)objectId device:(NSString* _Nullable)deviceId;
+ (float)getAverageNetServingCost:(int)days object:(NSString * _Nullable)objectId device:(NSString* _Nullable)deviceId;

+ (NSMutableArray * _Nonnull)getAveragePricePerWeightValues:(int)days object:(NSString * _Nullable)objectId device:(NSString* _Nullable)deviceId;
+ (NSMutableArray * _Nonnull)getAverageLossPercentageValues:(int)days object:(NSString * _Nullable)objectId device:(NSString* _Nullable)deviceId;
+ (NSMutableArray * _Nonnull)getAverageActualLossPercentageValues:(int)days object:(NSString * _Nullable)objectId device:(NSString* _Nullable)deviceId;
+ (NSMutableArray * _Nonnull)getAverageServingSizeValues:(int)days object:(NSString * _Nullable)objectId device:(NSString* _Nullable)deviceId;
+ (NSMutableArray * _Nonnull)getAverageCostPercentageValues:(int)days object:(NSString * _Nullable)objectId device:(NSString* _Nullable)deviceId;
+ (NSMutableArray * _Nonnull)getAverageSalePriceValues:(int)days object:(NSString * _Nullable)objectId device:(NSString* _Nullable)deviceId;
+ (NSMutableArray * _Nonnull)getAverageNetServingCostValues:(int)days object:(NSString * _Nullable)objectId device:(NSString* _Nullable)deviceId;

+ (NSString* _Nonnull)getPhoneId;

+ (void)openWifiSettings;
+ (ELADevice * _Nonnull)getElaDevice;
+ (ELADevice *)resetElaDevice;
+ (NSString * _Nullable)getWifiSSID;
+ (NSString * _Nullable)currentWifiBSSID;
+ (BOOL)hasInternet;

+ (NSString *_Nullable) getLastUpdated;
+ (void) setLastUpdated: (NSDate * _Nonnull) timeStamp;
+ (BOOL) showConnectionWarning;
+ (BOOL) showTempWarning;
+ (BOOL) showHumidityWarning;

@end;


#endif
