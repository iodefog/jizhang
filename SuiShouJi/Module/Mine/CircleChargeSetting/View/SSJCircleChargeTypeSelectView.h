//
//  SSJCircleChargeTypeSelectView.h
//  SuiShouJi
//
//  Created by ricky on 16/6/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJCircleChargeTypeSelectView : UIControl<UITableViewDelegate,UITableViewDataSource>

typedef void (^chargeTypeSelectBlock)(SSJBillType selectType);

@property(nonatomic) SSJBillType selectIndex;

//选择类型的回调
@property (nonatomic, copy) chargeTypeSelectBlock chargeTypeSelectBlock;

- (void)show;

- (void)dismiss;


@end
