//
//  SSJTextFieldAddition.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 管理输入框工具栏的类，通过此类安装的工具栏，可以通过按钮切换至上一个／下一个输入框
 */
@interface SSJTextFieldToolbarManager : NSObject

/**
 安装切换工具栏

 @param textField <#textField description#>
 */
- (void)installTextFieldToolbar:(UITextField *)textField;

/**
 卸载切换工具栏

 @param textField <#textField description#>
 */
- (void)uninstallTextFieldToolbar:(UITextField *)textField;

/**
 卸载所有切换工具栏
 */
- (void)uninstallAllTextFieldToolbar;

@end

@interface UITextField (SSJToolbar)

/**
 安装只有完成按钮的工具栏
 */
- (void)ssj_installToolbar;

/**
 卸载工具栏
 */
- (void)ssj_uninstallToolbar;

/**
 设置顺序，只有通过SSJTextFieldToolbarManager安装的工具栏，设置此顺序才有作用

 @param order <#order description#>
 */
- (void)ssj_setOrder:(NSUInteger)order;

/**
 获取顺序

 @return <#return value description#>
 */
- (NSUInteger)ssj_order;

/**
 根据主题适配颜色
 */
- (void)ssj_updateAppearanceAccordingToTheme;

@end
