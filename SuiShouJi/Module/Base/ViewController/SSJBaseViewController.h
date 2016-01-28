//
//  SSJBaseViewController.h
//  MoneyMore
//
//  Created by old lang on 15-3-22.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+SSJPageFlow.h"
#import "SSJBaseNetworkService.h"

@interface SSJBaseViewController : UIViewController <SSJBaseNetworkServiceDelegate>

/**
 *  点击是否隐藏键盘，默认为NO
 */
@property (nonatomic) BOOL hideKeyboradWhenTouch;

/**
 *  同步成功后重载数据，子类根据情况重写，父类中没有做任何处理
 */
- (void)reloadDataAfterSync;

@end
