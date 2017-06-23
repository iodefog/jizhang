//
//  SSJLoginHelper.h
//  SuiShouJi
//
//  Created by old lang on 16/5/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SSJLoginVerifyPhoneNumViewModel;
@class FMDatabase;

@interface SSJLoginHelper : NSObject

+ (void)updateBillTypeOrderIfNeededForUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error;


+ (void)updateBooksParentIfNeededForUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error;

+ (void)updateCustomUserBillNeededForUserId:(NSString *)userId billTypeItems:(NSArray *)items inDatabase:(FMDatabase *)db error:(NSError **)error;

// 在登录的时候更新表中的数据
+ (void)updateTableWhenLoginWithViewModel:(SSJLoginVerifyPhoneNumViewModel *)viewModel completion:(void(^)())completion;

@end
