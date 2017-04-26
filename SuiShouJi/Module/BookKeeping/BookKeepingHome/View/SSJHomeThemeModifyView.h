//
//  SSJHomeThemeModifyView.h
//  SuiShouJi
//
//  Created by ricky on 2017/4/24.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJHomeThemeModifyView : UIView

@property(nonatomic, strong) NSString *seletctTheme;

@property (nonatomic, copy) void(^themeSelectBlock)(NSString *selectTheme);

@property (nonatomic, copy) void(^themeSelectCustomImageBlock)();

- (void)dismiss ;

- (void)show ;


@end
