//
//  SSJRecycleModel.h
//  SuiShouJi
//
//  Created by old lang on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMResultSet;

@interface SSJRecycleModel : NSObject <NSCopying>

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *userID;

@property (nonatomic, copy) NSString *sundryID;

@property (nonatomic) SSJRecycleType type;

@property (nonatomic, strong) NSDate *clientAddDate;

@property (nonatomic, strong) NSDate *writeDate;

@property (nonatomic) SSJRecycleState state;

@property (nonatomic) int64_t version;

+ (instancetype)modelWithResultSet:(FMResultSet *)rs;

@end
