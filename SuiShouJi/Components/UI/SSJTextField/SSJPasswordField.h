//
//  SSJPasswordField.h
//  SuiShouJi
//
//  Created by old lang on 2017/6/29.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJPasswordField : UITextField

/**
 最大长度限制，默认15
 */
@property (nonatomic) NSUInteger maxLength;

@end

@interface SSJPasswordField (SSJTheme)

- (void)updateAppearanceAccordingToTheme;

- (void)updateAppearanceAccordingToDefaultTheme;

@end
