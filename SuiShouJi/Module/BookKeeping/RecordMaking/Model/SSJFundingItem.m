//
//  SSJFundingItem.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingItem.h"

@implementation SSJFundingItem

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.fundingID forKey:@"fundingID"];
    [aCoder encodeObject:self.fundingName forKey:@"fundingName"];
    [aCoder encodeObject:self.fundingColor forKey:@"fundingColor"];
    [aCoder encodeObject:self.fundingIcon forKey:@"fundingIcon"];
    [aCoder encodeObject:self.fundingParent forKey:@"fundingParent"];
    [aCoder encodeDouble:self.fundingBalance forKey:@"fundingBalance"];
    [aCoder encodeObject:self.fundingMemo forKey:@"fundingMemo"];

}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.fundingID = [aDecoder decodeObjectForKey:@"fundingID"];
        self.fundingName = [aDecoder decodeObjectForKey:@"fundingName"];
        self.fundingColor = [aDecoder decodeObjectForKey:@"fundingColor"];
        self.fundingIcon = [aDecoder decodeObjectForKey:@"fundingIcon"];
        self.fundingParent = [aDecoder decodeObjectForKey:@"fundingParent"];
        self.fundingBalance = [aDecoder decodeDoubleForKey:@"fundingBalance"];
        self.fundingMemo = [aDecoder decodeObjectForKey:@"fundingMemo"];
    }
    return self;
}
@end
