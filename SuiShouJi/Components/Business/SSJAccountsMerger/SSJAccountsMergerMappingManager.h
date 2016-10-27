//
//  SSJAccountsMergerMapping.h
//  SuiShouJi
//
//  Created by old lang on 16/10/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJAccountsMergerMappingManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, readonly) NSMutableDictionary <NSString *, NSString *>*remindIdMapping;

@property (nonatomic, readonly) NSMutableDictionary <NSString *, NSString *>*memberIdMapping;

@property (nonatomic, readonly) NSMutableDictionary <NSString *, NSString *>*billIdMapping;

@property (nonatomic, readonly) NSMutableDictionary <NSString *, NSString *>*fundIdMapping;

@property (nonatomic, readonly) NSMutableDictionary <NSString *, NSString *>*bookIdMapping;

@property (nonatomic, readonly) NSMutableDictionary <NSString *, NSString *>*loanIdMapping;

@property (nonatomic, readonly) NSMutableDictionary <NSString *, NSString *>*periodChargeIdMapping;

@property (nonatomic, readonly) NSMutableDictionary <NSString *, NSString *>*chargeIdMapping;

@end
