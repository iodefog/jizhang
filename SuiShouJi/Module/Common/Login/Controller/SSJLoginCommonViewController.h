//
//  SSJLoginCommonViewController.h
//  SuiShouJi
//
//  Created by yi cai on 2017/6/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "MMDrawerController.h"
#import "UIViewController+MMDrawerController.h"

#import "TPKeyboardAvoidingScrollView.h"
@interface SSJLoginCommonViewController : SSJBaseViewController
@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

/**
 顶部uiimgeview
 */
@property (nonatomic, strong) UIImageView *topView;

/**titleLabel*/
@property (nonatomic, strong) UILabel *titleL;
@end
