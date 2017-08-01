//
//  SSJRewardRankService.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/31.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"
@class SSJRankListItem;

@interface SSJRewardRankService : SSJBaseNetworkService

@property (nonatomic, strong) SSJRankListItem *selfRankItem;

/**<#注释#>*/
@property (nonatomic, strong) NSArray<SSJRankListItem *> *payRecords;
//mj_objectWithKeyValues

/**<#注释#>*/
@property (nonatomic, strong) NSArray *listArray;

- (void)requestRankList;

@end
