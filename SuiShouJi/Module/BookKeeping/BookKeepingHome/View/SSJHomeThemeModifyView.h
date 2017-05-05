//
//  SSJHomeThemeModifyView.h
//  SuiShouJi
//
//  Created by ricky on 2017/4/24.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJHomeThemeModifyView : UIView

// 选中的主题
@property(nonatomic, strong) NSString *seletctTheme;

// 选中的字体颜色(0为白色,1为黑色)
@property(nonatomic) BOOL selectType;

@property (nonatomic, copy) void(^themeSelectBlock)(NSString *selectTheme, BOOL selectType);

@property (nonatomic, copy) void(^themeSelectCustomImageBlock)();

- (void)dismiss ;

- (void)show ;


@end
