//
//  SSJForgotPSWSendVerCodeService.m
//  YYDB
//
//  Created by cdd on 15/10/29.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJForgotPSWSendVerCodeService.h"

@implementation SSJForgotPSWSendVerCodeService

//- (void)request:(NSString *)url params:(id)params {
//    NSMutableDictionary *paramsDic = [params mutableCopy];
//    if ([[params allKeys] containsObject:@"mobileNo"]) {
//        NSString *mobileNo = [params objectForKey:@"mobileNo"];
//        NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
//        NSString *key = [NSString stringWithFormat:@"mobileNo=%@&timestamp=%f&key=%@",mobileNo,timestamp,SSJ_PIE_KEY];
//        NSString *md5Key=[[SSJUtilities md5HexDigest:key] uppercaseString];
//        
//        [paramsDic setObject:@(timestamp) forKey:@"timestamp"];
//        [paramsDic setObject:md5Key forKey:@"signMsg"];
//    }
//    [super request:url params:paramsDic];
//}

- (void)loadForgotPSWSendVerCodeWithParams:(NSDictionary *)params showIndicator:(BOOL)show{
    self.showLodingIndicator=show;
    [self request:SSJURLWithAPI(@"/user/forgetpwd.go") params:params];
}

- (void)handleResult:(NSDictionary *)rootElement{
    [super handleResult:rootElement];
    if ([self.returnCode isEqualToString:@"1"]) {
        
    }
}

@end
