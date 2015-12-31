//
//  AppDelegate.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/11.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "AppDelegate.h"
#import "SSJBookKeepingHomeViewController.h"
#import "SSJMoreHomeViewController.h"
#import "SSJFinancingHomeViewController.h"
#import "SSJReportFormsViewController.h"
#import "MobClick.h"
#import "FMDB.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
static NSString *const UMAppKey = @"566e6f12e0f55ac052003f62";



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //  添加友盟统计
    [self umengTrack];
    
    //  创建数据表
    [self createTables];
    
    [self setRootViewController];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

//  设置根控制器
- (void)setRootViewController {
    SSJBookKeepingHomeViewController *bookKeepingVC = [[SSJBookKeepingHomeViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *bookKeepingNavi = [[UINavigationController alloc] initWithRootViewController:bookKeepingVC];
    bookKeepingNavi.tabBarItem.title = @"记账";
    bookKeepingNavi.tabBarItem.image = [UIImage imageNamed:@""];
    
    SSJReportFormsViewController *reportFormsVC = [[SSJReportFormsViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *reportFormsNavi = [[UINavigationController alloc] initWithRootViewController:reportFormsVC];
    reportFormsNavi.tabBarItem.title = @"报表";
    reportFormsNavi.tabBarItem.image = [UIImage imageNamed:@""];
    
    SSJFinancingHomeViewController *financingVC = [[SSJFinancingHomeViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *financingNavi = [[UINavigationController alloc] initWithRootViewController:financingVC];
    financingNavi.tabBarItem.title = @"资金";
    financingNavi.tabBarItem.image = [UIImage imageNamed:@""];
    
    SSJMoreHomeViewController *moreVC = [[SSJMoreHomeViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *moreNavi = [[UINavigationController alloc] initWithRootViewController:moreVC];
    moreNavi.tabBarItem.title = @"我的";
    moreNavi.tabBarItem.image = [UIImage imageNamed:@""];
    
    UITabBarController *tabBarVC = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    tabBarVC.tabBar.barTintColor = [UIColor whiteColor];
    tabBarVC.tabBar.tintColor = [UIColor ssj_colorWithHex:@"#ea5559"];
    tabBarVC.viewControllers = @[bookKeepingNavi, reportFormsNavi, financingNavi, moreNavi];
    self.window.rootViewController = tabBarVC;
}

- (void)createTables {
    NSString *dbDocumentPath = SSJSQLitePath();
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbDocumentPath]) {
        NSString *dbBundlePath = [[NSBundle mainBundle] pathForResource:@"mydatabase" ofType:@"db"];
        
        NSError *error = nil;
        if (![[NSFileManager defaultManager] copyItemAtPath:dbBundlePath toPath:dbDocumentPath error:&error]) {
            SSJPRINT(@"move database error:%@",[error localizedDescription]);
        }
    }
    
//    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
//    NSLog(@"%@",SSJSQLitePath());
//    if (![db open]) {
//        return;
//    }
    
//    //  用户表 CUSERID:用户唯一序列id CPWD:登录密码 CFPWD:资金密码 CNICKID:昵称 CMOBILENO:手机号 CREALNAME:用户真实姓名 CIDCARD:身份证号 CICONS:头像
//    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS BK_USER (CUSERID text primary key, CPWD text, CFPWD text, CNICKID text, CMOBILENO text, CREALNAME text, CIDCARD text, CICONS text)"];
//    
//    //  用户收支类型中间表 CUSERID:用户ID CBILLID:收支类型ID ISTATE:是否启用 0启用  1 禁用
//    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS BK_USER_BILL (CUSERID text, CBILLID text, ISTATE int, CWRITEDATE text, IVERSION int, OPERATORTYPE int, constraint PK_BK_USER_BILL primary key (CUSERID, CBILLID))"];
//    
//    //  收支类型表 ID:收支类型ID CNAME:账单类型名称 ITYPE:0收入 1支出 2平帐收入 3平帐支出 CCOIN:图标 CCOLOR:颜色 ISTATE:0不启用 1启用
//    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS BK_BILL_TYPE (ID text primary key, CNAME text, ITYPE int, IBOOKSTYPE int, CCOIN text, CCOLOR text, ISTATE int)"];
//    
//    //  资金账户信息表 CFUNDID:账户ID CACCTNAME:账户名称 CICOIN:图标 CPARENT:父账户(若为一级账户则父账户记为 root) CCOLOR:颜色编号 CADDDATE:添加时间
//    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS BK_FUND_ACCT (CFUNDID text primary key, CACCTNAME text, CICOIN text, CPARENT text, CCOLOR text, CADDDATE text, CWRITEDATE text, IVERSION int, OPERATORTYPE int)"];
//    
//    //  用户资金账户金额表 CUSERID:用户id CFUNDID:用户资金账户编号 IBALANCE:用户资金金额
//    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS BK_FUNS_ACCT (CUSERID text, CFUNDID text, IBALANCE text, constraint PK_BK_FUNS_ACCT primary key(CUSERID, CFUNDID))"];
//    
//    //  用户记账流水表 ICHARGEID:流水编号 CUSERID:用户ID IMONEY:金额 IBILLID:收支类型 IFID:资金账户类型 CADDDATE:日期 IOLDMONEY:变化前余额 IBALANCE:当前余额 EDITORDATE:编辑时间 CLIENTDATE:客户端修改时间 CBILLDATE:账单日期
//    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS BK_USER_CHARGE (ICHARGEID text primary key, CUSERID text, IMONEY real, IBILLID text, IFID text, CADDDATE text, IOLDMONEY real, IBALANCE real, CWRITEDATE text, IVERSION int, OPERATORTYPE int , CBILLDATE text)"];
//    
//    
//    //  用户每日记账汇总表 CBILLDATE:记账日期 EXPENCEAMOUT:支出金额 INCOMEAMOUT:收入金额
//    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS BK_DAILYSUM_CHARGE (CBILLDATE text primary key, EXPENCEAMOUNT real, INCOMEAMOUNT real , SUMAMOUNT real , ICHARGEID text , IBILLID text , CWRITEDATE text)"];
//    
//    [db close];
}

#pragma mark - 友盟
/* 友盟统计 */
- (void)umengTrack {
    [MobClick setCrashReportEnabled:YES]; // 如果不需要捕捉异常，注释掉此行
#ifdef DEBUG
    //    [MobClick setLogEnabled:YES];
#endif
    [MobClick setAppVersion:SSJAppVersion()]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    //  reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
    //  channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App Store"渠道
    [MobClick startWithAppkey:UMAppKey reportPolicy:(ReportPolicy)BATCH channelId:SSJDefaultSource()];
}

@end
