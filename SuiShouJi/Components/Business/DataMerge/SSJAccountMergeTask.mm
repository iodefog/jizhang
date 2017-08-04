//
//  SSJAccountMergeTask.m
//  SuiShouJi
//
//  Created by ricky on 2017/8/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJAccountMergeTask.h"
#import <WCDB/WCDB.h>
#import "SSJAccountMergeManager.h"
#import "SSJDataMergeQueue.h"
#import "SSJUserBaseTable.h"

@interface SSJAccountMergeTask()

@property (nonatomic, strong) SSJAccountMergeManager *mergeManager;

@property (nonatomic, strong) NSString *unloggedUserId;

@end

@implementation SSJAccountMergeTask

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeDataIfNeeded) name:SSJSyncDataSuccessNotification object:nil];
}

+ (void)mergeDataWithManager:(SSJAccountMergeManager *)manager {
    [SVProgressHUD showWithStatus:@"正在合并中"];
    dispatch_async([SSJDataMergeQueue sharedInstance].dataMergeQueue, ^{
        NSString *unloggedUserid = [manager getCurrentUnloggedUserId];
        
        SSJUserBaseTable *currentUser = [manager getCurrentUser];
        
        
        if (!currentUser.lastMergeTime.length || currentUser.lastMergeTime) {
            currentUser.lastMergeTime = @"1970-01-01 00:00:00.000";
        }
        
        NSDate *lastMergeDate = [NSDate dateWithString:currentUser.lastMergeTime formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        UIViewController *currentController = SSJVisibalController();


        [manager startMergeWithSourceUserId:unloggedUserid targetUserId:currentUser.userId startDate:lastMergeDate endDate:[NSDate date] mergeType:SSJMergeDataTypeByWriteDate Success:^{
            [SVProgressHUD showSuccessWithStatus:@"合并成功"];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"合并失败"];
            [SSJAlertViewAdapter showError:error];
        }];
        
    });
}

+ (void)mergeDataIfNeeded {
    SSJAccountMergeManager *mergeManager = [[SSJAccountMergeManager alloc] init];
    
    SSJUserBaseTable *currentUser = [mergeManager getCurrentUser];
    
    NSString *title;
    
    if (currentUser.loginType == SSJLoginTypeNormal) {
        NSString *screteMobileNo = currentUser.mobileNo;
        
        if (screteMobileNo.length == 11) {
            screteMobileNo = [screteMobileNo stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        }
        title = [NSString stringWithFormat:@"是否要将未登录记的账同步到当前登录的手机号:%@账户上",screteMobileNo];
    } else if (currentUser.loginType == SSJLoginTypeQQ) {
        title = [NSString stringWithFormat:@"是否要将未登录记的账同步到当前登录的QQ:%@账户上",currentUser.nickName];
    } else if (currentUser.loginType == SSJLoginTypeWeiXin) {
        title = [NSString stringWithFormat:@"是否要将未登录记的账同步到当前登录的手机号:%@账户上",currentUser.nickName];
    }
    
    if ([mergeManager needToMergeOrNot]) {
        UIViewController *currentController = SSJVisibalController();
        UIAlertAction *comfirm = [UIAlertAction actionWithTitle:@"立即合并" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self mergeDataWithManager:mergeManager];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"放弃数据" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [mergeManager saveLastMergeTime];
        }];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:title preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:comfirm];
        
        [alert addAction:cancel];

        
        [currentController.navigationController presentViewController:alert animated:YES completion:NULL];
    }
}


@end
