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

@end
