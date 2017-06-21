//
//  SSJForgotPSWCheckVerCodeService.m
//  YYDB
//
//  Created by cdd on 15/10/29.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJForgotPSWCheckVerCodeService.h"

@implementation SSJForgotPSWCheckVerCodeService

- (void)loadForgotPSWCheckVerCodeWithParams:(NSDictionary *)params ShowIndicator:(BOOL)show{
    self.showLodingIndicator=show;
    [self request:SSJURLWithAPI(@"/user/forgetpwdyz.go") params:params];
}

- (void)handleResult:(NSDictionary *)rootElement{
    [super handleResult:rootElement];
    if ([self.returnCode isEqualToString:@"1"]) {
        
    }
}

@end
