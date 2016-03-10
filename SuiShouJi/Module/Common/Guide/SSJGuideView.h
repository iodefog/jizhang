//
//  SSJGuideView.h
//  MoneyMore
//
//  Created by old lang on 15-5-7.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

/**
 *  引导页
 */

#import <UIKit/UIKit.h>

@class SSJGuideView;

typedef void(^SSJGuideViewBeginBlock)(SSJGuideView *guideView);

@interface SSJGuideView : UIView

////  点击开始按钮的回调
//@property (nonatomic, copy) SSJGuideViewBeginBlock beginHandle;

- (void)showIfNeeded;

- (void)showWithFinish:(void (^)())finish;

@end
