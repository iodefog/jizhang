//
//  SSJHomeLoadingView.m
//  SuiShouJi
//
//  Created by ricky on 2016/12/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJHomeLoadingView.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"

@interface SSJHomeLoadingView()

@property(nonatomic, strong) FLAnimatedImageView *loadingView;

@property(nonatomic, strong) UILabel *statusLab;

@property(nonatomic, strong) NSTimer *timer;

@end

@implementation SSJHomeLoadingView{
    NSInteger _currentSecond;
    CFAbsoluteTime _startTime;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.loadingView];
        [self addSubview:self.statusLab];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncCompleteHandler) name:SSJSyncDataSuccessNotification object:nil];
    }
    return self;
}

- (void)show {
    
    if (self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [keyWindow addSubview:self];
    
    self.size = CGSizeMake(keyWindow.width, keyWindow.height);
    
    _startTime = CFAbsoluteTimeGetCurrent();
    
    [self.timer fire];
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    
    [self removeFromSuperview];
    
    [self.timer invalidate];
    
    self.timer = nil;
    
    _currentSecond = 0;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.loadingView.center = CGPointMake(self.width / 2, self.height / 2);
    self.statusLab.centerX = self.width / 2;
    self.statusLab.top = self.loadingView.height + 10;
}

- (FLAnimatedImageView *)loadingView{
    if (!_loadingView) {
        _loadingView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, 180, 180)];
        NSData *gifData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"xiaomao" ofType:@"gif"]];
        _loadingView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:gifData];
    }
    return _loadingView;
}

- (UILabel *)statusLab{
    if (!_statusLab) {
        _statusLab = [[UILabel alloc] init];
        _statusLab.text = @"正在加载数据,请稍后...";
        _statusLab.font = [UIFont systemFontOfSize:16];
        _statusLab.textColor  = [UIColor ssj_colorWithHex:@"#333333"];
    }
    return _statusLab;
}

- (NSTimer *)timer{
    if (_timer) {
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateCurrentSecond) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

- (void)updateCurrentSecond{
    _currentSecond = _currentSecond + 1;
    if (_currentSecond > 8) {
        [self dismiss];
    }
}

- (void)syncCompleteHandler{
    CFAbsoluteTime _currentTime = CFAbsoluteTimeGetCurrent();
    if (_currentTime - _startTime > 2) {
        [self dismiss];
    } else {
        __weak typeof(self) weakSelf = self;
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, (2 - _currentTime) *NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [weakSelf dismiss];
        });
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
