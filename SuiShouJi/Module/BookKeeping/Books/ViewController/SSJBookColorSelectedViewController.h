//
//  SSJBookColorSelectedViewController.h
//  SuiShouJi
//
//  Created by yi cai on 2017/5/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
@class SSJFinancingGradientColorItem;

@interface SSJBookColorSelectedViewController : SSJBaseViewController
//账本名称
@property (nonatomic,strong) NSString *bookName;

//账本颜色
@property (nonatomic,strong) SSJFinancingGradientColorItem *bookColorItem;

@property(nonatomic,copy) void (^colorSelectedBlock)(SSJFinancingGradientColorItem *selectColor);
@end
