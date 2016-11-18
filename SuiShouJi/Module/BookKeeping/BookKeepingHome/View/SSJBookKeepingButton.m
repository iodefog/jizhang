
//
//  SSJBookKeepingButton.m
//  SuiShouJi
//
//  Created by ricky on 16/4/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//


#define Angle2Radian(angle) ((angle) / 180.0 * M_PI)

static NSString *const kLodingViewAnimationKey = @"lodingViewAnimationKey";

#import "SSJBookKeepingButton.h"

@interface SSJBookKeepingButton()
@property(nonatomic, strong) UIButton *recordMakingButton;
@property(nonatomic, strong) CAGradientLayer *loadingLayer;
@property(nonatomic, strong) UIView *pointView;
@property(nonatomic, strong) UIImageView *lineImage;
@property(nonatomic, strong) UIImageView *penImage;
@end

@implementation SSJBookKeepingButton{
    CFAbsoluteTime _startTime;
    CFAbsoluteTime _endTime;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.recordMakingButton];
        [self addSubview:self.penImage];
        [self addSubview:self.lineImage];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.recordMakingButton.frame = self.bounds;
    self.penImage.size = CGSizeMake(65, 65);
    self.penImage.center = CGPointMake(self.width / 2, self.height / 2);
    self.lineImage.size = CGSizeMake(39, 7);
    self.lineImage.top = self.penImage.bottom - 2;
    self.lineImage.centerX = self.width / 2;
}

