//
//  SSJAccountsMergerMapping.h
//  SuiShouJi
//
//  Created by old lang on 16/10/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJAccountsMergerMappingModel;

@interface SSJAccountsMergerMappingManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, readonly) NSMutableDictionary <NSString *, NSString *>*remindIdMapping;

@property (nonatomic, readonly) NSMutableDictionary <NSString *, NSString *>*memberIdMapping;

@property (nonatomic, readonly) NSMutableDictionary <NSString *, NSString *>*billIdMapping;

@property (nonatomic, readonly) NSMutableDictionary <NSString *, SSJAccountsMergerMappingModel *>*fundIdMapping;

@property (nonatomic, readonly) NSMutableDictionary <NSString *, NSString *>*bookIdMapping;

@property (nonatomic, readonly) NSMutableDictionary <NSString *, NSString *>*loanIdMapping;

@property (nonatomic, readonly) NSMutableDictionary <NSString *, NSString *>*periodChargeIdMapping;

@property (nonatomic, readonly) NSMutableDictionary <NSString *, NSString *>*chargeIdMapping;

@end

@interface SSJAccountsMergerMappingModel : NSObject

@property (nonatomic, copy) NSString *ID;

@property (nonatomic) BOOL newCreated;

@end
