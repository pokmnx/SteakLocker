//
//  ELADevice.h
//  ELA
//
//  Created by Jared Ashlock on 4/30/17.
//  Copyright © 2017 ELA. All rights reserved.
//

#ifndef ELADevice_h
#define ELADevice_h


@interface ELADevice : NSObject

@property (nonatomic, strong) dispatch_queue_t dispatch;

@property (nonatomic) BOOL hasSettings;
@property (nonatomic, strong) NSString *ssid;
@property (nonatomic, strong) NSString *pass;
@property (nonatomic, strong) NSString *uniqueId;
@property (nonatomic, strong) NSString *fwVersion;
@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *interval;
@property (nonatomic, strong) NSString *model;
@property (nonatomic) BOOL connected;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *timeout;
- (void)initStatusCheck;
- (void)cancelStatusCheck;


- (BOOL)isConnectedToDeviceWifi;
- (BOOL)isConnectedToDeviceSocket;

- (BOOL)needToReadSettings;

- (void)readSettings;
- (void)saveSettings;
- (void)apiConnect;

@end

#endif /* ELADevice_h */
