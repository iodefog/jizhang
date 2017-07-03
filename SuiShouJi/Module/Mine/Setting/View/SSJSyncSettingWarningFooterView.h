//
//  SSJSyncSettingWarningFooterView.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSJSyncSettingWarningFooterView : UIView

@property (nonatomic, copy, nullable) NSString *warningText;

- (void)updateAppearanceAccordingToTheme;

@end

NS_ASSUME_NONNULL_END
