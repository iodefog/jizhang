//
//  SSJVerifCodeField.h
//  SuiShouJi
//
//  Created by yi cai on 2017/6/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJLoginVerifyPhoneNumViewModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 请求验证码的状态

 - SSJGetVerifCodeStateReady: 还未请求
 - SSJGetVerifCodeStateLoading: 正在请求中
 - SSJGetVerifCodeStateSent: 已经发送
 - SSJGetVerifCodeStateNeedImageCode: 需要图片验证码
 - SSJGetVerifCodeStateImageCodeError: 图片验证码错误
 - SSJGetVerifCodeStateFailed: 请求失败
 */
typedef NS_ENUM(NSInteger, SSJGetVerifCodeState) {
    SSJGetVerifCodeStateReady = 0,
    SSJGetVerifCodeStateLoading,
    SSJGetVerifCodeStateSent,
    SSJGetVerifCodeStateNeedImageCode,
    SSJGetVerifCodeStateImageCodeError,
    SSJGetVerifCodeStateFailed
};

@interface SSJVerifCodeField : UITextField

/**
 验证码长度限制，默认6；如果为0就不做限制
 */
@property (nonatomic) NSUInteger authCodeLength;

/**<#注释#>*/
@property (nonatomic, strong) SSJLoginVerifyPhoneNumViewModel *viewModel;

/**
 验证码请求成功的回调
 */
@property (nonatomic, readonly) SSJGetVerifCodeState getAuthCodeState;

//只有找回密码用14其他都是13
- (instancetype)initWithGetCodeType:(SSJRegistAndForgetPasswordType)type;

- (void)getVerifCode;

@end

@interface SSJVerifCodeField (SSJTheme)

- (void)updateAppearanceAccordingToTheme;

- (void)defaultAppearanceTheme;

@end

NS_ASSUME_NONNULL_END
