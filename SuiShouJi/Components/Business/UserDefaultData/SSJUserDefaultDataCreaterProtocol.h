//
//  SSJUserDefaultDataCreaterProtocol.h
//  SuiShouJi
//
//  Created by old lang on 17/3/20.
//  Copyright © 2017年 MZL. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FMDatabase;

@protocol SSJUserDefaultDataCreaterProtocol <NSObject>

+ (void)createDefaultDataTypeForUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
