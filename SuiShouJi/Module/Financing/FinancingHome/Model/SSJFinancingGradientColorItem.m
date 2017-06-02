//
//  SSJFinancingGradientColorItem.m
//  SuiShouJi
//
//  Created by ricky on 2017/3/1.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFinancingGradientColorItem.h"

@implementation SSJFinancingGradientColorItem

- (BOOL)isEqual:(id)other
{
    if (self == other) {
        return YES;
    }
    
    SSJFinancingGradientColorItem *item = (SSJFinancingGradientColorItem *)other;
    if ([self.startColor isEqualToString:item.startColor] && [self.endColor isEqualToString:item.endColor]) {
        return YES;
    }
    
    return NO;
}

+ (NSArray *)defualtColors {
    NSArray *startColors = @[@"#fc6eac",@"#f96566",@"#7c91f8",@"#7fb4f1",@"#39d4da",@"#55d696",@"#f9b656",@"#fc8258",@"#bfaa37",@"#8d79ff",@"#c260e3",@"#4ea2ff"];
    NSArray *endColors = @[@"#fb92bd",@"#ff8989",@"#9fb0fc",@"#8ddcf0",@"#7fe8e0",@"#9be2a1",@"#f7cf70",@"#feb473",@"#e8d785",@"#afabff",@"#e8a8fe",@"#84befd"];
    
    NSMutableArray *colorArray = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < startColors.count; i ++) {
        SSJFinancingGradientColorItem *item = [[SSJFinancingGradientColorItem alloc] init];
        item.startColor = [startColors objectAtIndex:i];
        item.endColor = [endColors objectAtIndex:i];
        item.isSelected = NO;
        [colorArray addObject:item];
    }
    
    return colorArray;
}

@end
