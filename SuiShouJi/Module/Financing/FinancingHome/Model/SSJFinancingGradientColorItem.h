//
//  SSJFinancingGradientColorItem.h
//  SuiShouJi
//
//  Created by ricky on 2017/3/1.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@interface SSJFinancingGradientColorItem : SSJBaseItem

@property(nonatomic, strong) NSString *startColor;

@property(nonatomic, strong) NSString *endColor;

@property(nonatomic) BOOL isSelected;

+ (NSArray <SSJFinancingGradientColorItem *> *)defualtColors;

@end
