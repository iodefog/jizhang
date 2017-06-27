//
//  SSJVerifCodeField.h
//  SuiShouJi
//
//  Created by yi cai on 2017/6/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJLoginVerifyPhoneNumViewModel.h"

@interface SSJVerifCodeField : UITextField
/**
 default 6
 */
@property (nonatomic) NSUInteger minPasswordLength;

/**
 default 15
 */
@property (nonatomic) NSUInteger maxPasswordLength;

/**<#注释#>*/
@property (nonatomic, strong) SSJLoginVerifyPhoneNumViewModel *viewModel;

//只有找回密码用14其他都是13
- (instancetype)initWithGetCodeType:(SSJRegistAndForgetPasswordType)type;
@end

@interface SSJVerifCodeField (SSJTheme)

- (void)updateAppearanceAccordingToTheme;
@end
