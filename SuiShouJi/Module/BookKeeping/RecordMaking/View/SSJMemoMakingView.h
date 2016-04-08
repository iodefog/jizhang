//
//  SSJMemoMakingView.h
//  SuiShouJi
//
//  Created by ricky on 16/4/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJMemoMakingView : UIView<UITextViewDelegate>

@property(nonatomic, strong) NSString *originalText;

typedef void (^comfirmButtonClickedBlock)(NSString *textInputed);

@property(nonatomic,copy) comfirmButtonClickedBlock comfirmButtonClickedBlock;
- (void)show;
- (void)dismiss;
@end
