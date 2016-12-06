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

@property (nonatomic, strong) NSArray *titles;

@property (nonatomic) NSInteger selectedTitleIndex;

@property (nonatomic) SSJBillType selectedBillType;

@property (nonatomic, copy) SSJRecordMakingCustomNavigationBarAction selectBookHandle;

@property (nonatomic, copy) SSJRecordMakingCustomNavigationBarAction selectBillTypeHandle;

@property (nonatomic, copy) SSJRecordMakingCustomNavigationBarAction backOffHandle;

@property (nonatomic, copy) SSJRecordMakingCustomNavigationBarAction managementHandle;

- (void)updateAppearance;

@end
