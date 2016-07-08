//
//  SCYWinCowryHomeBannerView.h
//  YYDB
//
//  Created by old lang on 15/10/30.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

//  横向滚动广告视图

#import <UIKit/UIKit.h>

@class SCYWinCowryHomeBannerView;

/**
 *  点击图片的回调
 *
 *  @param view banner视图
 *  @param tapIndex 点击图片的下标
 */
typedef void(^SCYWinCowryHomeBannerViewTapAction)(SCYWinCowryHomeBannerView *view, NSUInteger tapIndex);

@interface SCYWinCowryHomeBannerView : UIView

//  图片url数组
@property (nonatomic, strong) NSArray <NSString *>*imageUrls;

//  点击图片的回调
@property (nonatomic, copy) SCYWinCowryHomeBannerViewTapAction tapAction;

//  开始自动滚动
- (void)beginAutoRoll;

//  停止自动滚动
- (void)stopAutoRoll;

@end
