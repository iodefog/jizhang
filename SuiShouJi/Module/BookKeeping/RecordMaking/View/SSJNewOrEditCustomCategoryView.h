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

@property (nonatomic, strong) NSArray <NSString *>*images;

@property (nonatomic, strong) NSArray <NSString *>*colors;

@property (nonatomic, strong) NSString *selectedImage;

@property (nonatomic, strong) NSString *selectedColor;

@property (nonatomic, copy) void (^selectImageAction)(SSJNewOrEditCustomCategoryView *view);

@property (nonatomic, copy) void (^selectColorAction)(SSJNewOrEditCustomCategoryView *view);

- (void)updateAppearance;

@end
