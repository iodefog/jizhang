//
//  SSJStartNetworkService.m
//  SuiShouJi
//
//  Created by old lang on 16/2/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJStartNetworkService.h"

@interface SSJStartNetworkService ()

@property (readwrite, nonatomic, copy) NSString *content;
@property (readwrite, nonatomic, copy) NSString *appversion;
@property (readwrite, nonatomic, copy) NSString *url;
@property (readwrite, nonatomic, copy) NSString *type;
@property (readwrite, nonatomic, copy) NSString *remindMassage;
@property (readwrite, nonatomic, copy) NSString *startImage;
@property (readwrite, nonatomic) BOOL isInReview;

@end

@implementation SSJStartNetworkService

- (void)request {
    [super request:@"/trade/start.go" params:nil];
}

- (void)requestDidFinish:(NSDictionary *)rootElement {
    self.content = nil;
    self.appversion = nil;
    self.url = nil;
    self.type = nil;
    self.remindMassage = nil;
    
    NSDictionary *results = [rootElement objectForKey:@"results"];
    
    //  解析升级信息
    NSDictionary *appInfo = [results objectForKey:@"app"];
    if (appInfo) {
        self.content = [appInfo objectForKey:@"content"];
        self.appversion = [appInfo objectForKey:@"appversion"];
        self.url = [appInfo objectForKey:@"url"];
        self.type = [appInfo objectForKey:@"type"];
    }
    //  解析审核配置
    self.isInReview = [[results objectForKey:@"review"] boolValue];
    self.remindMassage = [results objectForKey:@"remind"];
    self.startImage = [results objectForKey:@"homeheaderbg"];
}

@end
