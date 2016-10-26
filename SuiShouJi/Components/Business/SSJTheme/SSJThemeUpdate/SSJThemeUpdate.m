//
//  SSJThemeUpdate.m
//  SuiShouJi
//
//  Created by ricky on 16/10/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeUpdate.h"
#import "SSJNetworkReachabilityManager.h"
#import "SSJThemeService.h"
#import "SSJThemeItem.h"
#import "SSJThemeHomeViewController.h"

@implementation SSJThemeUpdate

+ (void)updateLocalThemesIfneeded{
    // 判断是否是wifi环境,如果是直接下载
    if ([SSJNetworkReachabilityManager networkReachabilityStatus] == SSJNetworkReachabilityStatusReachableViaWiFi) {
        SSJThemeService *service = [[SSJThemeService alloc]initWithDelegate:NULL];
        service.success = ^(NSArray <SSJThemeItem *> *items){
            for (SSJThemeItem *item in items) {
                if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", [NSString ssj_themeDirectory], item.themeId]]) {
                    if (item.downLoadUrl.length) {
                        [[SSJThemeDownLoaderManger sharedInstance] downloadThemeWithItem:item success:NULL failure:NULL];
                    }
                }
            }
        };
        [service requestThemeList];
    }else{
        SSJThemeService *service = [[SSJThemeService alloc]initWithDelegate:NULL];
        service.success = ^(NSArray <SSJThemeItem *> *items){
            for (SSJThemeItem *item in items) {
                SSJThemeModel *localTheme = [SSJThemeSetting ThemeModelForModelId:item.themeId];
                if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", [NSString ssj_themeDirectory], item.themeId]]) {
                    if ([localTheme.version integerValue] < [item.version integerValue]) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"你有新的皮肤需要升级哦~" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
                        UIAlertAction *comfirm = [UIAlertAction actionWithTitle:@"前往升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            SSJThemeHomeViewController *themeVc = [[SSJThemeHomeViewController alloc]init];
                            [SSJVisibalController().navigationController pushViewController:themeVc animated:YES];
                        }];
                        [alert addAction:cancel];
                        [alert addAction:comfirm];
                        [SSJVisibalController().navigationController presentViewController:alert animated:YES completion:NULL];
                        break;
                    }
                }
            }
        };
        [service requestThemeList];
    }
}

@end
