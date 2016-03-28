//
//  SJJBookKeepingHeader.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/14.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJBookKeepingHeader : UIView

typedef void(^BtnClickBlock)();

@property (nonatomic, copy) BtnClickBlock BtnClickBlock;

//本月支出
@property(nonatomic,strong)NSString *expenditure;

//本月收入
@property(nonatomic,strong)NSString *income;


//当前月份
@property (nonatomic)long currentMonth;

+ (id)BookKeepingHeader;

+ (CGFloat)viewHeight;
@end
