//
//  SSJMakeWishDefoDataService.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"
@class SSJWishDefItem;

@interface SSJMakeWishDefoDataService : SSJBaseNetworkService

@property (nonatomic, strong) NSMutableArray *wishDefoArray;

- (void)requestDefoWish;
@end
