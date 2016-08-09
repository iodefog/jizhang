//
//  SSJMagicExportSuccessAlertView.h
//  SuiShouJi
//
//  Created by old lang on 16/8/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJMagicExportSuccessAlertView : UIView

- (instancetype)initWithSize:(CGSize)size;

- (void)show:(void(^)())completion;

@end
