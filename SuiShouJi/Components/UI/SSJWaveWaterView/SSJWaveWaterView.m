//
//  SSJWaveWaterView.m
//  SSJWaveWaterDemo
//
//  Created by old lang on 16/3/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJWaveWaterView.h"
#import "SSJWaveWaterPath.h"

#warning test
#import "SSJViewAddition.h"

NSString *const SSJWaveWaterFirstColorKey = @"SSJWaveWaterFirstColorKey";
NSString *const SSJWaveWaterSecondColorKey = @"SSJWaveWaterSecondColorKey";

@interface SSJWaveWaterView ()

// 定时器
@property (nonatomic, strong) CADisplayLink *waveDisplaylink;

@property (nonatomic, strong) NSMutableArray *wavePaths;

@property (nonatomic) NSUInteger pathCounter;

@end

@implementation SSJWaveWaterView

- (instancetype)initWithRadius:(CGFloat)radius {
    if (self = [super initWithFrame:CGRectMake(0, 0, radius, radius)]) {
        self.borderWidth = 1;
        self.borderColor = [UIColor orangeColor];
        self.backgroundColor = [UIColor whiteColor];
        _wavePaths = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)layoutSubviews {
    [self reloadWavePaths];
}

- (void)drawRect:(CGRect)rect {
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    [self clipContext];
    
    for (SSJWaveWaterPath *path in _wavePaths) {
        [path drawPath];
//        [path drawWavePath];
    }
}

- (void)setItems:(NSArray *)items {
    if (![_items isEqualToArray:items]) {
        _items = items;
        [self reloadWavePaths];
    }
}

- (void)reloadWavePaths {
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    [_wavePaths removeAllObjects];
    for (SSJWaveWaterViewItem *item in _items) {
        @autoreleasepool {
            SSJWaveWaterPath *path = [SSJWaveWaterPath pathWithItem:item size:self.size];
            [_wavePaths addObject:path];
        }
    }
}

- (void)startWave {
    if (_waveDisplaylink == nil) {
//         启动定时调用
        _waveDisplaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawWave:)];
        _waveDisplaylink.frameInterval = 5;
        [_waveDisplaylink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stopWave {
    if (_waveDisplaylink) {
        [_waveDisplaylink invalidate];
        _waveDisplaylink = nil;
    }
    _pathCounter = 0;
}

- (void)reset {
    [_waveDisplaylink invalidate];
    _waveDisplaylink = nil;
    
    _items = nil;
    [_wavePaths removeAllObjects];
    _pathCounter = 0;
    
    [self setNeedsDisplay];
}

- (void)drawWave:(CADisplayLink *)displayLink {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (SSJWaveWaterPath *path in _wavePaths) {
            [path updateCurrentPoint];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsDisplay];
        });
    });
}

- (void)clipContext {
    CGRect circleRect = CGRectInset(self.bounds, _borderWidth, _borderWidth);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    [_borderColor setStroke];
    circlePath.lineWidth = _borderWidth;
    [circlePath stroke];
    [circlePath addClip];
}

@end
