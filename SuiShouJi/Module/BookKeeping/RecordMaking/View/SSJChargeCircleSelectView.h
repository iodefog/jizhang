//
//  SSJChargeCIrcleSelectVIew.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/2/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJChargeCircleSelectView : UIView<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic) NSInteger selectCircleType;

@property (nonatomic, copy, readonly) NSString *selectedPeriod;

@property (nonatomic) BOOL incomeOrExpenture;

//点击按钮的回调
typedef void (^chargeCircleSelectBlock)(NSInteger chargeCircleType);


@property(nonatomic, copy) chargeCircleSelectBlock chargeCircleSelectBlock;

@property (nonatomic, copy) void (^dismissBlock)();


- (void)show;

- (void)dismiss;

@end
