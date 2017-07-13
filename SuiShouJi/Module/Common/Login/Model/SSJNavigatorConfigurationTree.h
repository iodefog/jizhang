//
//  SSJNavigatorConfigurationTree.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL(^SSJNavigatorConditionBlock)(void);

@class SSJNavigatorConfigurationTree;

@protocol SSJNavigatorConfigurationTreeDataSource <NSObject>

- (NSUInteger)numberOfLayerInConfigurationTree:(SSJNavigatorConfigurationTree *)configurationTree;

- (Class)rootNodeClassInConfigurationTree:(SSJNavigatorConfigurationTree *)configurationTree;

- (NSArray<Class> *)nodeClassInLayerIndex:(NSUInteger)layerIndex superNodeIndex:(NSUInteger)superNodeIndex inConfigurationTree:(SSJNavigatorConfigurationTree *)configurationTree;

- (SSJNavigatorConditionBlock)conditionBlockForChildLayerIndex:(NSUInteger)childLayerIndex childNodeIndex:(NSUInteger)childNodeIndex superNodeIndex:(NSUInteger)superNodeIndex;

@end

@interface SSJNavigatorConfigurationTree : NSObject

@property (nonatomic, weak, readonly) id<SSJNavigatorConfigurationTreeDataSource> dataSource;

- (instancetype)initWithDataSource:(id<SSJNavigatorConfigurationTreeDataSource>)dataSource;

@end


@class SSJNavigator;

@protocol SSJNavigatorDelegate <NSObject>

- (void)navigator:(SSJNavigator *)navigator navigateToPageClass:(Class)pageClass;

- (void)navigatorDidFinishNavigation:(SSJNavigator *)navigator;

@end


@interface SSJNavigator : NSObject

@property (nonatomic, weak) id<SSJNavigatorDelegate> delegate;

@property (nonatomic, strong, readonly) SSJNavigatorConfigurationTree *tree;

- (instancetype)initWithConfiguration:(SSJNavigatorConfigurationTree *)configuration;

- (void)beginNavigation;

- (void)goNext;

@end
