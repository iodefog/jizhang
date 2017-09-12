//
//  SSJStartViewHelper.m
//  SuiShouJi
//
//  Created by ricky on 2017/9/12.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJStartViewHelper.h"

#import "SSJNavigationController.h"
#import "SSJBookKeepingHomeViewController.h"
#import "SSJReportFormsViewController.h"
#import "SSJFinancingHomeViewController.h"
#import "SSJNewMineHomeViewController.h"
#import "SSJBooksTypeSelectViewController.h"
#import "MMDrawerController.h"
#import "UIViewController+SSJMotionPassword.h"

#import "SSJGradientMaskView.h"

@implementation SSJStartViewHelper

+ (void)jumpOutOnViewController:(SSJBaseViewController *)controller {
    SSJBookKeepingHomeViewController *bookKeepingVC = [[SSJBookKeepingHomeViewController alloc] initWithNibName:nil bundle:nil];
    SSJNavigationController *bookKeepingNavi = [[SSJNavigationController alloc] initWithRootViewController:bookKeepingVC];
    bookKeepingNavi.tabBarItem.title = @"记账";
    
    SSJReportFormsViewController *reportFormsVC = [[SSJReportFormsViewController alloc] initWithNibName:nil bundle:nil];
    SSJNavigationController *reportFormsNavi = [[SSJNavigationController alloc] initWithRootViewController:reportFormsVC];
    reportFormsNavi.tabBarItem.title = @"报表";
    
    SSJFinancingHomeViewController *financingVC = [[SSJFinancingHomeViewController alloc] initWithNibName:nil bundle:nil];
    SSJNavigationController *financingNavi = [[SSJNavigationController alloc] initWithRootViewController:financingVC];
    financingNavi.tabBarItem.title = @"资金";
    
    SSJNewMineHomeViewController *moreVC = [[SSJNewMineHomeViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
    SSJNavigationController *moreNavi = [[SSJNavigationController alloc] initWithRootViewController:moreVC];
    moreNavi.tabBarItem.title = @"我的";
    
    UITabBarController *tabBarVC = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    tabBarVC.viewControllers = @[bookKeepingNavi, reportFormsNavi, financingNavi, moreNavi];
    
    SSJBooksTypeSelectViewController *booksTypeVC = [[SSJBooksTypeSelectViewController alloc]init];
    SSJNavigationController *booksNav = [[SSJNavigationController alloc] initWithRootViewController:booksTypeVC];
    
    MMDrawerController *drawerController = [[MMDrawerController alloc]
                                            initWithCenterViewController:tabBarVC
                                            leftDrawerViewController:booksNav
                                            rightDrawerViewController:nil];
    [drawerController setShowsShadow:NO];
    [drawerController setMaximumLeftDrawerWidth:SSJSCREENWITH * 0.8];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    drawerController.view.backgroundColor = [UIColor whiteColor];
    
    SSJGradientMaskView *maskView = [[SSJGradientMaskView alloc]initWithFrame:CGRectMake(0, 0, SSJSCREENWITH, SSJSCREENHEIGHT)];

    //    drawerController.showsShadow = YES;
    [drawerController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
        maskView.currentAplha = percentVisible;
        if (percentVisible > 0.f) {
            [drawerController.centerViewController.view addSubview:maskView];
        }else{
            [maskView removeFromSuperview];
        }
    }];

    [UIApplication sharedApplication].keyWindow.rootViewController = drawerController;
    
    [SSJThemeSetting updateTabbarAppearance];
    
    [UIViewController verifyMotionPasswordIfNeeded:^(BOOL isVerified) {
 
    } animated:NO];
}

@end
