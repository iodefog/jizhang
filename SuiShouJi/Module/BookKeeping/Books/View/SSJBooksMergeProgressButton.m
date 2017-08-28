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

@property (nonatomic, strong) NSTimer *animationTimer;

@property (nonatomic, strong) UIView *backColorView;

@property (nonatomic, strong) UIView *backWhiteView;

@property (nonatomic) BOOL isAnimating;

@property (nonatomic) double currentTime;


@end


@implementation SSJBooksMergeProgressButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleFont = [UIFont systemFontOfSize:SSJ_FONT_SIZE_2];
        self.titleColor = [UIColor whiteColor];
        [self addSubview:self.backGroundImage];
        [self addSubview:self.titleLab];
        [self addSubview:self.backWhiteView];
        [self addSubview:self.backColorView];
        self.clipsToBounds = YES;
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
        _fishImage.contents = (id)[UIImage imageNamed:@"book_transfer_fish"].CGImage;
        _fishImage.size = CGSizeMake(50, 29);
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
        _fishAnimation.duration = 2;
        _fishAnimation.removedOnCompletion = YES;
        _fishAnimation.delegate = self;
    }
    return _fishAnimation;
}

- (UIImageView *)backGroundImage {
    if (!_backGroundImage) {
        _backGroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _backGroundImage.image = [UIImage imageNamed:@"book_transfer_bg"];
        _backGroundImage.hidden = YES;
    }
    return _backGroundImage;
}


- (NSTimer *)animationTimer {
    if (!_animationTimer) {
        _animationTimer = [NSTimer timerWithTimeInterval:0.01 target:self selector:@selector(updateTheFishPosition) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSRunLoopCommonModes];
    }
    return _animationTimer;
}

- (UIView *)backColorView {
    if (!_backColorView ) {
        _backColorView = [[UIView alloc] init];
        _backColorView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        _backColorView.hidden = YES;
    }
    return _backColorView;
}

- (UIView *)backWhiteView {
    if (!_backWhiteView ) {
        _backWhiteView = [[UIView alloc] init];
        _backWhiteView.backgroundColor = [UIColor whiteColor];
        _backWhiteView.hidden = YES;
    }
    return _backWhiteView;

}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLab.text = _title;
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        self.isAnimating = NO;
        [self.animationTimer invalidate];
        self.animationTimer = nil;
        self.backGroundImage.hidden = YES;
        self.backColorView.hidden = YES;
        self.backWhiteView.hidden = YES;
        [self.fishImage removeFromSuperlayer];
        if (self.isSuccess) {
            self.title = @"迁移成功";
        } else {
            self.title = @"迁移失败";
        }
    }
}

- (void)animationDidStart:(CAAnimation *)anim {
    [self.animationTimer fire];
    self.currentTime = 0;
}


#pragma mark 动画暂停
- (void)animationPause{
    //取得指定图层动画的媒体时间，后面参数用于指定子图层，这里不需要
    CFTimeInterval interval=[_fishImage convertTime:CACurrentMediaTime() fromLayer:nil];
    //设置时间偏移量，保证暂停时停留在旋转的位置
    [_fishImage setTimeOffset:interval];
    
    _isAnimating = NO;;
    //速度设置为0，暂停动画
    _fishImage.speed=0;
}

#pragma mark 动画恢复
- (void)animationResume{
    //获得暂停的时间
    CFTimeInterval beginTime = CACurrentMediaTime() - _fishImage.timeOffset;
    //设置偏移量
    _fishImage.timeOffset = 0;
    //设置开始时间
    _fishImage.beginTime = beginTime;
    //设置动画速度，开始运动
    _fishImage.speed=1.0;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isAnimating) {
        if (self.mergeButtonClickBlock) {
            self.mergeButtonClickBlock();
        }
    }
}

- (void)startAnimating {
    if ([self.title isEqualToString:@"迁移"] || [self.title isEqualToString:@"迁移失败"]) {
        [self.fishImage addAnimation:self.fishAnimation forKey:@"fishAnimation"];
        self.backGroundImage.frame = CGRectMake(0, 0, self.width, self.height);
        self.isAnimating = !self.isAnimating;
        self.titleLab.text = @"";
        self.backGroundImage.hidden = NO;
        self.backColorView.hidden = NO;
        self.backWhiteView.hidden = NO;
        [self.layer addSublayer:self.fishImage];
    }
}

- (void)updateTheFishPosition {
    self.currentTime += 0.01;
    self.backColorView.frame = CGRectMake(self.fishImage.presentationLayer.position.x + 20, 0, self.width - self.fishImage.presentationLayer.position.x - 20, self.height);
    self.backWhiteView.frame = CGRectMake(self.fishImage.presentationLayer.position.x + 20, 0, self.width - self.fishImage.presentationLayer.position.x - 20, self.height);
    double currentPercent = self.backGroundImage.frame.size.width / self.width;
    if (currentPercent >= 0.8 && !_progressDidCompelete) {
        [self animationPause];
    }
}

- (void)setProgressDidCompelete:(BOOL)progressDidCompelete {
    _progressDidCompelete = progressDidCompelete;
    if (progressDidCompelete && !_isAnimating) {
        [self animationResume];
    }
}

- (void)setIsSuccess:(BOOL)isSuccess {
    _isSuccess = isSuccess;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
