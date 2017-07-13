//
//  SSJLoginNavigatorTest.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJLoginNavigatorTest.h"
#import "SSJNavigationController.h"
#import "SSJLoginVerifyPhoneViewController.h"
#import "SSJLoginPhoneViewController.h"
#import "SSRegisterAndLoginViewController.h"
#import "SSJMotionPasswordViewController.h"
#import "SSJBindMobileNoViewController.h"
#import "SSJSettingPasswordViewController.h"
#import "SSJUserTableManager.h"

#import "SSJNavigatorConfigurationTree.h"
#import "SSJDatabaseQueue.h"

@interface SSJLoginNavigatorTest () <SSJNavigatorConfigurationTreeDataSource, SSJNavigatorDelegate>

@property (nonatomic) SSJLoginType loginType;

@property (nonatomic) SSJNavigationType navigationType;

@property (nonatomic) BOOL motionPwdForgeted;

@property (nonatomic, strong) NSString *defaultMobileNo;

@property (nonatomic, strong) SSJNavigationController *navigationVC;

@property (nonatomic, strong) UIViewController *sourceController;

@property (nonatomic, copy) void (^finishHandler)();

@property (nonatomic, strong) NSError *lastError;

@property (nonatomic, strong) SSJNavigatorConfigurationTree *navigatorTree;

@property (nonatomic, strong) SSJNavigator *navigator;

@property (nonatomic, strong) NSDictionary *params;

@end

@implementation SSJLoginNavigatorTest

+ (instancetype)sharedNavigator {
    static SSJLoginNavigatorTest *navigator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        navigator = [[SSJLoginNavigatorTest alloc] init];
    });
    return navigator;
}

- (instancetype)init {
    if (self = [super init]) {
        self.navigatorTree = [[SSJNavigatorConfigurationTree alloc] initWithDataSource:self];
        self.navigator = [[SSJNavigator alloc] initWithConfiguration:self.navigatorTree];
    }
    return self;
}

- (void)beginLoginWithSourceController:(UIViewController *)sourceController
                              mobileNo:(NSString *)mobileNo
                             loginType:(SSJLoginType)loginType
                        navigationType:(SSJNavigationType)navigationType
                     motionPwdForgeted:(BOOL)motionPwdForgeted
                         finishHandler:(void(^)())finishHandler {
    self.loginType = loginType;
    self.navigationType = navigationType;
    self.motionPwdForgeted = self.motionPwdForgeted;
    self.finishHandler = finishHandler;
    self.sourceController = sourceController;
    self.defaultMobileNo = mobileNo;
    
    [self.navigator beginNavigation];
}

#pragma mark - SSJNavigatorConfigurationTreeDataSource
- (NSUInteger)numberOfLayerInConfigurationTree:(SSJNavigatorConfigurationTree *)configurationTree {
    return 5;
}

- (Class)rootNodeClassInConfigurationTree:(SSJNavigatorConfigurationTree *)configurationTree {
    return [SSJLoginVerifyPhoneViewController class];
}

- (NSArray<Class> *)nodeClassInLayerIndex:(NSUInteger)layerIndex superNodeIndex:(NSUInteger)superNodeIndex inConfigurationTree:(SSJNavigatorConfigurationTree *)configurationTree {
    if (layerIndex == 1) {
        return @[[SSJMotionPasswordViewController class],
                 [SSJBindMobileNoViewController class],
                 [NSNull class]];
    } else if (layerIndex == 2) {
        if (superNodeIndex == 0) {
            return @[[SSJBindMobileNoViewController class], [NSNull null]];
        } else if (superNodeIndex == 1) {
            return @[[SSJSettingPasswordViewController class]];
        }
    } else if (layerIndex == 3) {
        if (superNodeIndex == 0) {
            return @[[SSJSettingPasswordViewController class]];
        } else if (superNodeIndex == 2) {
            return @[[NSNull class]];
        }
    } else if (layerIndex == 4) {
        if (superNodeIndex == 0) {
            return @[[NSNull class]];
        }
    }
    
    return nil;
}

- (SSJNavigatorConditionBlock)conditionBlockForChildLayerIndex:(NSUInteger)childLayerIndex childNodeIndex:(NSUInteger)childNodeIndex superNodeIndex:(NSUInteger)superNodeIndex {
    if (childLayerIndex == 1) {
        if (childNodeIndex == 0) {
            return ^{
                return self.motionPwdForgeted;
            };
        } else if (childNodeIndex == 1) {
            return ^{
                BOOL bind = [self queryMobileNo].length <= 0;
                return bind;
            };
        }
        
    } else if (childLayerIndex == 2 && superNodeIndex == 0) {
        if (childNodeIndex == 0) {
            return ^{
                BOOL bind = [self queryMobileNo].length <= 0;
                return bind;
            };
        }
    }
    
    return ^{
        return YES;
    };
}

