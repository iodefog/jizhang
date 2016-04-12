//
//  SSJStartView.m
//  SuiShouJi
//
//  Created by old lang on 16/3/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJStartView.h"

static const NSTimeInterval kTransitionDuration = 0.3;

@interface SSJStartView ()

//  默认的启动页
@property (nonatomic, strong) UIImageView *defaultView;

//  服务器下发的启动页
@property (nonatomic, strong) UIImageView *dynamicView;

@end

@implementation SSJStartView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.defaultView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.defaultView setImage:[UIImage ssj_compatibleImageNamed:@"default"]];
        [self addSubview:self.defaultView];
        
        self.dynamicView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.dynamicView];
    }
    return self;
}

- (void)layoutSubviews {
    self.defaultView.frame = self.bounds;
    self.dynamicView.frame = self.bounds;
}

- (void)showServerImageWithUrl:(NSURL *)url duration:(NSTimeInterval)duration finish:(void (^)())finish {
    __weak typeof(self) wself = self;
    SDWebImageManager *manager = [[SDWebImageManager alloc] init];
    manager.imageDownloader.downloadTimeout = 2;
    [manager downloadImageWithURL:url options:SDWebImageContinueInBackground progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (!wself) {
            return;
        }
        if (!image) {
            return;
        }
        dispatch_main_sync_safe(^{
            [UIView transitionWithView:wself duration:kTransitionDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                wself.dynamicView.image = image;
            } completion:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (finish) {
                        finish();
                    }
                });
            }];
        });
    }];
}

- (void)showTreeImage:(UIImage *)image duration:(NSTimeInterval)duration finish:(void (^)())finish {
    if (SSJIsFirstLaunchForCurrentVersion()) {
        [UIView transitionWithView:_defaultView duration:kTransitionDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            _defaultView.image = image;
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (finish) {
                    finish();
                }
            });
        }];
    } else {
        
    }
}

@end
