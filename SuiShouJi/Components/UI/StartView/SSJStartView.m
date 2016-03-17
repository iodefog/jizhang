//
//  SSJStartView.m
//  SuiShouJi
//
//  Created by old lang on 16/3/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJStartView.h"

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

- (void)showWithUrl:(NSURL *)url duration:(NSTimeInterval)duration finish:(void (^)())finish {
    [self.dynamicView sd_setImageWithURL:url placeholderImage:nil options:SDWebImageAvoidAutoSetImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image || error) {
            if (finish) {
                finish();
            }
            return;
        }
        
        [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.dynamicView setImage:image];
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (finish) {
                    finish();
                }
            });
        }];
    }];
}

@end
