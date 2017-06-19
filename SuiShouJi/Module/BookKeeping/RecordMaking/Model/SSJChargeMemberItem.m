//
//  SSJChargeMemBerItem.m
//  SuiShouJi
//
//  Created by ricky on 16/7/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJChargeMemberItem.h"

@implementation SSJChargeMemberItem

-(BOOL)isEqual:(id)object{
    [super isEqual:object];
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[SSJChargeMemberItem class]]) {
        return NO;
    }
    
    SSJChargeMemberItem *memberItem = (SSJChargeMemberItem *)object;
    return [self.memberId isEqualToString:memberItem.memberId];
}

@end
