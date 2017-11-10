//
//  ELADevice.m
//  ELA
//
//  Created by Jared Ashlock on 4/30/17.
//  Copyright © 2017 ELA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCNetworkReachability.h"
@import SystemConfiguration.CaptiveNetwork;
#import "ELADevice.h"
#import "ELA.h"
#import "UNIRest.h"
#import "FastSocket.h"


#define ENABLE_BACKGROUNDING 1

#define TAG_READ_SETTINGS 10
#define TAG_API_CONNECT   11
#define TAG_NORMAL_MODE   12
#define TAG_SAVE_SETTINGS 20


@implementation ELADevice

- (dispatch_queue_t)getAsyncQueue {
    
    if (self.dispatch == Nil) {
        self.dispatch = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return self.dispatch;
}

- (BOOL)isConnectedToDeviceWifi
{
    NSString *ssid = [ELA getWifiSSID];
    
    if (ssid != Nil && ([ssid isEqualToString: [ELA getDeviceWifiName]] || [ssid isEqualToString:@"🐮 Steak Locker JARED"])) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isConnectedToDeviceSocket
{
    return YES;
    //return self.socket != Nil && [self.socket isConnected];
}

- (BOOL)needToReadSettings
{
    return (self.ssid == nil || self.pass == nil || self.uniqueId == nil) ? YES : NO;
}


- (nullable id)parseJsonResonse: (NSData *)data
{
    NSString * jsonStr = [[NSString stringWithUTF8String:[data bytes]] stringByReplacingOccurrencesOfString:@"\r\n"
                                                                                                 withString:@""];
    return [self parseJsonStringResponse:jsonStr];
}

- (nullable id)parseJsonStringResponse: (NSString *)jsonStr
{
    NSDictionary *json;
    NSData * jsonData;
    NSError *error;
    if (jsonStr != nil) {
        NSRange range = [jsonStr rangeOfString:@"}}"];
        if (range.location != NSNotFound) {
            jsonStr = [jsonStr substringToIndex:range.location+2];
        }
        
        jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\"read-data\"\"data\""
                                                     withString:@"\"read-data\",\"data\""];
        jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\"\"mac-address" withString:@"\",\"mac-address"];
        
        jsonData = (jsonStr != Nil) ? [jsonStr dataUsingEncoding:NSUTF8StringEncoding] : Nil;
        json = (jsonData != nil) ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    }
    
    return json;
}



- (void) updateSettingsFromDevice: (NSDictionary *)json
{
    if (json != nil && [json isKindOfClass:[NSDictionary class]]) {
        NSDictionary *settings = [json objectForKey:@"data"];
        if (settings != nil) {
            self.ssid = [settings objectForKey:@"ssid"];
            self.pass = [settings objectForKey:@"password"];
            
            NSString *id = [settings objectForKey:@"unique-id"];
            if (id != nil) {
                self.uniqueId = id;
            }
            self.fwVersion = [settings objectForKey:@"fw-version"];
            self.appId = [settings objectForKey:@"application-id"];
            self.interval = [settings objectForKey:@"interval"];
        }
    }
}

- (FastSocket *)fastSocketConnect
{
    NSString *host = @"192.168.1.1";
    NSString *port = @"80";
    FastSocket *client = [[FastSocket alloc] initWithHost: host andPort: port];
    return ([client connect]) ? client : nil;
}

