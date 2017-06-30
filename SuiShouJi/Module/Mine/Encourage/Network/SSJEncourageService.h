//
//  SSJEncourageService.h
//  SuiShouJi
//
//  Created by ricky on 2017/6/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"
#import "SSJAppUpdateModel.h"

@interface SSJEncourageService : SSJBaseNetworkService

- (void)request;

@property(nonatomic, strong) NSString *qqgroup;

@property(nonatomic, strong) NSString *qqgroupId;

@property(nonatomic, strong) NSString *wechatgroup;

@property(nonatomic, strong) NSString *wechatId;

@property(nonatomic, strong) NSString *sinaBlog;

@property(nonatomic, strong) NSString *telNum;

@property(nonatomic, strong) SSJAppUpdateModel *updateModel;

@end
