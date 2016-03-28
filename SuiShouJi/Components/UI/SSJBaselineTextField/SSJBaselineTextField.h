//
//  SSJBaselineTextField.h
//  SuiShouJi
//
//  Created by old lang on 16/1/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJBaselineTextField : UITextField

//  为选中时底线的颜色，默认是白色
@property (nonatomic, strong) UIColor *normalLineColor;

//  选中时底线的颜色，默认是白色
@property (nonatomic, strong) UIColor *highlightLineColor;

- (instancetype)initWithFrame:(CGRect)frame contentHeight:(CGFloat)height;

@end
