//
//  SSJMobileNoField.h
//  SuiShouJi
//
//  Created by old lang on 2017/6/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJMobileNoField : UITextField

/**
 default 11
 */
@property (nonatomic) NSUInteger mobileNoLength;

@end

@interface SSJMobileNoField (SSJTheme)

- (void)updateAppearanceAccordingToTheme;

@end
