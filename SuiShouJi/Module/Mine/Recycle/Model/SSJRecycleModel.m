//
//  SSJRecycleModel.m
//  SuiShouJi
//
//  Created by old lang on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRecycleModel.h"
#import "FMResultSet.h"

@implementation SSJRecycleModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"ID":@"rid",
             @"userID":@"cuserid",
             @"sundryID":@"cid",
             @"type":@"itype",
             @"clientAddDate":@"clientadddate",
             @"writeDate":@"cwritedate",
             @"state":@"operatortype",
             @"version":@"iversion"
             };
}

- (instancetype)copyWithZone:(NSZone *)zone {
    SSJRecycleModel *model = [[SSJRecycleModel alloc] init];
    model.ID = self.ID;
    model.userID = self.userID;
    model.sundryID = self.sundryID;
    model.type = self.type;
    model.clientAddDate = self.clientAddDate;
    model.writeDate = self.writeDate;
    model.state = self.state;
    model.version = self.version;
    return model;
}

+ (instancetype)modelWithResultSet:(FMResultSet *)rs {
    SSJRecycleModel *model = [[SSJRecycleModel alloc] init];
    model.ID = [rs stringForColumn:@"rid"];
    model.userID = [rs stringForColumn:@"cuserid"];
    model.sundryID = [rs stringForColumn:@"cid"];
    model.type = [rs intForColumn:@"itype"];
    model.clientAddDate = [NSDate dateWithString:[rs stringForColumn:@"clientadddate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
    model.writeDate = [NSDate dateWithString:[rs stringForColumn:@"cwritedate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
    model.state = [rs intForColumn:@"operatortype"];
    model.version = [rs longLongIntForColumn:@"iversion"];
    return model;
}

@end
