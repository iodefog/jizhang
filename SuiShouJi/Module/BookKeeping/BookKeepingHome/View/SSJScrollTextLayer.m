//
//  SSJScrollTextLayer.m
//  SuiShouJi
//
//  Created by ricky on 16/4/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJScrollTextLayer.h"
@interface SSJScrollTextLayer()
@property(nonatomic, strong) CADisplayLink *timer;
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

-(CADisplayLink *)timer{
    if (!_timer) {
        _timer = [CADisplayLink displayLinkWithTarget:self
                                             selector:@selector(changeNum)];
    }
    return _timer;
}

-(void)changeNum{
    int randomNum = arc4random() % 10;
    self.string = [NSString stringWithFormat:@"%d",randomNum];
}

-(void)setNumStr:(NSString *)numStr{
    _numStr = numStr;
    [self.timer addToRunLoop:[NSRunLoop currentRunLoop]
                 forMode:NSDefaultRunLoopMode];
    __weak typeof(self) weakSelf = self;
    dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, self.animationDuration * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [weakSelf stopTimer];
    });
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

-(void)stopTimer{
    self.string = self.numStr;
    [self.timer invalidate];
    self.timer = nil;
}

@end
