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
    if (selfPayRecord.count) {
        self.listArray = @[@[self.selfRankItem],self.payRecords];
    } else {
        self.listArray = @[self.payRecords];
    }
    
    
}
@end
