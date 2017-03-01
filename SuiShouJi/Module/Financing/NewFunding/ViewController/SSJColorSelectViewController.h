//
//  SSJColorSelectViewControllerViewController.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "SSJFinancingGradientColorItem.h"

@interface SSJColorSelectViewController : SSJBaseViewController<UICollectionViewDataSource,UICollectionViewDelegate>

//资金账户余额
@property (nonatomic) double fundingAmount;

//资金账户名称
@property (nonatomic,strong) NSString *fundingName;

//资金账户颜色
@property (nonatomic,strong) SSJFinancingGradientColorItem *fundingColor;


typedef void (^colorSelectedBlock)(SSJFinancingGradientColorItem *selectColor);

@property(nonatomic,copy) colorSelectedBlock colorSelectedBlock;

@end
