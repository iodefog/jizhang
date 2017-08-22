//
//  SSJRecycleModel.m
//  SuiShouJi
//
//  Created by old lang on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRecycleModel.h"

@implementation SSJRecycleModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"ID":@"rid",
             @"userID":@"cuserid",
             @"sundryID":@"cid",
             @"type":@"itype",
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
    model.writeDate = self.writeDate;
    model.state = self.state;
    model.version = self.version;
    return model;
}

@end
