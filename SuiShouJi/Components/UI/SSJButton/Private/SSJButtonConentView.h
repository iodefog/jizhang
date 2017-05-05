//
//  SSJButtonConentView.h
//  SuiShouJi
//
//  Created by old lang on 17/3/19.
//  Copyright © 2017年 MZL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJButtonConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSJButtonConentView : UIView

@property (nonatomic, strong, readonly) UILabel *titleLabel;

@property (nonatomic, strong, readonly) UIImageView *imageView;

@property (nonatomic, strong, readonly) UIImageView *backgroundImageView;

@property (nonatomic) SSJButtonLayoutStyle layoutStyle;

@property (nonatomic) CGFloat spaceBetweenImageAndTitle;

@property (nonatomic) UIEdgeInsets titleInset;

@property (nonatomic) UIEdgeInsets imageInset;

@end

NS_ASSUME_NONNULL_END
