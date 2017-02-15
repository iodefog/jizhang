//
//  SSJHeaderBannerImageView.h
//  SuiShouJi
//
//  Created by yi cai on 2016/12/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kBannerHeight 100
@class SSJBannerItem;

@protocol SSJHeaderBannerImageViewDelegate <NSObject>

- (void)pushToViewControllerWithUrl:(NSString *)urlStr title:(NSString *)title;
- (void)pushToViewControllerWithVC:(UIViewController *)vc;
- (void)closeBanner;

@end
@interface SSJHeaderBannerImageView : UICollectionReusableView

@property (nonatomic, strong) NSArray<SSJBannerItem *> *bannerItemArray;
@property (nonatomic, weak) id<SSJHeaderBannerImageViewDelegate> delegate;
@end
