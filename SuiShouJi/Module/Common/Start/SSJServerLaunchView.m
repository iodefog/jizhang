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
        _defaultView = [[UIImageView alloc] initWithImage:[UIImage ssj_compatibleImageNamed:@"default"]];
        _defaultView.frame = self.bounds;
        [self addSubview:_defaultView];
    }
    return self;
}

- (void)layoutSubviews {
    _defaultView.frame = _serverView.frame = self.bounds;
}

- (void)downloadImgWithUrl:(NSString *)imgUrl completion:(void (^)())completion {
    SDWebImageManager *manager = [[SDWebImageManager alloc] init];
    manager.imageDownloader.downloadTimeout = 2;
    
    NSURL *url = [NSURL URLWithString:SSJImageURLWithAPI(imgUrl)];
    [manager downloadImageWithURL:url options:SDWebImageContinueInBackground progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (!image || error) {
            _isCompleted = YES;
            if (completion) {
                completion();
            }
            return;
        }
        SSJDispatchMainSync(^{
            [UIView transitionWithView:self duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                if (!_serverView) {
                    _serverView = [[UIImageView alloc] initWithImage:image];
                    [self addSubview:_defaultView];
                }
            } completion:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _isCompleted = YES;
                    if (completion) {
                        completion();
                    }
                });
            }];
        });
    }];
}

@end
