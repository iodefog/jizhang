//
//  SSJCheckMark.h
//  SuiShouJi
//
//  Created by old lang on 2017/8/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SSJCheckMarkState) {
    SSJCheckMarkNormal = 0,
    SSJCheckMarkHighlighted,
    SSJCheckMarkDisabled,
    SSJCheckMarkSelected,
};

@interface SSJCheckMark : UIControl

@property (nonatomic) CGFloat radius;

@property (nonatomic) SSJCheckMarkState currentState;

- (void)setTickColr:(UIColor *)tickColr forState:(SSJCheckMarkState)state;

- (UIColor *)tickColorForState:(SSJCheckMarkState)state;

- (void)setFillColr:(UIColor *)fillColor forState:(SSJCheckMarkState)state;

- (UIColor *)fillColorForState:(SSJCheckMarkState)state;

@end


@interface SSJCheckMark (SSJTheme)

- (void)updateAppearanceAccordingToTheme;

@end
