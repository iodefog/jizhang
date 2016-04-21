//
//  SSJWaveWaterView.m
//  SSJWaveWaterDemo
//
//  Created by old lang on 16/3/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJWaveWaterView.h"
#import "SSJWaveWaterPath.h"

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
        
        _topTitleFontSize = 12;
        _bottomTitleFontSize = 18;
        _topTitleColor = [UIColor whiteColor];
        _bottomTitleColor = [UIColor whiteColor];
        
        _wavePaths = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor whiteColor];
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
    }
    
    if (self.topTitle.length || self.bottomTitle.length) {
        [self drawText];
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

- (void)drawWave {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (SSJWaveWaterPath *path in _wavePaths) {
            [path updateCurrentPoint];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsDisplay];
        });
    });
}

- (void)startWave {
    if (_waveDisplaylink == nil) {
//         启动定时调用
        _waveDisplaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawWave)];
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

- (void)clipContext {
    CGRect circleRect = CGRectInset(self.bounds, _borderWidth, _borderWidth);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    [_borderColor setStroke];
    circlePath.lineWidth = _borderWidth;
    [circlePath stroke];
    [circlePath addClip];
}

- (void)drawText {
    UIFont *topFont = [UIFont systemFontOfSize:_topTitleFontSize];
    UIFont *bottomFont = [UIFont systemFontOfSize:_bottomTitleFontSize];
    
    CGSize topTitleSize = [_topTitle sizeWithAttributes:@{NSFontAttributeName:topFont}];
    CGSize bottomTitleSize = [_bottomTitle sizeWithAttributes:@{NSFontAttributeName:bottomFont}];
    
    CGFloat top = (self.height - topTitleSize.height - bottomTitleSize.height) * 0.5;
    if (!topTitleSize.height || !bottomTitleSize.height) {
        top -= _titleGap * 0.5;
    }
    
    CGPoint topTitlePoint = CGPointMake((self.width - topTitleSize.width) * 0.5, top);
    [_topTitle drawAtPoint:topTitlePoint withAttributes:@{NSFontAttributeName:topFont,
                                                          NSForegroundColorAttributeName:_topTitleColor}];
    
    CGPoint bottomTitlePoint = CGPointMake((self.width - bottomTitleSize.width) * 0.5, topTitleSize.height + top + _titleGap);
    [_bottomTitle drawAtPoint:bottomTitlePoint withAttributes:@{NSFontAttributeName:bottomFont,
                                                                NSForegroundColorAttributeName:_bottomTitleColor}];
}

@end
