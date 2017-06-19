//
//  SSJUserTable.h
//  SuiShouJi
//
//  Created by old lang on 17/5/9.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJUserTable : NSObject

+ (NSDictionary *)syncDataWithUserId:(NSString *)userId;

+ (BOOL)mergeData:(NSDictionary *)info;

@end
