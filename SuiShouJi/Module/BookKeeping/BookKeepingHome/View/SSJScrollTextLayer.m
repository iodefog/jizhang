//
//  SSJScrollTextLayer.m
//  SuiShouJi
//
//  Created by ricky on 16/4/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJScrollTextLayer.h"
@interface SSJScrollTextLayer()
@property(nonatomic, strong) NSTimer *timer;
@end
@implementation SSJScrollTextLayer{
    int _currentNum;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor].CGColor;
        _currentNum = 0;
        self.animationDuration = 1.0;
        self.foregroundColor = [UIColor blackColor].CGColor;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.string = [NSString stringWithFormat:@"%d",_currentNum];
        CATransition *transition = [[CATransition alloc]init];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromTop;
        self.actions = @{@"string":transition};
    }
    return self;
}

-(NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:self.animationDuration / [self.numStr intValue] target:self selector:@selector(changeNum) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
    return _timer;
}

-(void)changeNum{
    _currentNum ++;
    if (_currentNum > [self.numStr intValue]) {
        [self.timer invalidate];
    }else{
        self.string = [NSString stringWithFormat:@"%d",_currentNum];
    }
}

-(void)setNumStr:(NSString *)numStr{
    _numStr = numStr;
    [self.timer fire];
}

-(void)setTextFont:(int)textFont{
    _textFont = textFont;
    self.fontSize = _textFont;
}

-(void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    self.foregroundColor = self.textColor.CGColor;
}

-(void)setAnimationDuration:(float)animationDuration{
    _animationDuration = animationDuration;
}

@end
