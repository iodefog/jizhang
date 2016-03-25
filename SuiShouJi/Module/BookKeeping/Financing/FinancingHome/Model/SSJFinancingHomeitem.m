//
//  SSJFinancingHomeitem.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFinancingHomeitem.h"

@implementation SSJFinancingHomeitem

-(BOOL)isEqual:(id)object{
    if (![object isKindOfClass:[SSJFinancingHomeitem class]]) {
        return NO;
    }else{
        SSJFinancingHomeitem *anotherItem = (SSJFinancingHomeitem*)object;
        if ([anotherItem.fundingID isEqualToString:self.fundingID] && [anotherItem.fundingIcon isEqualToString:self.fundingIcon] && [anotherItem.fundingMemo isEqualToString:self.fundingMemo] && [anotherItem.fundingName isEqualToString:self.fundingName] && [anotherItem.fundingColor isEqualToString:self.fundingColor] && anotherItem.fundingAmount == self.fundingAmount && [anotherItem.fundingParent isEqualToString:self.fundingParent]) {
            return YES;
        }
    }
    return NO;
}

@end
