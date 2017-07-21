//
//  SSJMemoMakingView.h
//  SuiShouJi
//
//  Created by ricky on 16/4/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

SSJ_DEPRECATED
@interface SSJMemoMakingView : UIView<UITextViewDelegate>

@property(nonatomic, strong) NSString *originalText;

typedef void (^comfirmButtonClickedBlock)(NSString *textInputed);

@property(nonatomic,copy) comfirmButtonClickedBlock comfirmButtonClickedBlock;

typedef void (^typeErrorBlock)(NSString *errorDesc);

@property(nonatomic,copy) typeErrorBlock typeErrorBlock;

- (void)show;
- (void)dismiss;
@end
