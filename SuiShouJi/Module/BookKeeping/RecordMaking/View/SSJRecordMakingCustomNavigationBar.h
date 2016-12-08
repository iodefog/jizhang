//
//  SSJRecordMakingCustomNavigationBar.h
//  SuiShouJi
//
//  Created by old lang on 16/12/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSJRecordMakingCustomNavigationBar;

typedef void(^SSJRecordMakingCustomNavigationBarAction)(SSJRecordMakingCustomNavigationBar *);

@interface SSJRecordMakingCustomNavigationBar : UIView

/**
 下拉菜单的标题
 */
@property (nonatomic, strong) NSArray <NSString *>*titles;

/**
 选中的标题下标，默认－1（即什么都不选）
 */
@property (nonatomic) NSInteger selectedTitleIndex;

/**
 选中的收支类型（只有SSJBillTypePay、SSJBillTypeIncome），默认SSJBillTypePay
 */
@property (nonatomic) SSJBillType selectedBillType;

/**
 管理按钮点击后为YES，再次点击就为NO；默认NO
 */
@property (nonatomic) BOOL managed;

/**
 显示账本选择菜单的回调
 */
@property (nonatomic, copy) SSJRecordMakingCustomNavigationBarAction showBookHandle;

/**
 点击下拉菜单中的选项触发的回调
 */
@property (nonatomic, copy) SSJRecordMakingCustomNavigationBarAction selectBookHandle;

/**
 点击添加账本出发的回调
 */
@property (nonatomic, copy) SSJRecordMakingCustomNavigationBarAction addNewBookHandle;

/**
 选中收入、支出切换控件触发的回调
 */
@property (nonatomic, copy) SSJRecordMakingCustomNavigationBarAction selectBillTypeHandle;

/**
 点击返回按钮触发的回调
 */
@property (nonatomic, copy) SSJRecordMakingCustomNavigationBarAction backOffHandle;

/**
 点击管理按钮触发的回调
 */
@property (nonatomic, copy) SSJRecordMakingCustomNavigationBarAction managementHandle;

/**
 根据当前主题刷新界面
 */
- (void)updateAppearance;

@end
