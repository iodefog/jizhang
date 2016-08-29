//
//  SSJNewOrEditCustomCategoryView.h
//  SuiShouJi
//
//  Created by old lang on 16/8/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSJRecordMakingCategoryItem;

@interface SSJNewOrEditCustomCategoryView : UIView

@property (nonatomic, strong, readonly) UITextField *textField;

@property (nonatomic, strong) NSArray <SSJRecordMakingCategoryItem *>*items;

@property (nonatomic, strong, readonly) SSJRecordMakingCategoryItem *selectedItem;

@property (nonatomic, copy) void (^selectCategoryAction)(SSJNewOrEditCustomCategoryView *view);

@property (nonatomic, copy) void (^selectColorAction)(SSJNewOrEditCustomCategoryView *view);

@end
