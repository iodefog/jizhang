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

@interface SSJBookKeepingHomeEvaluatePopView : UIView
/*
typedef void(^FavorableReceptionBtnClickBlock)();
@property (nonatomic, copy) FavorableReceptionBtnClickBlock favorableReceptionBtnClickBlock;

typedef void(^LaterBtnClickBlock)();
@property (nonatomic, copy) LaterBtnClickBlock laterBtnClickBlock;


typedef void(^NotShowAgainBtnClickBlock)();
@property (nonatomic, copy) NotShowAgainBtnClickBlock notShowAgainBtnClickBlock;
 */


- (void)showEvaluatePopView;
+ (void)evaluatePopViewConfiguration;
//是否显示过弹框
+ (BOOL)isShowEvaluatePopView;
/**
 *  是否为新用户
 */
+ (BOOL)SSJIsNewUser;



@end
