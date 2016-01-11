//
//  SSJDataSyncModel.h
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"

@interface SSJDataSyncModel : NSObject

//  用户ID
@property (nonatomic, copy) NSString *CUSERID;

@property (nonatomic, copy) NSString *CWRITEDATE;

@property (nonatomic) NSInteger IVERSION;

@property (nonatomic) NSInteger OPERATORTYPE;

+ (instancetype)modelWithResultSet:(FMResultSet *)result;

+ (NSArray *)primaryKeys;

+ (NSArray *)getAllProperties;

@end
