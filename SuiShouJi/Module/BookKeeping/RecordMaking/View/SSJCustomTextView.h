//
//  SSJCustomTextView.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/2/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//
//带placeholder的textView


#import <UIKit/UIKit.h>

@interface SSJCustomTextView : UITextView

@property(nonatomic,copy) NSString *placeholder;  //文字

@property(nonatomic,strong) UIColor *placeholderColor; //文字颜色
/**
 placeholder距离上边距的距离
 */
@property (nonatomic, assign) CGFloat placeholderTopConst;

/**
 placeholder距离左边距的距离
 */
@property (nonatomic, assign) CGFloat placeholderLeftConst;

/**背景颜色*/
@property (nonatomic, strong) UIColor *bgColor;
@end
