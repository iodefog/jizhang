//
//  SSJScrollalbleAnnounceView.h
//  SuiShouJi
//
//  Created by ricky on 2017/2/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJHeadLineItem.h"

@interface SSJScrollalbleAnnounceView : UIView

@property(nonatomic, strong) SSJHeadLineItem *item;

@property (nonatomic, copy) void (^headLineClickedBlock)(SSJHeadLineItem *item);

@property (nonatomic, copy) void (^headLineCloseBtnClickedBlock)(SSJHeadLineItem *item);

/**是否开启定时器*/
@property (nonatomic, assign, readonly) BOOL isDisplayRun;

- (void)updateAppearanceAfterThemeChanged;

//开始
- (void)startAnimation;

//暂停
- (void)stopAnimation;

//移除定时器
- (void)removeDisplayLink;
@end
