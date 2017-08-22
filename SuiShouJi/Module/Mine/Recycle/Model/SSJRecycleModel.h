//
//  SSJRecycleModel.h
//  SuiShouJi
//
//  Created by old lang on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SSJRecycleType) {
    SSJRecycleTypeCharge = 0,
    SSJRecycleTypeFund = 1,
    SSJRecycleTypeBooks = 2
};

typedef NS_ENUM(NSInteger, SSJRecycleState) {
    SSJRecycleStateNormal = 0,
    SSJRecycleStateRecovered = 1,
    SSJRecycleStateRemoved = 2
};

@interface SSJRecycleModel : NSObject <NSCopying>

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *userID;

@property (nonatomic, copy) NSString *sundryID;

@property (nonatomic) SSJRecycleType type;

@property (nonatomic, strong) NSDate *clientAddDate;

@property (nonatomic, strong) NSDate *writeDate;

@property (nonatomic) SSJRecycleState state;

@property (nonatomic) int64_t version;

@end
