//
//  SSJFundingTypeManager.h
//  SuiShouJi
//
//  Created by ricky on 2017/8/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJFundingTypeManager : NSObject



@end

@interface SSJFundingParentmodel : NSObject

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, copy) NSString *color;

@property (nonatomic, strong) NSArray *subFunds;

@property (nonatomic) BOOL expended;


@end
