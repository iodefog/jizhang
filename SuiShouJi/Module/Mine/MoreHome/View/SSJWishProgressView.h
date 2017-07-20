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

/**进度*/
@property (nonatomic, assign) float progress;
@end
