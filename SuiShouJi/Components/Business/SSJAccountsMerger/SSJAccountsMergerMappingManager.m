//
//  SSJAccountsMergerMapping.m
//  SuiShouJi
//
//  Created by old lang on 16/10/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAccountsMergerMappingManager.h"

@implementation SSJAccountsMergerMappingManager

+ (instancetype)sharedManager {
    static SSJAccountsMergerMappingManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SSJAccountsMergerMappingManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _remindIdMapping = [[NSMutableDictionary alloc] init];
        _memberIdMapping = [[NSMutableDictionary alloc] init];
        _billIdMapping = [[NSMutableDictionary alloc] init];
        _fundIdMapping = [[NSMutableDictionary alloc] init];
        _bookIdMapping = [[NSMutableDictionary alloc] init];
        _loanIdMapping = [[NSMutableDictionary alloc] init];
        _periodChargeIdMapping = [[NSMutableDictionary alloc] init];
        _chargeIdMapping = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end
