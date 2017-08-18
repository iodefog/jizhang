//
//  SSJBooksAdView.h
//  SuiShouJi
//
//  Created by ricky on 16/11/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

SSJ_DEPRECATED
@interface SSJBooksAdView : UIView

@property(nonatomic, strong) UIImageView *adImageView;

//  点击关闭按钮的回调
typedef void (^closeButtonClickBlock)();

@property (nonatomic, copy) closeButtonClickBlock closeButtonClickBlock;

//  点击关闭按钮的回调
typedef void (^imageClickBlock)();

@property (nonatomic, copy) imageClickBlock imageClickBlock;

@end
