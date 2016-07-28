//
//  SSJMemberChargeTable.h
//  SuiShouJi
//
//  Created by old lang on 16/7/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface SSJMemberChargeTable : NSObject

+ (BOOL)supplementMemberChargeRecords;

+ (BOOL)supplementMemberChargeRecordsInDatabase:(FMDatabase *)db;

@end
