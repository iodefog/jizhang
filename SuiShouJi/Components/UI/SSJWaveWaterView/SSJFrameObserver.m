//
//  SSJFrameObserver.m
//  SSJWaveWaterDemo
//
//  Created by old lang on 16/3/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFrameObserver.h"

@interface SSJFrameObserver ()

@property (nonatomic, strong) CADisplayLink *displayLinker;

@property (nonatomic, strong) UILabel *frameLab;

@end

@implementation SSJFrameObserver

+ (void)show {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    SSJFrameObserver *observer = [[SSJFrameObserver alloc] initWithFrame:CGRectMake(CGRectGetWidth(window.bounds) - 100, CGRectGetHeight(window.bounds) - 20, 100, 20)];
    [window addSubview:observer];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _frameLab = [[UILabel alloc] init];
        _frameLab.backgroundColor = [UIColor clearColor];
        _frameLab.font = [UIFont systemFontOfSize:16];
        _frameLab.textColor = [UIColor blackColor];
        _frameLab.textAlignment = NSTextAlignmentRight;
        
        _displayLinker = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateFrameLab)];
        [_displayLinker addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
    }
    return self;
}

- (void)layoutSubviews {
    _frameLab.frame = self.bounds;
}

- (void)updateFrameLab {
    NSLog(@"每秒刷新帧数：%d", (int)(1 / _displayLinker.duration));
//    _frameLab.text = [NSString stringWithFormat:@"每秒刷新帧数：%d", (int)(1 / _displayLinker.duration)];
}

@end
