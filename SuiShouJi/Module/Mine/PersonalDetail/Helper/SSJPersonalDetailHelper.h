//
//  SSJPersonalDetailHelper.h
//  SuiShouJi
//
//  Created by ricky on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJPersonalDetailItem.h"

@interface SSJPersonalDetailHelper : NSObject
+ (void)queryUserDetailWithsuccess:(void (^)(SSJPersonalDetailItem *data))success
                        failure:(void (^)(NSError *error))failure;
@end
