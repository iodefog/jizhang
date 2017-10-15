//
//  SSJFundingTypeManager.m
//  SuiShouJi
//
//  Created by ricky on 2017/8/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFundingTypeManager.h"

@implementation SSJFundingParentmodel


@end

@interface SSJFundingTypeManager ()

@property (nonatomic, strong) NSDictionary<NSString *, NSDictionary *> *allParentFunds;


@end

@implementation SSJFundingTypeManager

+ (instancetype)sharedManager {
    static SSJFundingTypeManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SSJFundingTypeManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            self.allParentFunds = nil;
            self.sassetsFunds = nil;
            self.liabilitiesFunds = nil;
        }];
    }
    return self;
}


- (SSJFundingParentmodel *)modelForFundId:(NSString *)fundId {
    NSDictionary *modelInfo = [SSJFundingTypeManager sharedManager].allParentFunds[fundId];
    if (modelInfo) {
        return [SSJFundingParentmodel mj_objectWithKeyValues:modelInfo];
    }
    
    return nil;
}

- (NSArray *)assetsFundIds {
    return @[@"1",@"2",@"18",@"19",@"20",@"21",@"10",@"15"];
}

- (NSArray *)assetsFundIdsWithOutLoan {
    return @[@"1",@"2",@"18",@"19",@"20",@"21",@"15"];
}

- (NSArray *)liabilitiesFundIds {
    return @[@"3",@"16",@"11"];
}

- (NSArray *)liabilitiesFundIdsWithOutLoan {
    return @[@"3",@"16"];
}

- (NSDictionary<NSString *,NSDictionary *> *)allParentFunds{
    if (!_allParentFunds) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SSJFundingParent" ofType:@"plist"];
        _allParentFunds = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    return _allParentFunds;
}

- (NSArray<SSJFundingParentmodel *> *)sassetsFunds {
    if (!_sassetsFunds) {
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        NSDictionary *allFunds = [SSJFundingTypeManager sharedManager].allParentFunds;
        for (NSString *fundId in [self assetsFundIds]) {
            SSJFundingParentmodel *model = [self modelForFundId:fundId];
            if (model.subFunds.count) {
                NSMutableArray *tempFundArr = [NSMutableArray arrayWithCapacity:0];
                for (NSString *subFundId in model.subFunds) {
                    SSJFundingParentmodel *subModel = [self modelForFundId:subFundId];
                    [tempFundArr addObject:subModel];
                }
                model.subFunds = tempFundArr;
            }
            [tempArr addObject:model];
        }
        _sassetsFunds = tempArr;
    }
    return _sassetsFunds;
}

- (NSArray<SSJFundingParentmodel *> *)liabilitiesFunds {
    if (!_liabilitiesFunds) {
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        for (NSString *fundId in [self liabilitiesFundIds]) {
            SSJFundingParentmodel *model = [self modelForFundId:fundId];
            if (model.subFunds.count) {
                NSMutableArray *tempFundArr = [NSMutableArray arrayWithCapacity:0];
                for (NSString *subFundId in model.subFunds) {
                    SSJFundingParentmodel *subModel = [self modelForFundId:subFundId];
                    [tempFundArr addObject:subModel];
                }
                model.subFunds = tempFundArr;
            }
            [tempArr addObject:model];
        }
        _liabilitiesFunds = tempArr;
    }
    return _liabilitiesFunds;
}

- (NSArray<SSJFundingParentmodel *> *)sassetsFundsWithOutLoan {
    if (!_sassetsFundsWithOutLoan) {
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        for (NSString *fundId in [self assetsFundIdsWithOutLoan]) {
            SSJFundingParentmodel *model = [self modelForFundId:fundId];
            if (model.subFunds.count) {
                NSMutableArray *tempFundArr = [NSMutableArray arrayWithCapacity:0];
                for (NSString *subFundId in model.subFunds) {
                    SSJFundingParentmodel *subModel = [self modelForFundId:subFundId];
                    if (![subFundId isEqualToString:@"17"]) {
                        [tempFundArr addObject:subModel];
                    }
                }
                model.subFunds = tempFundArr;
            }
            [tempArr addObject:model];
        }
        _sassetsFundsWithOutLoan = tempArr;
    }
    return _sassetsFundsWithOutLoan;
}

- (NSArray<SSJFundingParentmodel *> *)liabilitiesFundsWithOutLoan {
    if (!_liabilitiesFundsWithOutLoan) {
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        NSDictionary *allFunds = [SSJFundingTypeManager sharedManager].allParentFunds;
        for (NSString *fundId in [self liabilitiesFundIdsWithOutLoan]) {
            SSJFundingParentmodel *model = [self modelForFundId:fundId];
            if (model.subFunds.count) {
                NSMutableArray *tempFundArr = [NSMutableArray arrayWithCapacity:0];
                for (NSString *subFundId in model.subFunds) {
                    SSJFundingParentmodel *subModel = [self modelForFundId:subFundId];
                    [tempFundArr addObject:subModel];
                }
                model.subFunds = tempFundArr;
            }
            [tempArr addObject:model];
        }
        _liabilitiesFundsWithOutLoan = tempArr;
    }
    return _liabilitiesFundsWithOutLoan;
}

@end
