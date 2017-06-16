//
//  SSJServerLaunchView.m
//  SuiShouJi
//
//  Created by old lang on 16/4/15.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJServerLaunchView.h"



@interface SSJServerLaunchView ()

@property (nonatomic, strong) UIImageView *defaultView;

@property (nonatomic, strong) UIImageView *serverView;

@property (nonatomic) BOOL isCompleted;

@end

@implementation SSJServerLaunchView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //_defaultView = [[UIImageView alloc] initWithImage:[UIImage ssj_compatibleImageNamed:@"default"]];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            UIImage *image;
            if (CGSizeEqualToSize(screenSize, CGSizeMake(320.0, 480.0))) {
                image = [YYImage imageNamed:@"ani@960.webp"];
            } else {
                image = [YYImage imageNamed:@"ani.webp"];
            }
            _defaultView = [[YYAnimatedImageView alloc] initWithImage:image];
            _defaultView.frame = self.bounds;
            [self addSubview:_defaultView];
        }
    }
    return self;
}

- (void)layoutSubviews {
    _defaultView.frame = _serverView.frame = self.bounds;
}

- (void)downloadImgWithUrl:(NSString *)imgUrl completion:(void (^)())completion {
    [self downloadImgWithUrl:imgUrl timeout:60 completion:completion];
}

- (void)downloadImgWithUrl:(NSString *)imgUrl timeout:(NSTimeInterval)timeout completion:(void (^)())completion {
    
#ifdef DEBUG
    [CDAutoHideMessageHUD showMessage:@"开始下载服务端下发启动页"];
#endif
    SDWebImageManager *manager = [[SDWebImageManager alloc] init];
//    manager.imageDownloader.downloadTimeout = timeout;
    NSURL *url = [NSURL URLWithString:SSJImageURLWithAPI(imgUrl)];
    [manager.imageDownloader downloadImageWithURL:url options:(SDWebImageContinueInBackground | SDWebImageAllowInvalidSSLCertificates) progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        if (!image || error) {
#ifdef DEBUG
            [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"下载服务端下发启动页失败，error:%@", [error localizedDescription]]];
#endif
            if (!_isCompleted) {
                _isCompleted = YES;
                if (completion) {
                    completion();
                }
            }
            
            return;
        }
#ifdef DEBUG
        [CDAutoHideMessageHUD showMessage:@"下载服务端下发启动页成功"];
#endif
        SSJDispatchMainSync(^{
            if (!_isCompleted) {
                _isCompleted = YES;
                [UIView transitionWithView:self duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    if (!_serverView) {
                        _serverView = [[UIImageView alloc] initWithImage:image];
                        [self addSubview:_serverView];
                    }
                } completion:^(BOOL finished) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (completion) {
                            completion();
                        }
                    });
                }];
            }
        });
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!_isCompleted) {
            _isCompleted = YES;
            if (completion) {
                completion();
            }
        }
    });
}

@end
