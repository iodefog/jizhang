//
//  SSJMakeWishDefoDataService.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJMakeWishDefoDataService.h"

#import "SSJWishDefItem.h"

@implementation SSJMakeWishDefoDataService
- (void)requestDefoWish {
    [self request:SSJURLWithAPI(@"/chargebook/account/query_wishType.go") params:nil];
}

- (void)handleResult:(NSDictionary *)rootElement {
    NSArray *wishTypesArr = [[rootElement objectForKey:@"results"] objectForKey:@"wishTypes"];
    NSMutableArray *tempArr = [NSMutableArray array];
    for (NSDictionary *dic in wishTypesArr) {
        SSJWishDefItem *item = [[SSJWishDefItem alloc] init];
        item.wishType = [[dic objectForKey:@"typeid"] integerValue];
        item.wishName = [dic objectForKey:@"typename"];
        item.wishMoney = [dic objectForKey:@"money"];
        item.wishCount = [dic objectForKey:@"count"];
        [tempArr addObject:item];
    }
    self.wishDefoArray = tempArr;
}

- (NSMutableArray *)wishDefoArray {
    if (!_wishDefoArray) {
        _wishDefoArray = [NSMutableArray array];
    }
    return _wishDefoArray;
}

@end
