
//
//  SSJFundingDetailListItem.m
//  SuiShouJi
//
//  Created by ricky on 16/3/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingDetailListItem.h"

@implementation SSJFundingDetailListItem
- (NSString *)debugDescription {
    return [self ssj_debugDescription];
}
-(BOOL)isEqual:(id)object{
    SSJFundingDetailListItem *anotherItem = (SSJFundingDetailListItem*)object;
    
    if ([anotherItem isKindOfClass:[SSJFundingDetailListItem class]]
        && ([anotherItem.date isEqualToString:self.date] || anotherItem.date == self.date)
        && (anotherItem.income == self.income)
        && (anotherItem.expenture == self.expenture)
        && ([anotherItem.chargeArray isEqualToArray:self.chargeArray] || anotherItem.chargeArray == self.chargeArray)) {
        return YES;
    }
    
    return [super isEqual:object];
}
@end
