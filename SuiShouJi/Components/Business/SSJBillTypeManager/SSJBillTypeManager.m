//
//  SSJBillTypeManager.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBillTypeManager.h"

@implementation SSJBillTypeModel
@end

@interface SSJBillTypeManager ()

@property (nonatomic, strong) NSDictionary<NSString *, NSDictionary *> *specialBillTypes;

@property (nonatomic, strong) NSDictionary<NSString *, NSDictionary *> *incomeBillTypes;

@property (nonatomic, strong) NSDictionary<NSString *, NSDictionary *> *expenseBillTypes;

@end

@implementation SSJBillTypeManager

+ (instancetype)sharedManager {
    static SSJBillTypeManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SSJBillTypeManager alloc] init];
    });
    return manager;
}

+ (SSJBillTypeModel *)modelForBillId:(NSString *)billId {
    NSDictionary *modelInfo = [SSJBillTypeManager sharedManager].specialBillTypes[billId];
    if (modelInfo) {
        return [SSJBillTypeModel mj_objectWithKeyValues:modelInfo];
    }
    
    modelInfo = [SSJBillTypeManager sharedManager].incomeBillTypes[billId];
    if (modelInfo) {
        return [SSJBillTypeModel mj_objectWithKeyValues:modelInfo];
    }
    
    modelInfo = [SSJBillTypeManager sharedManager].expenseBillTypes[billId];
    if (modelInfo) {
        return [SSJBillTypeModel mj_objectWithKeyValues:modelInfo];
    }
    
    return nil;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            self.specialBillTypes = nil;
            self.incomeBillTypes = nil;
            self.expenseBillTypes = nil;
        }];
    }
    return self;
}

- (NSDictionary *)specialBillTypes {
    if (!_specialBillTypes) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SSJSpecialType" ofType:@"plist"];
        _specialBillTypes = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    return _specialBillTypes;
}

- (NSDictionary *)incomeBillTypes {
    if (!_incomeBillTypes) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SSJIncomeBillType" ofType:@"plist"];
        _incomeBillTypes = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    return _incomeBillTypes;
}

- (NSDictionary *)expenseBillTypes {
    if (!_expenseBillTypes) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SSJExpenseBillType" ofType:@"plist"];
        _expenseBillTypes = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    return _expenseBillTypes;
}

@end
