//
//  SSJColorSelectViewControllerViewController.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "SSJFinancingHomeitem.h"
#import "SSJFinancingGradientColorItem.h"

@interface SSJColorSelectViewController : SSJBaseViewController<UICollectionViewDataSource,UICollectionViewDelegate>


//资金账户model
@property (nonatomic,strong) SSJFinancingHomeitem *fundingItem;


typedef void (^colorSelectedBlock)(SSJFinancingGradientColorItem *selectColor);

@property(nonatomic,copy) colorSelectedBlock colorSelectedBlock;

@end