#pragma mark - SSJNavigatorDelegate
- (void)navigator:(SSJNavigator *)navigator navigateToPageClass:(Class)pageClass {
    NSLog(@"navigateToPageClass:%@", pageClass);
    
    if (pageClass == [SSJLoginVerifyPhoneViewController class]) {
        SSJLoginVerifyPhoneViewController *verifyMobileVC = [[SSJLoginVerifyPhoneViewController alloc] init];
        verifyMobileVC.mobileNo = self.defaultMobileNo;
        
        switch (self.navigationType) {
            case SSJNavigationTypePush:
                if ([self.sourceController isKindOfClass:[SSJNavigationController class]]) {
                    self.navigationVC = (SSJNavigationController *)self.sourceController;
                } else {
                    if ([self.sourceController.navigationController isKindOfClass:[SSJNavigationController class]]) {
                        self.navigationVC = (SSJNavigationController *)self.sourceController.navigationController;
                    } else {
                        self.lastError = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"源控制器的导航控制器为nil或者不是SSJNavigationController的实例"}];
                    }
                }
                
                if (self.navigationVC) {
                    [self.navigationVC pushViewController:verifyMobileVC animated:YES];
                }
                
                break;
                
            case SSJNavigationTypePresent:
                self.navigationVC = [[SSJNavigationController alloc] initWithRootViewController:verifyMobileVC];
                [self.sourceController presentViewController:self.navigationVC animated:YES completion:NULL];
                break;
        }
        
    } else if (pageClass == [SSJMotionPasswordViewController class]) {
        SSJMotionPasswordViewController *motionSettingVC = [[SSJMotionPasswordViewController alloc] init];
        motionSettingVC.type = SSJMotionPasswordViewControllerTypeSetting;
//        motionSettingVC.loginNavigator = self;
        [self.navigationVC pushViewController:motionSettingVC animated:YES];
        
    } else if (pageClass == [SSJBindMobileNoViewController class]) {
        SSJBindMobileNoViewController *bindMobileNoVC = [[SSJBindMobileNoViewController alloc] init];
        [self.navigationVC pushViewController:bindMobileNoVC animated:YES];
        
    } else if (pageClass == [SSJBindMobileNoViewController class]) {
        SSJBindMobileNoViewController *bindMobileNoVC = [[SSJBindMobileNoViewController alloc] init];
        [self.navigationVC pushViewController:bindMobileNoVC animated:YES];
        
    } else if (pageClass == [SSJSettingPasswordViewController class]) {
        SSJSettingPasswordViewController *bindMobileNoVC = [[SSJSettingPasswordViewController alloc] init];
        bindMobileNoVC.mobileNo = self.params[@"mobileNo"];
        [self.navigationVC pushViewController:bindMobileNoVC animated:YES];
        
    }
}

- (void)navigatorDidFinishNavigation:(SSJNavigator *)navigator {
    switch (self.navigationType) {
        case SSJNavigationTypePush:
            [self.navigationVC popToViewController:self.sourceController animated:YES];
            break;
            
        case SSJNavigationTypePresent:
            [self.navigationVC dismissViewControllerAnimated:YES completion:NULL];
            break;
    }
}

- (NSString *)queryMobileNo {
    __block NSString *mobileNo = nil;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(SSJDatabase *db) {
        mobileNo = [db stringForQuery:@"select cmobileno from bk_user where cuserid = ?", SSJUSERID()];
    }];
    return mobileNo;
}

- (void)goNext:(NSDictionary *)params {
    self.params = params;
    [self.navigator goNext];
}

@end


@interface SSJLoginNavigatorTester : NSObject

@end

@implementation SSJLoginNavigatorTester

//+ (void)load {
//    [[SSJLoginNavigatorTest sharedNavigator] beginLoginWithSourceController:nil mobileNo:@"133333" loginType:SSJLoginTypeWeiXin navigationType:SSJNavigationTypePresent motionPwdForgeted:YES finishHandler:NULL];
//    [[SSJLoginNavigatorTest sharedNavigator].navigator goNext];
//}

@end
