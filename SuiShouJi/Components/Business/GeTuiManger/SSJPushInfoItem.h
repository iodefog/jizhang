//
//  SSJPushInfoItem.h
//  SuiShouJi
//
//  Created by ricky on 2017/3/8.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@interface SSJPushInfoItem : SSJBaseItem

@property(nonatomic, strong) NSString *pushId;

@property(nonatomic) NSInteger pushType;

@property(nonatomic, strong) NSString *pushTitle;

@property(nonatomic, strong) NSString *pushDesc;

@property(nonatomic, strong) NSString *pushTarget;

@end
