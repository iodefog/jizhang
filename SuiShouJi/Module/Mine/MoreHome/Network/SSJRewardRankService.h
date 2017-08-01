//
//  SSJRewardRankService.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/31.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"
@class SSJRankListItem;
NS_ASSUME_NONNULL_BEGIN
@interface SSJRewardRankService : SSJBaseNetworkService

@property (nonatomic, strong) SSJRankListItem *selfRankItem;

/**<#注释#>*/
@property (nonatomic, strong) NSArray<SSJRankListItem *> *payRecords;

/**二维码支付链接*/
@property (nonatomic, copy, readonly) NSString *payUrl;

/**	订单号*/
@property (nonatomic, copy, readonly) NSString *tradeNo;

/**<#注释#>*/
@property (nonatomic, strong) NSArray *listArray;

/**支付结果状态*/
@property (nonatomic, strong, readonly) NSString *payResultStatus;


/**
 请求支付

 @param payMethod 支付方式 1微信WAP支付； 2支付宝扫码支付）
 */
- (void)payWithMethod:(SSJMethodOfPayment)payMethod payMoney:(NSString *)money memo:( NSString * _Nullable )memo;


/**
 查询支付结果

 @param tradeNo 根据订单号查询e
 支付结果状态（1支付成功； 0 未支付）
 */
- (void)resultOfPayWithTradeNo:(NSString *)tradeNo;

/**
 打赏列表
 */
- (void)requestRankList;


@end
NS_ASSUME_NONNULL_END
