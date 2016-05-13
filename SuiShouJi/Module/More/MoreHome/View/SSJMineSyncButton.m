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
@interface SSJMineSyncButton()
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UIButton *syncButton;
@property(nonatomic, strong) UIImageView *cloudImage;
@property(nonatomic, strong) UIImageView *circleImage;
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
        [self addSubview:self.circleImage];
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
    self.circleImage.center = self.cloudImage.center;
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

-(UIImageView *)circleImage{
    if (!_circleImage) {
        _circleImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
        _circleImage.image = [UIImage imageNamed:@"more_tongbucircle"];
//        _circleImage.hidden = YES;
    }
    return _circleImage;
}

-(UIImageView *)cloudImage{
    if (!_cloudImage) {
        _cloudImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 26, 26)];
        _cloudImage.image = [UIImage imageNamed:@"more_tongbu"];
    }
    return _cloudImage;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"云同步";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

-(void)syncButtonClicked:(id)sender{
    [self startAnimation];
}

-(void)startAnimation{
    self.circleImage.hidden = NO;
    CABasicAnimation *circleAnimation =[CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    circleAnimation.duration=3;
    circleAnimation.repeatCount = HUGE;
    circleAnimation.removedOnCompletion = NO;
    circleAnimation.fromValue = [NSNumber numberWithFloat:0];
    circleAnimation.toValue = [NSNumber numberWithFloat:Angle2Radian(360)];
    [self.circleImage.layer addAnimation:circleAnimation forKey:kCircleAnimationKey];
}

-(void)stopAnimation{
    [self.circleImage.layer removeAnimationForKey:kCircleAnimationKey];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
