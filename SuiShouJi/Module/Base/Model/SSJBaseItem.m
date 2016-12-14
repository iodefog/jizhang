//
//  SSJBaseItem.m
//  MoneyMore
//
//  Created by old lang on 15-3-23.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@implementation SSJBaseItem

+ (instancetype)itemWithElement:(id)element {
    SSJBaseItem *item = [[SSJBaseItem alloc] initWithElement:element];
    return item;
}

- (instancetype)initWithElement:(id)element {
    if (self = [super init]) {
        [self parseElement:element];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return nil;
}

- (void)parseElement:(id)element {
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    SSJPRINT(@"<<< 警告：设置未定义的属性：%@ >>>",key);
}

- (CGFloat)rowHeight {
    return 54;
}

@end
