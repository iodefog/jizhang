//
//  SSJNormalWebViewController.h
//  MoneyMore
//
//  Created by cdd on 15/4/1.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

@interface SSJNormalWebViewController : SSJBaseViewController

@property (nonatomic, strong, readonly) UIWebView *webView;

/**
 *  进度条颜色,默认系统TintColor
 */
@property (nonatomic, strong) UIColor *progressViewTintColor;

/**
 *  工具条Item颜色,默认系统TintColor
 */
@property (nonatomic, strong) UIColor *toolBarItemTintColor;

/**
 *  工具条颜色
 */
@property (nonatomic, strong) UIColor *toolBarTintColor;

/**
 *  是否在导航条显示URL,默认隐藏(NO)
 */
@property (nonatomic, assign) BOOL showURLInNavigationBar;

/**
 *  是否在导航条显示网页的PageTitle,默认隐藏(NO)
 */
@property (nonatomic, assign) BOOL showPageTitleInNavigationBar;

/**
 *  是否隐藏工具条,默认隐藏(YES)
 */
@property (nonatomic, assign) BOOL toolBarHidden;


/**
 *  UIWebView的url
 */
@property (nonatomic, strong) NSURL *url;


/**
 *  实例化简单方法
 *
 *  @param url 请求的URL
 *
 *  @return SSJNormalWebViewController对象
 */
+ (instancetype)webViewVCWithURL:(NSURL *)url;

/**
 *  刷新当前页面
 */
- (void)refresh;

/**
 *  加载HTML字符串源码
 *
 *  @param HTMLString HTML字符串源码
 */
- (void)loadHTMLString:(NSString *)HTMLString;

- (void)loadURL:(NSURL *)URL;

@end
