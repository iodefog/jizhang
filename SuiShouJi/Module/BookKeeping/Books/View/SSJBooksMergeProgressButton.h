//
//  SSJBooksMergeProgressButton.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJBooksMergeProgressButton : UIView

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) UILabel  *titleLab;

@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic) BOOL progressDidCompelete;

@property (nonatomic, copy) void(^mergeButtonClickBlock)();

@end
