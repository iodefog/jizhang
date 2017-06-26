//
//  SSJMineSyncButton.m
//  SuiShouJi
//
//  Created by ricky on 16/5/12.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#define Angle2Radian(angle) ((angle) / 180.0 * M_PI)

static NSString *const kCircleAnimationKey = @"circleAnimationKey";

#import "SSJMineSyncButton.h"
#import "SSJDataSynchronizer.h"

@interface SSJMineSyncButton()
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UIButton *syncButton;
@property(nonatomic, strong) UIImageView *cloudImage;
@property(nonatomic, strong) UIImageView *arrowImage;
@property(nonatomic, strong) UILabel *titleLabel;
@end

@implementation SSJMineSyncButton{
    CFAbsoluteTime _startTime;
    CFAbsoluteTime _endTime;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.cloudImage];
        [self addSubview:self.titleLabel];
        [self addSubview:self.arrowImage];
        [self addSubview:self.containerView];
        [self addSubview:self.syncButton];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.containerView.size = CGSizeMake(self.cloudImage.width + self.titleLabel.width + 5, self.height);
    self.containerView.center = CGPointMake(self.width / 2, self.height / 2);
    self.cloudImage.centerY = self.height / 2;
    self.cloudImage.left = self.containerView.left;
    self.titleLabel.centerY = self.height / 2;
    self.titleLabel.right = self.containerView.right;
    self.arrowImage.centerX = self.cloudImage.centerX;
    self.arrowImage.centerY = self.cloudImage.centerY + 6 ;
    self.syncButton.frame = self.bounds;
}

-(UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc]init];
        _containerView.backgroundColor = [UIColor clearColor];
    }
    return _containerView;
}

-(UIButton *)syncButton{
    if (!_syncButton) {
        _syncButton = [[UIButton alloc]init];
        [_syncButton addTarget:self action:@selector(syncButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _syncButton;
}

-(UIImageView *)arrowImage{
    if (!_arrowImage) {
        _arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 8, 10)];
        _arrowImage.image = [[UIImage imageNamed:@"more_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _arrowImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.moreHomeTitleColor];
        _arrowImage.hidden = YES;
    }
    return _arrowImage;
}

-(UIImageView *)cloudImage{
    if (!_cloudImage) {
        _cloudImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 26, 26)];
        _cloudImage.image = [[UIImage imageNamed:@"more_tongbu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _cloudImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.moreHomeTitleColor];
    }
    return _cloudImage;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"云同步";
        _titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.moreHomeTitleColor];
        _titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

-(void)syncButtonClicked:(id)sender{
    BOOL shouldSync = YES;
    if (_shouldSyncBlock) {
        shouldSync = _shouldSyncBlock();
    }
    
    if (!shouldSync) {
        return;
    }
    
    [self startAnimation];
    _startTime = CFAbsoluteTimeGetCurrent();
    self.titleLabel.text = @"同步中";
    [[SSJDataSynchronizer shareInstance]startSyncWithSuccess:^(SSJDataSynchronizeType type){
        if (type == SSJDataSynchronizeTypeData) {
            _endTime = CFAbsoluteTimeGetCurrent();
            float animationDuration = _endTime - _startTime;
            if (animationDuration < 2) {
                dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, (2 - animationDuration) *NSEC_PER_SEC);
                dispatch_after(time, dispatch_get_main_queue(), ^{
                    [self stopAnimation];
                    self.cloudImage.image = [[UIImage imageNamed:@"more_tongbu_s"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    self.titleLabel.text = @"同步成功";
                    [self.titleLabel sizeToFit];
                    dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 1 *NSEC_PER_SEC);
                    dispatch_after(time, dispatch_get_main_queue(), ^{
                        self.cloudImage.image = [[UIImage imageNamed:@"more_tongbu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        self.titleLabel.text = @"云同步";
                    });
                });
            }else{
                [self stopAnimation];
                self.cloudImage.image = [[UIImage imageNamed:@"more_tongbu_s"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                self.titleLabel.text = @"同步成功";
                [self.titleLabel sizeToFit];
                dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 1 *NSEC_PER_SEC);
                dispatch_after(time, dispatch_get_main_queue(), ^{
                    self.cloudImage.image = [[UIImage imageNamed:@"more_tongbu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    self.titleLabel.text = @"云同步";
                });
            }
        }
    }failure:^(SSJDataSynchronizeType type, NSError *error) {
        [self stopAnimation];
        self.cloudImage.image = [[UIImage imageNamed:@"more_tongbu_f"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.titleLabel.text = @"同步失败";
        [self.titleLabel sizeToFit];
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 1 *NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            self.cloudImage.image = [[UIImage imageNamed:@"more_tongbu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.titleLabel.text = @"云同步";
        });
    }];

}

-(void)startAnimation{
    self.cloudImage.image = [[UIImage imageNamed:@"more_tongbuing"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.arrowImage.hidden = NO;
    CAKeyframeAnimation *arrowAnimation =[CAKeyframeAnimation animation];
    arrowAnimation.keyPath = @"transform.translation.y";
    arrowAnimation.duration= 1;
    arrowAnimation.repeatCount = HUGE;
    arrowAnimation.removedOnCompletion = NO;
    arrowAnimation.values = @[@(-2),@(2),@(-2)];

    [self.arrowImage.layer addAnimation:arrowAnimation forKey:kCircleAnimationKey];
}

-(void)stopAnimation{
    self.arrowImage.hidden = YES;
//    self.cloudImage.image = [UIImage imageNamed:@"more_tongbu"];
//    self.titleLabel.text = @"云同步";
    [self.arrowImage.layer removeAnimationForKey:kCircleAnimationKey];
}

- (void)updateAfterThemeChange{
    self.arrowImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.moreHomeTitleColor];
    self.cloudImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.moreHomeTitleColor];
    self.titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.moreHomeTitleColor];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
