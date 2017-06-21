
//
//  SSJClearUserDataService.m
//  SuiShouJi
//
//  Created by ricky on 16/7/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJClearUserDataService.h"

@interface SSJClearUserDataService()

@property (nonatomic, copy) void(^successBlock)();

@property (nonatomic, copy) void(^failBlock)();

@end

@implementation SSJClearUserDataService

- (void)clearUserDataWithOriginalUserid:(NSString *)originalUserid
                              newUserid:(NSString *)newUserid
                                Success:(void(^)())success
                                failure:(void (^)(NSError *error))failure{
    self.showLodingIndicator = NO;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:originalUserid forKey:@"oldUserId"];
    [dic setObject:newUserid forKey:@"cuserId"];
    [self request:SSJURLWithAPI(@"/user/initUserData.go") params:dic];
    self.successBlock = success;
    self.failBlock = failure;
}

- (void)handleResult:(NSDictionary *)rootElement{
    [super handleResult:rootElement];
    SSJPRINT(@"%@",self.desc);
    if ([self.returnCode isEqualToString:@"1"]
        || [self.returnCode isEqualToString:@"-5555"]) {
        if (self.successBlock) {
            self.successBlock();
        }
    }else{
        if (self.failBlock) {
            self.failBlock();
        }
    }
}

- (void)server:(SSJBaseNetworkService *)service didFailLoadWithError:(NSError *)error{
    if (self.failBlock) {
        self.failBlock();
    }
}

@end
