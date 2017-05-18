//
//  SSJBaseCellItem.m
//  MoneyMore
//
//  Created by old lang on 15-3-23.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@implementation SSJBaseCellItem

// 用MJExtension转成字典忽略这几个属性
+ (NSArray *)mj_ignoredPropertyNames {
    return @[@"rowHeight",
             @"separatorInsets",
             @"selectionStyle"];
}

- (instancetype)init {
    if (self = [super init]) {
        self.rowHeight = 54;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    SSJBaseCellItem *item = [[SSJBaseCellItem alloc] init];
    item.rowHeight = self.rowHeight;
    item.separatorInsets = self.separatorInsets;
    item.selectionStyle = self.selectionStyle;
    return item;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    SSJPRINT(@"<<< 警告：设置未定义的属性：%@ >>>",key);
}

- (NSString *)debugDescription {
    return [self ssj_debugDescription];
}

@end
