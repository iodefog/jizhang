//
//  SSJBookKeepingRiminderCircleView.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJBookKeepingRiminderCircleView : UIView<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSString *selectWeekStr;

//选择周期回调
typedef void (^circleSelectBlock)(NSString *dateNumString , NSString *dateString);

@property (nonatomic, copy) circleSelectBlock circleSelectBlock;

@end
