//
//  SSJPatchUpdateService.h
//  SuiShouJi
//
//  Created by ricky on 16/5/20.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"
#import "SSJJsPatchItem.h"

@interface SSJPatchUpdateService : SSJBaseNetworkService

/**
 *  请求补丁列表
 *
 *  @param version 当前客户端版本号
 */
- (void)requestPatchWithCurrentVersion:(NSString *)version;

@property(nonatomic, strong) SSJJsPatchItem *patchItem;

@end
