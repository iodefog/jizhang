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
@property (readonly , nonatomic, copy) NSString *qqgroup;

// qq加群id
@property (readonly , nonatomic, copy) NSString *qqgroupId;

// 微信群
@property (readonly , nonatomic, copy) NSString *wechatgroup;

// 微信公众号
@property (readonly , nonatomic, copy) NSString *wechatId;

// 新浪微博
@property (readonly , nonatomic, copy) NSString *sinaBlog;

// 客服电话
@property (readonly , nonatomic, copy) NSString *telNum;

// 新浪微博id
@property (readonly , nonatomic, copy) NSString *sinaWeiboId;

@property (nonatomic, strong) SSJAppUpdateModel *updateModel;

@end
