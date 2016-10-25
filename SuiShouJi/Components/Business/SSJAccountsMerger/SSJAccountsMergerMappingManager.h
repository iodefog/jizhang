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

@property (nonatomic, readonly) NSMutableDictionary *remindIdMapping;

@property (nonatomic, readonly) NSMutableDictionary *memberIdMapping;

@property (nonatomic, readonly) NSMutableDictionary *billIdMapping;

@property (nonatomic, readonly) NSMutableDictionary *fundIdMapping;

@property (nonatomic, readonly) NSMutableDictionary *bookIdMapping;

@property (nonatomic, readonly) NSMutableDictionary *loanIdMapping;

@property (nonatomic, readonly) NSMutableDictionary *periodChargeIdMapping;

@property (nonatomic, readonly) NSMutableDictionary *chargeIdMapping;

@end
