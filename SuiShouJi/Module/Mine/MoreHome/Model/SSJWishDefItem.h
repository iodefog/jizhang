//
//  SSJWishDefItem.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/20.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@interface SSJWishDefItem : SSJBaseCellItem

@property (nonatomic, assign) NSInteger wishType;

@property (nonatomic, copy) NSString *wishName;

@property (nonatomic, copy) NSString *wishMoney;

@property (nonatomic, copy) NSString *wishCount;

+ (NSMutableArray *)defWishItemArr;
@end
