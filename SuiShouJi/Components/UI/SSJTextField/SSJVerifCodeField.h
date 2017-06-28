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

/**<#注释#>*/
@property (nonatomic, strong) SSJLoginVerifyPhoneNumViewModel *viewModel;

//只有找回密码用14其他都是13
- (instancetype)initWithGetCodeType:(SSJRegistAndForgetPasswordType)type;
- (void)getVerifCode;

@end

@interface SSJVerifCodeField (SSJTheme)

- (void)updateAppearanceAccordingToTheme;
- (void)defaultAppearanceTheme;
@end
