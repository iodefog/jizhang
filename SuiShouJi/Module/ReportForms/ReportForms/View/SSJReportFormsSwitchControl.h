//
//  SSJReportFormsSwitchControl.h
//  SuiShouJi
//
//  Created by old lang on 16/7/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJReportFormsSwitchControl : UIControl

@property (nonatomic) NSUInteger selectedIndex;

@property (nonatomic, strong, readonly) NSArray *titles;

@property (nonatomic, strong) UIColor *normalTitleColor;

@property (nonatomic, strong) UIColor *selectedTitleColor;

@property (nonatomic, strong) UIColor *normalBackgroundColor;

@property (nonatomic, strong) UIColor *selectedBackgroundColor;

@property (nonatomic, strong) UIColor *lineColor;

- (instancetype)initWithTitles:(NSArray <NSString *>*)titles;

@end
