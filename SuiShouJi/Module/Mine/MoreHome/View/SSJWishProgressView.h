//
//  SSJWishProgressView.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJWishProgressView : UIView
- (instancetype)initWithFrame:(CGRect)frame proColor:(UIColor *)proColor trackColor:(UIColor *)trackColor;


-(void)setProgress:(double)progress withAnimation:(BOOL)isAnimation;

/**进度条颜色*/
@property (nonatomic, strong) UIColor *progressColor;
@end
