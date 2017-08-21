//
//  SSJFinancingHomeitem.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFinancingHomeitem.h"

@implementation SSJFinancingHomeitem

@synthesize fundingName;
@synthesize fundingColor;
@synthesize fundingID;
@synthesize fundingIcon;
@synthesize fundingParent;

-(BOOL)isEqual:(id)object{
    SSJFinancingHomeitem *anotherItem = (SSJFinancingHomeitem*)object;
    
    if ([anotherItem isKindOfClass:[SSJFinancingHomeitem class]]
        && ([anotherItem.fundingID isEqualToString:self.fundingID] || anotherItem.fundingID == self.fundingID)
        && ([anotherItem.fundingIcon isEqualToString:self.fundingIcon] || anotherItem.fundingIcon == self.fundingIcon)
        && ([anotherItem.fundingMemo isEqualToString:self.fundingMemo] || anotherItem.fundingMemo == self.fundingMemo)
        && ([anotherItem.fundingName isEqualToString:self.fundingName] || anotherItem.fundingName == self.fundingName)
        && ([anotherItem.fundingColor isEqualToString:self.fundingColor] || anotherItem.fundingColor == self.fundingColor)
        && ([anotherItem.fundingParent isEqualToString:self.fundingParent] || anotherItem.fundingParent == self.fundingParent)
        && anotherItem.fundingAmount == self.fundingAmount) {
        return YES;
    }
    
    return [super isEqual:object];
}

@end
