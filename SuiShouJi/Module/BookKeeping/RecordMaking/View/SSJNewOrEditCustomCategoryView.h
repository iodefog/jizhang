//
//  SSJNewOrEditCustomCategoryView.h
//  SuiShouJi
//
//  Created by old lang on 16/8/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJCategoryEditableCollectionView.h"

@class SSJRecordMakingCategoryItem;

SSJ_DEPRECATED
@interface SSJNewOrEditCustomCategoryView : UIView

@property (nonatomic, strong, readonly) UITextField *textField;

@property (nonatomic, strong) NSArray <NSString *>*images;

@property (nonatomic, strong) NSArray <NSString *>*colors;

@property (nonatomic, strong) NSString *selectedImage;

@property (nonatomic, strong) NSString *selectedColor;

@property (nonatomic) CGFloat displayColorRowCount;

@property (nonatomic, copy) void (^selectImageAction)(SSJNewOrEditCustomCategoryView *view);

@property (nonatomic, copy) void (^selectColorAction)(SSJNewOrEditCustomCategoryView *view);

@property (nonatomic, strong) SSJCategoryEditableCollectionView *imageSelectionView;

- (void)updateAppearance;

@end
