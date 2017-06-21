//
//  SSJLoginVerifyPhoneNumViewModel.m
//  SuiShouJi
//
//  Created by yi cai on 2017/6/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJLoginVerifyPhoneNumViewModel.h"
#import "SSJBaseNetworkService.h"

#import "SSJStringAddition.h"
//#import "NSString+RACSequenceAdditions.h"
#import <ReactiveCocoa/NSString+RACSequenceAdditions.h>
@interface SSJLoginVerifyPhoneNumViewModel ()<SSJBaseNetworkServiceDelegate>
@end

@implementation SSJLoginVerifyPhoneNumViewModel
- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

#pragma mark - Private


#pragma mark - Lazy
- (SSJBaseNetworkService *)netWorkService {
    if (!_netWorkService) {
        _netWorkService = [[SSJBaseNetworkService alloc] init];
    }
    return _netWorkService;
}

- (RACCommand *)verifyPhoneNumRequestCommand {
    if (!_verifyPhoneNumRequestCommand) {
        
        _verifyPhoneNumRequestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            
            @weakify(self);
            RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
                [paramDic setObject:SSJUSERID() forKey:@"cuserId"];
                
//                [self.netWorkService request:@"/chargebook/user/check_cphoneExist.go" params:paramDic];
                [self.netWorkService request:@"/chargebook/user/check_cphoneExist.go" params:paramDic success:^(SSJBaseNetworkService * _Nonnull service) {
                    [subscriber sendNext:service.rootElement];
                    [subscriber sendCompleted];
                } failure:^(SSJBaseNetworkService * _Nonnull service) {
                    [CDAutoHideMessageHUD showMessage:service.description];
                }];
                
                return nil;
            }];
            //返回的数据处理json->model
            return [signal map:^id(id value) {
                return @"成功啦";
            }];
        }];
        
        //获得数据
        [_verifyPhoneNumRequestCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
            NSLog(@"新数据:::::%@",x);
        }];
    }
    return _verifyPhoneNumRequestCommand;
}

- (RACSignal *)enableVerifySignal {
    if (!_enableVerifySignal) {
        //手机号格式，位数，是否同意用户协议
        @weakify(self);
        _enableVerifySignal = [[RACSignal combineLatest:@[RACObserve(self, phoneNum)] reduce:^id(NSString *phoneNum){
            @strongify(self);
            return @(phoneNum.length == 11 && self.agreeProtocol);
            //[self.phoneNum ssj_validPhoneNum]
        }] skip:1];
    }
    return _enableVerifySignal;
}

@end
