//
//  SSJWishDefItem.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/20.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishDefItem.h"

@implementation SSJWishDefItem


+ (NSMutableArray *)defWishItemArr {
    NSArray *titleArr = @[@"存下人生第一个 1 万",@"一场说走就走的旅行",@"为“ta”买礼物"];
    NSArray *moneyArr = @[@"10000",@"5000",@"2000"];
    
    NSMutableArray *defWishArr = [NSMutableArray array];
    for (NSInteger i = 0; i<titleArr.count; i++) {
        SSJWishDefItem *item = [[SSJWishDefItem alloc] init];
        item.wishName = [titleArr ssj_safeObjectAtIndex:i];
        item.wishMoney = [moneyArr ssj_safeObjectAtIndex:i];
        item.wishType = i + 1;
        [defWishArr addObject:item];
    }
    return defWishArr;
}
@end
