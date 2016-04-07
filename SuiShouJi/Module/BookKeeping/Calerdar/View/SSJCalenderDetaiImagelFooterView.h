//
//  SSJCalenderDetaiImagelFooterView.h
//  SuiShouJi
//
//  Created by ricky on 16/4/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJCalenderDetaiImagelFooterView : UIView
//点击修改记录按钮回调
typedef void (^ModifyButtonClickedBlock)();

@property (nonatomic, copy) ModifyButtonClickedBlock ModifyButtonClickedBlock;

@property(nonatomic, strong) NSString *imageName;
@end
