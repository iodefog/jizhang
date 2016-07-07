//
//  SSJBookKeepingButton.h
//  SuiShouJi
//
//  Created by ricky on 16/4/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJBookKeepingButton : UIView
// 开始动画
-(void)startAnimating;

// 结束动画
- (void)stopLoading;

typedef void(^recordMakingClickBlock)();

@property (nonatomic, copy) recordMakingClickBlock recordMakingClickBlock;

//typedef void(^animationStopBlock)();

//@property (nonatomic, copy) animationStopBlock animationStopBlock;

@property(nonatomic) BOOL refreshSuccessOrNot;

- (void)updateAfterThemeChange;


@end
