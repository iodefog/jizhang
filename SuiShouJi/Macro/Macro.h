//
//  Macro.h
//  MoneyMore
//
//  Created by old lang on 15/9/6.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#ifndef MoneyMore_Macro_h
#define MoneyMore_Macro_h

//  安全地给主线程同步添加任务
#define SSJDispatch_main_sync_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_sync(dispatch_get_main_queue(), block);\
    }

//  安全地给主线程异步添加任务
#define SSJDispatch_main_async_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }

//  为了使用新版AFNetworking暂时添加的宏，xcode更新到7时可以删掉
//#ifndef TARGET_OS_IOS
//#define TARGET_OS_IOS TARGET_OS_IPHONE
//#endif
//#ifndef TARGET_OS_WATCH
//#define TARGET_OS_WATCH 0
//#endif

//  标注弃用某个类或方法使用的宏
#if defined(__GNUC__) && (__GNUC__ >= 4) && defined(__APPLE_CC__) && (__APPLE_CC__ >= 5465)
#define SSJ_DEPRECATED __attribute__((deprecated))
#else
#define SSJ_DEPRECATED
#endif

//  打印日志
#ifdef DEBUG
#define SSJPRINT(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define SSJPRINT(xx, ...)  ((void)0)
#endif

//  RGB颜色
#define RGBCOLOR(_red, _green, _blue) [UIColor colorWithRed:(_red)/255.0f green:(_green)/255.0f blue:(_blue)/255.0f alpha:1]

//  RGB颜色
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]

//  角度转换
#define degreesToRadians(x)(M_PI*x/180.0)

//  根据屏幕宽度比例计算宽度
#define SSJ_SCALE_WIDTH(x) CGRectGetWidth([UIScreen mainScreen].bounds) / 320 * (x)

//  默认背景颜色
#define SSJ_DEFAULT_BACKGROUND_COLOR RGBCOLOR(245, 245, 245)

//  默认分割线颜色
#define SSJ_DEFAULT_SEPARATOR_COLOR [UIColor ssj_colorWithHex:@"#e8e8e8"]

//  主题红色
#define SSJ_THEME_RED_COLOR [UIColor ssj_colorWithHex:@"#eb4a64"]

//  密码过滤规则
#define kAlphaNum @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"

//  身份证过滤规则
#define kIDCardFilter @"0123456789xX"

//  短信验证码签名秘钥
#define SSJ_PIE_KEY @"iwannapie?!"

//  默认错误提示
#define SSJ_ERROR_MESSAGE @"出错啦，休息一下再试^_^"

//  无效的版本号，int类型
#define SSJ_INVALID_SYNC_VERSION LONG_LONG_MIN

//  屏幕高度
#define SSJSCREENHEIGHT CGRectGetHeight([UIScreen mainScreen].bounds)

//  屏幕屏幕宽度
#define SSJSCREENWITH CGRectGetWidth([UIScreen mainScreen].bounds)

//  导航栏底部到屏幕顶端的距离
#define SSJ_NAVIBAR_BOTTOM self.navigationController.navigationBar.bottom

//  tabbar高度
#define SSJ_TABBAR_HEIGHT self.tabBarController.tabBar.height

#endif
