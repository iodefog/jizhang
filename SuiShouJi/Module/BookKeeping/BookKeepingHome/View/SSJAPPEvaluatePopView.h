//
//  SSJAPPEvaluatePopView.h
//  SuiShouJi
//
//  Created by yi cai on 2017/6/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const SSJAppApplicationLunchTimeKey;
extern NSString *const SSJAppNewUserKey;
extern NSString *const SSJAppEvaluateSelecatedKey;

@interface SSJAPPEvaluatePopView : UIView
//  评价弹框用户选择类型
typedef NS_ENUM(NSUInteger, SSJAPPEvaluateSelecatedType) {
    SSJAPPEvaluateSelecatedTypeUnKnow = 0,        //  未知，用户没有选择
    SSJAPPEvaluateSelecatedTypePraise = 1,    //  赏个好评
    SSJAPPEvaluateSelecatedTypeTuCao = 2,
    SSJAPPEvaluateSelecatedTypeLatter = 3        //  再用用看
//    SSJEvaluateSelecatedTypeNotShowAgain = 3   //  别再烦我
};

/**
 用户选择类型
 */
@property (nonatomic, assign) SSJAPPEvaluateSelecatedType evaluateSelecatedType;
/**
 *  显示
 */
- (BOOL)showEvaluatePopViewWithController:(UIViewController *)controller;

/**
 *  设置启动时间，判断是否为新用户
 */
+ (void)evaluatePopViewConfiguration;

typedef void(^FavorableReceptionBtnClickBlock)();
@property (nonatomic, copy) FavorableReceptionBtnClickBlock favorableReceptionBtnClickBlock;

typedef void(^LaterBtnClickBlock)();
@property (nonatomic, copy) LaterBtnClickBlock laterBtnClickBlock;
typedef void(^TuCaoBtnClickBlock)();
@property (nonatomic, copy) TuCaoBtnClickBlock tuCaoBtnClickBlock;
//typedef void(^NotShowAgainBtnClickBlock)();
//@property (nonatomic, copy) NotShowAgainBtnClickBlock notShowAgainBtnClickBlock;
@end
