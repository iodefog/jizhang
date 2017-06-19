//
//  SSJDatabaseVersionProtocol.h
//  SuiShouJi
//
//  Created by old lang on 16/3/15.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@protocol SSJDatabaseVersionProtocol <NSObject>

@required
+ (NSString *)dbVersion;

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db;

@end
