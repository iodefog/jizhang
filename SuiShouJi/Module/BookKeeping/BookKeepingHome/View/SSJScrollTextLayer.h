//
//  SSJScrollTextLayer.h
//  SuiShouJi
//
//  Created by ricky on 16/4/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface SSJScrollTextLayer : CATextLayer
//显示的数字
@property(nonatomic, strong) NSString *numStr;

//滚动的时间
@property(nonatomic) float animationDuration;

//字体大小
@property(nonatomic) int textFont;

//字体颜色
@property(nonatomic, strong) UIColor *textColor;

@end
