//
//  SSJClearUserDataService.h
//  SuiShouJi
//
//  Created by ricky on 16/7/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"

@interface SSJClearUserDataService : SSJBaseNetworkService

- (void)clearUserDataWithOriginalUserid:(NSString *)originalUserid
                              newUserid:(NSString *)newUserid
                                Success:(void(^)())success
                                failure:(void (^)(NSError *error))failure;

@end