-(UIButton *)recordMakingButton{
    if (!_recordMakingButton) {
        _recordMakingButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _recordMakingButton.layer.cornerRadius = self.width / 2;
        _recordMakingButton.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.recordHomeBorderColor].CGColor;
        _recordMakingButton.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.recordHomeButtonBackgroundColor];
        _recordMakingButton.layer.borderWidth = 2.0f;
        [_recordMakingButton addTarget:self action:@selector(recordMakingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordMakingButton;
}

-(UIImageView *)penImage{
    if (!_penImage) {
        _penImage = [[UIImageView alloc]init];
        _penImage.image = [UIImage ssj_themeImageWithName:@"home_pen"];
    }
    return _penImage;
}

-(UIImageView *)lineImage{
    if (!_lineImage) {
        _lineImage = [[UIImageView alloc]init];
        _lineImage.image = [UIImage ssj_themeImageWithName:@"home_line"];
    }
    return _lineImage;
}

//-(CAGradientLayer *)loadingLayer{
//    if (!_loadingLayer) {
//        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.width/2, self.height/2) radius:(self.width-kPROGRESS_LINE_WIDTH)/2 startAngle:degreesToRadians(0) endAngle:degreesToRadians(360) clockwise:YES];
//        CAShapeLayer *progressLayer = [CAShapeLayer layer];
//        progressLayer.frame = self.bounds;
//        progressLayer.fillColor =  [[UIColor clearColor] CGColor];
//        progressLayer.strokeColor=[UIColor redColor].CGColor;
//        progressLayer.lineCap = kCALineCapRound;
//        progressLayer.lineWidth = kPROGRESS_LINE_WIDTH;
//        progressLayer.path = path.CGPath;
//        _loadingLayer =  [CAGradientLayer layer];
//        _loadingLayer.frame = progressLayer.frame;
//        [_loadingLayer setColors:[NSArray arrayWithObjects:(id)[[UIColor ssj_colorWithHex:@"ffea01"] CGColor],(id)[[UIColor whiteColor] CGColor], nil]];
//        [_loadingLayer setLocations:@[@0,@0.5]];
//        [_loadingLayer setStartPoint:CGPointMake(0, 0)];
//        [_loadingLayer setEndPoint:CGPointMake(1, 0)];
//        [_loadingLayer setMask:progressLayer];
//        _loadingLayer.hidden = YES;
//    }
//    return _loadingLayer;
//}
//
//-(UIView *)pointView{
//    if (!_pointView) {
//        _pointView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 8)];
//        _pointView.layer.borderColor = [UIColor ssj_colorWithHex:@"ffea01"].CGColor;
//        _pointView.layer.borderWidth = 3.0f;
//        _pointView.layer.cornerRadius = 4.0f;
//        _pointView.backgroundColor = [UIColor whiteColor];
//        _pointView.hidden = YES;
//    }
//    return _pointView;
//}

//-(void)startLoading{
//    _startTime = CFAbsoluteTimeGetCurrent();
//    
//    [MobClick event:@"15"];
//    
//    self.recordMakingButton.layer.borderColor = [UIColor clearColor].CGColor;
//
//    
//    self.pointView.hidden = NO;
//    
//    self.loadingLayer.hidden = NO;
//    
//    CABasicAnimation *animation = [ CABasicAnimation
//                                   animationWithKeyPath: @"transform.rotation.z"];
//    
//    animation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
//    
//    animation.duration = kAnimationDuration;
//
//    animation.cumulative = YES;
//    
//    animation.repeatCount = 3;
//    
//    animation.removedOnCompletion = NO;
//    
//    animation.delegate = self;
//    
//    [self.pointView.layer addAnimation:animation forKey:kPointViewAnimationKey];
//    
//    [self.loadingLayer addAnimation:animation forKey:kLodingViewAnimationKey];
//    
//}
//
//- (void)stopLoading{
//    _endTime = CFAbsoluteTimeGetCurrent();
//    
//    double secondInterval = _endTime - _startTime;
//    
//    if (secondInterval > kAnimationDuration) {
//        self.recordMakingButton.layer.borderColor = [UIColor ssj_colorWithHex:@"26dcc5"].CGColor;
//        
//        [self.pointView.layer removeAnimationForKey:kPointViewAnimationKey];
//        
//        [self.loadingLayer removeAnimationForKey:kLodingViewAnimationKey];
//        
//        self.pointView.hidden = YES;
//        
//        self.loadingLayer.hidden = YES;
//        
//        if (self.animationStopBlock) {
//            self.animationStopBlock();
//        }
//    }else{
//        __weak typeof(self) weakSelf = self;
//        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, (kAnimationDuration - secondInterval) *NSEC_PER_SEC);
//        dispatch_after(time, dispatch_get_main_queue(), ^{
//            weakSelf.recordMakingButton.layer.borderColor = [UIColor ssj_colorWithHex:@"26dcc5"].CGColor;
//            
//            [weakSelf.pointView.layer removeAnimationForKey:kPointViewAnimationKey];
//            
//            [weakSelf.loadingLayer removeAnimationForKey:kLodingViewAnimationKey];
//            
//            weakSelf.pointView.hidden = YES;
//            
//            weakSelf.loadingLayer.hidden = YES;
//            
//            if (self.animationStopBlock) {
//                self.animationStopBlock();
//            }
//        });
//    }
//    _startTime = 0;
//}

// 抖动动画
- (void)startAnimating
{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    anim.keyPath = @"transform.rotation";
    
    anim.values = @[@(Angle2Radian(-25)),  @(Angle2Radian(25)), @(Angle2Radian(-25))];
    anim.duration = 0.5;
    // 动画的重复执行次数
    anim.repeatCount = MAXFLOAT;
    
    // 保持动画执行完毕后的状态
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    
    [self.penImage.layer addAnimation:anim forKey:kLodingViewAnimationKey];
}

- (void)stopLoading{
    [self.penImage.layer removeAnimationForKey:kLodingViewAnimationKey];
    
}


-(void)recordMakingButtonClicked:(id)sender{
    if (self.recordMakingClickBlock) {
        self.recordMakingClickBlock();
    }
}

- (void)updateAfterThemeChange{
    self.recordMakingButton.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.recordHomeBorderColor].CGColor;
    self.penImage.image = [UIImage ssj_themeImageWithName:@"home_pen"];
    self.recordMakingButton.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.recordHomeButtonBackgroundColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
