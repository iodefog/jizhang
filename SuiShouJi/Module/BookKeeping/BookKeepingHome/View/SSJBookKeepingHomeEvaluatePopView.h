//
//  SSJBookKeepingHomeEvaluatePopView.h
//  SuiShouJi
//
//  Created by yi cai on 2016/12/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
//  应用第一次启动时间（弹框）
extern NSString *const SSJApplicationLunchTimeKey;
extern NSString *const SSJNewUserKey;//是否为新用户
extern NSString *const SSJEvaluateSelecatedKey;//用户点击了那个按钮

//  评价弹框用户选择类型
typedef NS_ENUM(NSUInteger, SSJEvaluateSelecatedType) {
    SSJEvaluateSelecatedTypeUnKnow = 0,        //  未知，用户没有选择
    SSJEvaluateSelecatedTypeHighPraise = 1,    //  赏个好评
    SSJEvaluateSelecatedTypeLatter = 2,        //  稍后再说
    SSJEvaluateSelecatedTypeNotShowAgain = 3   //  别再烦我
};
@interface SSJBookKeepingHomeEvaluatePopView : UIView
/*
typedef void(^FavorableReceptionBtnClickBlock)();
@property (nonatomic, copy) FavorableReceptionBtnClickBlock favorableReceptionBtnClickBlock;

typedef void(^LaterBtnClickBlock)();
@property (nonatomic, copy) LaterBtnClickBlock laterBtnClickBlock;


typedef void(^NotShowAgainBtnClickBlock)();
@property (nonatomic, copy) NotShowAgainBtnClickBlock notShowAgainBtnClickBlock;
 */

/**
 用户选择类型
 */
@property (nonatomic, assign) SSJEvaluateSelecatedType evaluateSelecatedType;
/**
 *  显示
 */
- (BOOL)showEvaluatePopView;

/**
 *  设置启动时间，判断是否为新用户
 */
+ (void)evaluatePopViewConfiguration;


@end
