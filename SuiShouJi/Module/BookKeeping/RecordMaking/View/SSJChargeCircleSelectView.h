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

//点击按钮的回调
typedef void (^chargeCircleSelectBlock)(NSInteger chargeCircleType);


@property(nonatomic, copy) chargeCircleSelectBlock chargeCircleSelectBlock;

@end
