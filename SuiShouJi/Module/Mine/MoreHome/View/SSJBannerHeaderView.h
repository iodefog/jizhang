//
//  SSJBannerHeaderView.h
//  SuiShouJi
//
//  Created by ricky on 16/7/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCYWinCowryHomeBannerView.h"

@interface SSJBannerHeaderView : UIView
@property(nonatomic, strong) NSArray *items;

//  点击关闭按钮的回调
typedef void (^closeButtonClickBlock)();

@property (nonatomic, copy) closeButtonClickBlock closeButtonClickBlock;

//  点击banner的回调
typedef void (^bannerClickedBlock)(NSString *url);

@property (nonatomic, copy) bannerClickedBlock bannerClickedBlock;

@property(nonatomic, strong) SCYWinCowryHomeBannerView *banner;

@end
