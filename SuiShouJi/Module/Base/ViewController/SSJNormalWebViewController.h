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
 *  是否隐藏工具条,默认隐藏(YES)
 */
@property (nonatomic, assign) BOOL toolBarHidden;

/**
 *  实例化简单方法
 *
 *  @param url 请求的URL
 *
 *  @return SSJNormalWebViewController对象
 */
+ (SSJNormalWebViewController *)webViewVCWithURL:(NSURL *)url;

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

@end
