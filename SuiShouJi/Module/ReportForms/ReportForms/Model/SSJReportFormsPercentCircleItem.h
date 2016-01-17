//
//  SSJReportFormsPercentCircleItem.h
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJReportFormsPercentCircleItem : NSObject

//  圆环组件比例值，在0～1之间
@property (nonatomic) double scale;

//  圆环组件颜色
@property (nonatomic, copy) NSString *colorValue;

//  圆环组件图片
@property (nonatomic, copy) NSString *imageName;

//  附加文本
@property (nonatomic, copy) NSString *additionalText;

//  之前所有圆环组件的比例值总和，用于SSJReportFormsPercentCircle内部计算角度使用
//  不需要在函数percentCircle:itemForComponentAtIndex:中返回
@property (nonatomic) double previousScale;

@end
