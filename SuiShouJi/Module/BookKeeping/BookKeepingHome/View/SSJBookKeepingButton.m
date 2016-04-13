
//
//  SSJBookKeepingButton.m
//  SuiShouJi
//
//  Created by ricky on 16/4/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

static const float kPROGRESS_LINE_WIDTH=4.0;

static const float kAnimationDuration = 3.0;


static NSString *const kLodingViewAnimationKey = @"lodingViewAnimationKey";

static NSString *const kPointViewAnimationKey = @"pointViewAnimationKey";

#import "SSJBookKeepingButton.h"

@interface SSJBookKeepingButton()
@property(nonatomic, strong) UIButton *recordMakingButton;
@property(nonatomic, strong) CAGradientLayer *loadingLayer;
@property(nonatomic, strong) UIView *pointView;
@end

@implementation SSJBookKeepingButton{
    CFAbsoluteTime _startTime;
    CFAbsoluteTime _endTime;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _startTime = CFAbsoluteTimeGetCurrent();
        self.backgroundColor = [UIColor whiteColor];
        [self.layer addSublayer:self.loadingLayer];
        [self addSubview:self.recordMakingButton];
        [self addSubview:self.pointView];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.pointView.center = CGPointMake(self.width / 2, self.height / 2);
    [_pointView.layer setAnchorPoint:CGPointMake(0.5, 48.f / 8 + 0.5)];
    self.recordMakingButton.frame = self.bounds;
}

-(UIButton *)recordMakingButton{
    if (!_recordMakingButton) {
        _recordMakingButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        [_recordMakingButton setImage:[UIImage imageNamed:@"home_pen"] forState:UIControlStateNormal];
        [_recordMakingButton setImage:[UIImage imageNamed:@"home_pen"] forState:UIControlStateHighlighted]; 
        _recordMakingButton.layer.cornerRadius = self.width / 2;
        _recordMakingButton.layer.borderColor = [UIColor ssj_colorWithHex:@"47cfbe"].CGColor;
        _recordMakingButton.layer.borderWidth = 2.0f;
        [_recordMakingButton addTarget:self action:@selector(recordMakingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordMakingButton;
}

-(CAGradientLayer *)loadingLayer{
    if (!_loadingLayer) {
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.width/2, self.height/2) radius:(self.width-kPROGRESS_LINE_WIDTH)/2 startAngle:degreesToRadians(0) endAngle:degreesToRadians(360) clockwise:YES];
        CAShapeLayer *progressLayer = [CAShapeLayer layer];
        progressLayer.frame = self.bounds;
        progressLayer.fillColor =  [[UIColor clearColor] CGColor];
        progressLayer.strokeColor=[UIColor redColor].CGColor;
        progressLayer.lineCap = kCALineCapRound;
        progressLayer.lineWidth = kPROGRESS_LINE_WIDTH;
        progressLayer.path = path.CGPath;
        _loadingLayer =  [CAGradientLayer layer];
        _loadingLayer.frame = progressLayer.frame;
        [_loadingLayer setColors:[NSArray arrayWithObjects:(id)[[UIColor ssj_colorWithHex:@"ffea01"] CGColor],(id)[[UIColor whiteColor] CGColor], nil]];
        [_loadingLayer setLocations:@[@0,@0.5]];
        [_loadingLayer setStartPoint:CGPointMake(0, 0)];
        [_loadingLayer setEndPoint:CGPointMake(1, 0)];
        [_loadingLayer setMask:progressLayer];
        _loadingLayer.hidden = YES;
    }
    return _loadingLayer;
}

-(UIView *)pointView{
    if (!_pointView) {
        _pointView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 8)];
        _pointView.layer.borderColor = [UIColor ssj_colorWithHex:@"ffea01"].CGColor;
        _pointView.layer.borderWidth = 3.0f;
        _pointView.layer.cornerRadius = 4.0f;
        _pointView.backgroundColor = [UIColor whiteColor];
        _pointView.hidden = YES;
    }
    return _pointView;
}

-(void)startLoading{
    _startTime = CFAbsoluteTimeGetCurrent();
    
    self.recordMakingButton.layer.borderColor = [UIColor clearColor].CGColor;

    
    self.pointView.hidden = NO;
    
    self.loadingLayer.hidden = NO;
    
    CABasicAnimation *animation = [ CABasicAnimation
                                   animationWithKeyPath: @"transform.rotation.z" ];
    
    animation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
    
    animation.duration = kAnimationDuration;

    animation.cumulative = YES;
    
    animation.repeatCount = HUGE;
    animation.removedOnCompletion = NO;
    
    [self.pointView.layer addAnimation:animation forKey:kPointViewAnimationKey];
    
    [self.loadingLayer addAnimation:animation forKey:kLodingViewAnimationKey];
}

- (void)stopLoading{
    _endTime = CFAbsoluteTimeGetCurrent();
    
    NSLog(@"time cost: %0.3f", _endTime - _startTime);
    
    double secondInterval = _endTime - _startTime;
    
    if (secondInterval > kAnimationDuration) {
        self.recordMakingButton.layer.borderColor = [UIColor ssj_colorWithHex:@"47cfbe"].CGColor;
        
        [self.pointView.layer removeAnimationForKey:kPointViewAnimationKey];
        
        [self.loadingLayer removeAnimationForKey:kLodingViewAnimationKey];
        
        self.pointView.hidden = YES;
        
        self.loadingLayer.hidden = YES;
        
        if (self.animationStopBlock) {
            self.animationStopBlock();
        }
    }else{
        __weak typeof(self) weakSelf = self;
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, (kAnimationDuration - secondInterval) *NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            weakSelf.recordMakingButton.layer.borderColor = [UIColor ssj_colorWithHex:@"47cfbe"].CGColor;
            
            [weakSelf.pointView.layer removeAnimationForKey:kPointViewAnimationKey];
            
            [weakSelf.loadingLayer removeAnimationForKey:kLodingViewAnimationKey];
            
            weakSelf.pointView.hidden = YES;
            
            weakSelf.loadingLayer.hidden = YES;
            
            if (self.animationStopBlock) {
                self.animationStopBlock();
            }
        });
    }
    _startTime = CFAbsoluteTimeGetCurrent();
}

-(void)recordMakingButtonClicked:(id)sender{
    if (self.recordMakingClickBlock) {
        self.recordMakingClickBlock();
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
