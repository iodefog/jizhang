//
//  SSJBooksMergeProgressButton.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBooksMergeProgressButton.h"

@interface SSJBooksMergeProgressButton()<CAAnimationDelegate>

@property (nonatomic, strong) UIBezierPath *animationPath;

@property (nonatomic, strong) UIImageView *backGroundImage;

@property (nonatomic, strong) CALayer *fishImage;

@property (nonatomic, strong) CAKeyframeAnimation *fishAnimation;

@property (nonatomic) BOOL isAnimating;


@end


@implementation SSJBooksMergeProgressButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleFont = [UIFont systemFontOfSize:SSJ_FONT_SIZE_2];
        self.titleColor = [UIColor whiteColor];
        [self addSubview:self.titleLab];
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    }
    return self;
}

- (void)updateConstraints {
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];
    
    [super updateConstraints];
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = self.titleFont;
        _titleLab.textColor = self.titleColor;
    }
    return _titleLab;
}

- (CALayer *)fishImage {
    if (!_fishImage) {
        _fishImage = [CALayer layer];
        _fishImage.contents = [UIImage imageNamed:@"book_transfer_fish"];
    }
    return _fishImage;
}

- (UIBezierPath *)animationPath {
    if (!_animationPath) {
        _animationPath = [UIBezierPath bezierPath];
        [_animationPath moveToPoint:CGPointMake(0,self.height / 2)];
        [_animationPath addCurveToPoint:CGPointMake(self.width, self.height / 2)
                      controlPoint1:CGPointMake(self.width / 4, self.height / 2 - 30)
                      controlPoint2:CGPointMake(self.width / 4 * 3, self.height / 2 + 30)];

    }
    return _animationPath;
}

- (CAKeyframeAnimation *)fishAnimation {
    if (!_fishAnimation) {
        _fishAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        _fishAnimation.path = self.animationPath.CGPath;
        _fishAnimation.calculationMode = kCAAnimationCubic;
        _fishAnimation.duration = 10;
        _fishAnimation.removedOnCompletion = YES;
        _fishAnimation.delegate = self;
    }
    return _fishAnimation;
}

- (UIImageView *)backGroundImage {
    if (!_backGroundImage) {
        _backGroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, self.height)];
        _backGroundImage.image = [UIImage imageNamed:@"book_transfer_fish"];
    }
    return _backGroundImage;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLab.text = _title;
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    }
}


#pragma mark 动画暂停
- (void)animationPause{
    //取得指定图层动画的媒体时间，后面参数用于指定子图层，这里不需要
    CFTimeInterval interval=[_fishImage convertTime:CACurrentMediaTime() fromLayer:nil];
    //设置时间偏移量，保证暂停时停留在旋转的位置
    [_fishImage setTimeOffset:interval];
    //速度设置为0，暂停动画
    _fishImage.speed=0;
}

#pragma mark 动画恢复
- (void)animationResume{
    //获得暂停的时间
    CFTimeInterval beginTime = CACurrentMediaTime() - _fishImage.timeOffset;
    //设置偏移量
    _fishImage.timeOffset=0;
    //设置开始时间
    _fishImage.beginTime=beginTime;
    //设置动画速度，开始运动
    _fishImage.speed=1.0;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isAnimating) {
        self.isAnimating = !self.isAnimating;
        self.backgroundColor = [UIColor whiteColor];
        self.titleLab.text = @"";
        [self.fishImage addAnimation:self.fishAnimation forKey:@"fishAnimation"];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
