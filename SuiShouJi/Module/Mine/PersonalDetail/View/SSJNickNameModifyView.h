//
//  SSJNickNameModifyView.h
//  SuiShouJi
//
//  Created by ricky on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJNickNameModifyView : UIControl<UITextViewDelegate>

@property(nonatomic, strong) NSString *originalText;

- (instancetype)initWithFrame:(CGRect)frame maxTextLength:(int)maxTextLength title:(NSString *)title;

typedef void (^comfirmButtonClickedBlock)(NSString *textInputed);

@property(nonatomic,copy) comfirmButtonClickedBlock comfirmButtonClickedBlock;

typedef void (^typeErrorBlock)(NSString *errorDesc);

@property(nonatomic,copy) typeErrorBlock typeErrorBlock;

- (void)show;

- (void)dismiss;

@end
