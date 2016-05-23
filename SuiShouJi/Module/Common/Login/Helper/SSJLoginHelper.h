//
//  SSJLoginHelper.h
//  SuiShouJi
//
//  Created by old lang on 16/5/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface SSJLoginHelper : NSObject

+ (void)updateBillTypeOrderIfNeededForUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error;

@end
