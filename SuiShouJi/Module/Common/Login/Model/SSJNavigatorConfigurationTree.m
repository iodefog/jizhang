//
//  SSJNavigatorConfigurationTree.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJNavigatorConfigurationTree.h"

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJNavigatiorCondition
#pragma mark -
@interface SSJNavigatiorCondition : NSObject <NSCopying>

@property (nonatomic, copy) SSJNavigatorConditionBlock conditionBlock;

@end

@implementation SSJNavigatiorCondition

+ (instancetype)conditionWithBlock:(SSJNavigatorConditionBlock)conditionBlock {
    SSJNavigatiorCondition *condition = [[SSJNavigatiorCondition alloc] init];
    condition.conditionBlock = conditionBlock;
    return condition;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    SSJNavigatiorCondition *condition = [[SSJNavigatiorCondition alloc] init];
    condition.conditionBlock = self.conditionBlock;
    return condition;
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJNavigatorRelationship
#pragma mark -
@class SSJNavigatorConfigurationTreeNode;

@interface SSJNavigatorRelationship : NSObject

@property (nonatomic, strong) SSJNavigatiorCondition *condition;

@property (nonatomic, strong) SSJNavigatorConfigurationTreeNode *childNode;

@end

@implementation SSJNavigatorRelationship

@end


////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJNavigatorConfigurationTreeNode
#pragma mark -
@interface SSJNavigatorConfigurationTreeNode : NSObject

@property (nonatomic) NSUInteger index;

@property (nonatomic, strong) Class pageClass;

@property (nonatomic, strong) NSArray<SSJNavigatorRelationship *> *relationships;

@end

@implementation SSJNavigatorConfigurationTreeNode

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJNavigatorConfigurationTree
#pragma mark -
@interface SSJNavigatorConfigurationTree ()

@property (nonatomic, weak) id<SSJNavigatorConfigurationTreeDataSource> dataSource;

@property (nonatomic, strong) SSJNavigatorConfigurationTreeNode *rootNode;

@end

@implementation SSJNavigatorConfigurationTree

- (instancetype)initWithDataSource:(id<SSJNavigatorConfigurationTreeDataSource>)dataSource {
    if (self = [super init]) {
        self.dataSource = dataSource;
        [self construct];
    }
    return self;
}

- (void)construct {
    if (!self.dataSource) {
        return;
    }
    
    NSUInteger layerCount = 2;
    if ([self.dataSource respondsToSelector:@selector(numberOfLayerInConfigurationTree:)]) {
        layerCount = [self.dataSource numberOfLayerInConfigurationTree:self];
    }
    
    NSMutableArray<SSJNavigatorConfigurationTreeNode *> *superNodes = [[NSMutableArray alloc] init];
    
    for (int layerIndex = 0; layerIndex < layerCount; layerIndex ++) {
        if (layerIndex == 0) {
            Class rootNodeClass = [self.dataSource rootNodeClassInConfigurationTree:self];
            
            SSJNavigatorConfigurationTreeNode *superNode = [[SSJNavigatorConfigurationTreeNode alloc] init];
            superNode.index = 0;
            superNode.pageClass = rootNodeClass;
            [superNodes addObject:superNode];
            
            self.rootNode = superNode;
            
        } else {
            
            for (int superNodeIndex = 0; superNodeIndex < superNodes.count; superNodeIndex ++) {
                SSJNavigatorConfigurationTreeNode *superNode = superNodes[superNodeIndex];
                NSArray *nodeClasses = [self.dataSource nodeClassInLayerIndex:layerIndex superNodeIndex:superNode.index inConfigurationTree:self];
                NSMutableArray *relationships = [[NSMutableArray alloc] initWithCapacity:nodeClasses.count];
                
                for (int nodeIndex = 0; nodeIndex < nodeClasses.count; nodeIndex ++) {
                    SSJNavigatorConditionBlock conditionBlock = [self.dataSource conditionBlockForChildLayerIndex:layerIndex childNodeIndex:nodeIndex superNodeIndex:superNode.index];
                    Class nodeClass = nodeClasses[nodeIndex];
                    
                    SSJNavigatorConfigurationTreeNode *currentNode = [[SSJNavigatorConfigurationTreeNode alloc] init];
                    currentNode.index = nodeIndex;
                    currentNode.pageClass = nodeClass;
                    
                    SSJNavigatorRelationship *relationship = [[SSJNavigatorRelationship alloc] init];
                    relationship.condition = [SSJNavigatiorCondition conditionWithBlock:conditionBlock];
                    relationship.childNode = currentNode;
                    [relationships addObject:relationship];
                    
                    [superNodes addObject:currentNode];
                }
                
                superNode.relationships = relationships;
                [superNodes removeObjectAtIndex:0];
            }
            
//            if (layerIndex == layerCount - 1) {
//                for (int idx = 0; idx < superNodes.count; idx ++) {
//                    SSJNavigatorConfigurationTreeNode *finishNode = [[SSJNavigatorConfigurationTreeNode alloc] init];
//                    finishNode.index = idx;
//                    finishNode.pageClass = [SSJNavigatorFinishPage class];
//                    
//                    SSJNavigatorRelationship *relationship = [[SSJNavigatorRelationship alloc] init];
//                    relationship.condition = [SSJNavigatiorCondition conditionWithBlock:^BOOL{
//                        return YES;
//                    }];
//                    relationship.childNode = finishNode;
//                    
//                    SSJNavigatorConfigurationTreeNode *superNode = superNodes[idx];
//                    superNode.relationships = @[relationship];
//                }
//            }
        }
    }
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJNavigator
#pragma mark -
@interface SSJNavigator ()

@property (nonatomic, strong) SSJNavigatorConfigurationTree *tree;

@property (nonatomic, strong) SSJNavigatorConfigurationTreeNode *currentNode;

@end

@implementation SSJNavigator

- (instancetype)initWithConfiguration:(SSJNavigatorConfigurationTree *)configuration {
    if (self = [super init]) {
        self.tree = configuration;
        self.currentNode = configuration.rootNode;
    }
    return self;
}

- (void)beginNavigation {
    SSJNavigatorRelationship *relationship = [self.currentNode.relationships firstObject];
    [self navigateToPage:relationship.childNode.pageClass];
}

- (void)goNext {
    SSJNavigatorRelationship *relationship = [self.currentNode.relationships firstObject];
    if (relationship.childNode.pageClass == [NSNull class]) {
        [self finishNavigation];
        return;
    }
    
    SSJNavigatorConfigurationTreeNode *nextNode = nil;
    for (SSJNavigatorRelationship *relationship in self.currentNode.relationships) {
        if (relationship.condition.conditionBlock()) {
            nextNode = relationship.childNode;
            break;
        }
    }
    
    self.currentNode = nextNode;
    [self navigateToPage:nextNode.pageClass];
}

- (void)navigateToPage:(Class)class {
    if (self.delegate && [self.delegate respondsToSelector:@selector(navigator:navigateToPageClass:)]) {
        [self.delegate navigator:self navigateToPageClass:class];
    }
}

- (void)finishNavigation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(navigatorDidFinishNavigation:)]) {
        [self.delegate navigatorDidFinishNavigation:self];
    }
}

@end
