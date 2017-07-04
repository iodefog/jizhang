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

- (void)requestWithSuccess:(SSJNetworkServiceHandler)success
                   failure:(SSJNetworkServiceHandler)failure;

// qq群
@property(nonatomic, strong) NSString *qqgroup;

// qq加群id
@property(nonatomic, strong) NSString *qqgroupId;

// 微信群
@property(nonatomic, strong) NSString *wechatgroup;

// 微信公众号
@property(nonatomic, strong) NSString *wechatId;

// 新浪微博
@property(nonatomic, strong) NSString *sinaBlog;

// 客服电话
@property(nonatomic, strong) NSString *telNum;

@property(nonatomic, strong) SSJAppUpdateModel *updateModel;

@end
