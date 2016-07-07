//
//  SSJHomeBarButton.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJHomeBarButton : UIView

@property (nonatomic) long currentDay;

@property (nonatomic,strong) UIButton *btn;

- (void)updateAfterThemeChange;

@end
