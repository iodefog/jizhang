//
//  SSJCalenderHelper.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJCalenderHelper : NSObject
+ (void)queryDataInYear:(NSInteger)year
                  month:(NSInteger)month
                success:(void (^)(NSDictionary *data))success
                failure:(void (^)(NSError *error))failure;
@end
