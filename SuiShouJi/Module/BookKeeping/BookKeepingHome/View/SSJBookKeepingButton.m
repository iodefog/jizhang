
//
//  SSJBookKeepingButton.m
//  SuiShouJi
//
//  Created by ricky on 16/4/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

static const float kPROGRESS_LINE_WIDTH=4.0;

#import "SSJBookKeepingButton.h"

@interface SSJBookKeepingButton()
@property(nonatomic, strong) UIButton *recordMakingButton;
@property(nonatomic, strong) CAGradientLayer *loadingLayer;
@property(nonatomic, strong) UIView *pointView;
@end

@implementation SSJBookKeepingButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
    [_pointView.layer setAnchorPoint:CGPointMake(0.5, 44.0 / 8 + 0.5)];
    self.recordMakingButton.frame = self.bounds;
}

-(UIButton *)recordMakingButton{
    if (!_recordMakingButton) {
        _recordMakingButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        [_recordMakingButton setImage:[UIImage imageNamed:@"home_pen"] forState:UIControlStateNormal];
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
        _pointView.hidden = YES;
    }
    return _pointView;
}

-(void)startLoading{
    self.pointView.hidden = NO;
    
    self.loadingLayer.hidden = NO;
    
    CABasicAnimation *animation = [ CABasicAnimation
                                   animationWithKeyPath: @"transform.rotation.z" ];
    
    animation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
    
    animation.duration = 3;

    animation.cumulative = YES;
    
    animation.repeatCount = HUGE;
    
    [self.pointView.layer addAnimation:animation forKey:nil];
    
    [self.loadingLayer addAnimation:animation forKey:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
