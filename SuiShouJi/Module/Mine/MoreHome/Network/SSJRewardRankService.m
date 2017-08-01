//
//  SSJRewardRankService.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/31.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRewardRankService.h"

#import "SSJRankListItem.h"

@implementation SSJRewardRankService

- (void)payWithMethod:(SSJMethodOfPayment)payMethod payMoney:(nonnull NSString *)money memo:(NSString * _Nullable)memo {
    NSMutableDictionary *parmDic = [NSMutableDictionary dictionary];
    if (payMethod == SSJMethodOfPaymentAlipay) {
        [parmDic setObject:@"2" forKey:@"payType"];
    } else if (payMethod == SSJMethodOfPaymentWeChat) {
        [parmDic setObject:@"1" forKey:@"payType"];
    }
    NSString *imei = [UIDevice currentDevice].identifierForVendor.UUIDString;
    [parmDic setObject:@"2" forKey:@"mobileType"];//	手机类型 （1安卓； 2 IOS； 3其他）
    
    [parmDic setObject:@([money doubleValue] * 100) forKey:@"payMoney"];
    [parmDic setObject:memo.length ? memo :@"" forKey:@"memo"];
    [parmDic setObject:imei forKey:@"cimei"];
    [parmDic setObject:SSJPhoneModel() forKey:@"cmodel"];
    [parmDic setObject:[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"] forKey:@"cwriteDate"];
    [self request:SSJURLWithAPI(@"/chargebook/pay/reward.go") params:parmDic];
}

- (void)resultOfPayWithTradeNo:(NSString *)tradeNo {
    NSMutableDictionary *parmDic = [NSMutableDictionary dictionary];
    [parmDic setObject:tradeNo forKey:@"tradeNo"];
    [self request:SSJURLWithAPI(@"/chargebook/pay/query_payResult.go") params:parmDic];
}

- (void)requestRankList {
    self.showLodingIndicator = NO;
    [self request:SSJURLWithAPI(@"/chargebook/pay/pay_record.go") params:nil];
}

- (void)handleResult:(NSDictionary *)rootElement {
    [super handleResult:rootElement];
    if (![self.returnCode isEqualToString:@"1"]) return;
    NSDictionary *selfPayRecord = [[rootElement objectForKey:@"results"] objectForKey:@"selfPayRecord"];
    self.selfRankItem = [SSJRankListItem mj_objectWithKeyValues:selfPayRecord];
    NSArray *payRecordArr = [[rootElement objectForKey:@"results"] objectForKey:@"payRecords"];
    self.payRecords = [SSJRankListItem mj_objectArrayWithKeyValuesArray:payRecordArr];
    if (selfPayRecord.count && selfPayRecord) {
        self.listArray = @[@[self.selfRankItem],self.payRecords];
    } else if(payRecordArr && !selfPayRecord.count && payRecordArr.count){
        self.listArray = @[self.payRecords];
    }
    
    _payUrl = [[rootElement objectForKey:@"results"] objectForKey:@"payUrl"];
    _tradeNo = [[rootElement objectForKey:@"results"] objectForKey:@"tradeNo"];
    
    //支付结果状态（1支付成功； 0 未支付）
    _payResultStatus = [[rootElement objectForKey:@"results"] objectForKey:@"status"];
}
@end