- (long)socketSendString: (NSString*)json withSocket: (FastSocket *)socket
{
    NSMutableData * data = [[json dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    
    return [socket sendBytes:[data bytes] count:[data length]];
}

- (NSDictionary*)socketReceive: (FastSocket *)socket andClose: (BOOL)close
{
    long maxLength = 2000;
    char bytes[maxLength];
    long receivedBytes = [socket receiveBytes:bytes limit:maxLength];
    NSString *received = [[NSString alloc] initWithBytes:bytes length:receivedBytes encoding:NSUTF8StringEncoding];
    
    if (close) {
        [socket close];
    }
    
    return (receivedBytes && received != nil) ? (NSDictionary *)[self parseJsonStringResponse:received] : nil;
}


- (void)readSettings
{
    dispatch_async([self getAsyncQueue], ^{
        FastSocket *socket = [self fastSocketConnect];
        if (socket) {
            NSString * json = @"{\"request\":\"read-data\",\"data\":{\"request-field\":\"all\"}}";
            
            long bytesSent = [self socketSendString:json withSocket:socket];
            
            NSDictionary *result = [self socketReceive:socket andClose:YES];
            

            [self updateSettingsFromDevice: result];
            
            [ELA emit: @"settingsRead"];
        }
    });

                   }
- (void)saveSettings
{
    dispatch_async([self getAsyncQueue], ^{
        FastSocket *socket = [self fastSocketConnect];
        if (socket) {
            NSString * json = [NSString stringWithFormat: @"{\"request\":\"save-data\",\"data\":{\"ssid\":\"%@\",\"password\":\"%@\",\"application-id\":\"MEhfCXacMGU4wU9R7GNImyxP8766VJwCpnvE4ctI\",\"post-address\":\"http://steaklocker.herokuapp.com/parse/classes/Measurement\"}}", self.ssid, self.pass];
            
            
            long bytesSent = [self socketSendString:json withSocket:socket];
            NSDictionary *result = [self socketReceive:socket andClose:YES];
            
            [ELA emit:@"settingsSaved"];
        }
    });
}

- (void)apiConnect
{
    dispatch_async([self getAsyncQueue], ^{
        FastSocket *socket = [self fastSocketConnect];
        if (socket) {
            PFUser * user = [PFUser currentUser];
            
            NSString *url = [NSString stringWithFormat:@"http://steaklocker.herokuapp.com/device/connect/%@/%@/%@/%@",
                             [ELA getLockerType], user.objectId, self.uniqueId, self.model];
            
            NSString *json = [NSString stringWithFormat: @"{\"request\":\"api-connect\",\"data\":{\"nonce\":\"%@\",\"url\":\"%@\"}}", self.uniqueId, url];
            
            
            long bytesSent = [self socketSendString:json withSocket:socket];
            NSDictionary *result = [self socketReceive:socket andClose:NO];
            
            [ELA emit:@"apiConnected"];
        }
    });
}

- (void) initStatusCheck
{
    dispatch_async(dispatch_get_main_queue(), ^{
    if (self.timer == nil || ![self.timer isValid]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(checkDeviceStatus:) userInfo: nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        
         self.timeout = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timeout:) userInfo: nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.timeout forMode:NSRunLoopCommonModes];
    }
    });
}

- (void) cancelStatusCheck
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    if (self.timeout) {
        [self.timeout invalidate];
        self.timeout = nil;
    }
}

- (void) checkDeviceStatus: (NSTimer *)timer
{
    NSLog(@"Check Device Status");
    
    if (!self.connected) {
        NSLog(@"Not connected, making status call");
        [self makeStatusCall];
    }
    else {
        NSLog(@"Connected, stop timer");
        if (self.timer != nil) {
            [self.timer invalidate];
        }
        self.timer = nil;
    }
}

- (void) timeout: (NSTimer *)timer
{
    if (!self.connected) {
        [ELA emit:@"deviceConnectionTimeout"];
    }
}

- (NSString *)getStatusUrl
{
    PFUser * user = [PFUser currentUser];
    
    return [NSString stringWithFormat:@"https://steaklocker.herokuapp.com/device/status/%@/%@/%@",
                     [ELA getLockerType], user.objectId, self.uniqueId];
}

- (void) makeStatusCall
{
    NSDictionary *headers = @{@"accept": @"application/json"};
    
    [[UNIRest post:^(UNISimpleRequest *request) {
        [request setUrl: [self getStatusUrl]];
        [request setHeaders:headers];
    }] asJsonAsync:^(UNIHTTPJsonResponse* response, NSError *error) {
        if (error == nil) {
            UNIJsonNode *body = response.body;
            NSNumber *num = [body.object objectForKey:@"status"];
            long status = (num != nil) ? [num longValue] : 0;
            
            if (status > 0) {
                self.connected = true;
                [self cancelStatusCheck];
                [ELA emit:@"deviceConnected"];
            }
        }
        else {
            NSLog(@"UNIRest Error: %@", error);
        }
    }];

}
@end
