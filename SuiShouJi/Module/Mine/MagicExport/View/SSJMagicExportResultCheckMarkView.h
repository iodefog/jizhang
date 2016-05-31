//
//  SSJMagicExportResultCheckMarkView.h
//  SuiShouJi
//
//  Created by old lang on 16/4/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJMagicExportResultCheckMarkView : UIView

@property (nonatomic, readonly) CGFloat radius;

- (instancetype)initWithRadius:(CGFloat)radius;

- (void)startAnimation:(void (^)())finish;

@end
