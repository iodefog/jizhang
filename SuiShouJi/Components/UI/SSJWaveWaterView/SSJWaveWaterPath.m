//
//  SSJWaveWaterPath.m
//  SSJWaveWaterDemo
//
//  Created by old lang on 16/3/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJWaveWaterPath.h"
#import "SSJWaveWaterViewItem.h"

@interface SSJWaveWaterPath ()

@property (nonatomic) BOOL isRising;

@property (nonatomic) CGFloat halfCycleWidth;

@property (nonatomic) CGFloat targetPointY;

@property (nonatomic) CGPoint currentPoint;

@property (nonatomic, strong) UIBezierPath *wavePath;

@end

@implementation SSJWaveWaterPath

- (void)dealloc {
    [_item removeObserver:self forKeyPath:@"waveCycle"];
    [_item removeObserver:self forKeyPath:@"wavePercent"];
    [_item removeObserver:self forKeyPath:@"waveOffset"];
}

+ (instancetype)pathWithItem:(SSJWaveWaterViewItem *)item size:(CGSize)size {
    return [[SSJWaveWaterPath alloc] initWithItem:item size:size];
}

- (instancetype)initWithItem:(SSJWaveWaterViewItem *)item size:(CGSize)size {
    if (self = [super init]) {
        _item = item;
        _size = size;
        
        _isRising = YES;
        if (_item.waveCycle) {
            _halfCycleWidth = _size.width / (_item.waveCycle * 2);
        }
        _targetPointY = _size.height * (1 - _item.wavePercent);
        _currentPoint = CGPointMake(-_item.waveOffset, _size.height);
        _wavePath = [UIBezierPath bezierPath];
        
        [_item addObserver:self forKeyPath:@"waveCycle" options:(NSKeyValueObservingOptionNew) context:NULL];
        [_item addObserver:self forKeyPath:@"wavePercent" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
        [_item addObserver:self forKeyPath:@"waveOffset" options:(NSKeyValueObservingOptionNew) context:NULL];
    }
    return self;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    
    if (object != self.item) {
        return;
    }
    
    if ([keyPath isEqualToString:@"waveCycle"]) {
        if (_item.waveCycle) {
            _halfCycleWidth = _size.width / (_item.waveCycle * 2);
        } else {
            _halfCycleWidth = 0;
        }
        return;
    }
    
    if ([keyPath isEqualToString:@"wavePercent"]) {
        _targetPointY = _size.height * (1 - _item.wavePercent);
        _isRising = _currentPoint.y > _targetPointY;
        return;
    }
    
    if ([keyPath isEqualToString:@"waveOffset"]) {
        _currentPoint.x = -_item.waveOffset;
        return;
    }
}

- (void)drawWavePath {
    [self updateCurrentPoint];
    [self drawPath];
}

- (void)drawPath {
    
    [_wavePath removeAllPoints];
    [_item.waveColor setFill];
    
    [_wavePath moveToPoint:_currentPoint];
    
    CGFloat currentAmplitude = 0;
    for (int i = 0; i < 4 * _item.waveCycle; i ++) {
        CGPoint endPoint = CGPointMake(_currentPoint.x + (i + 1) * _halfCycleWidth, _currentPoint.y);
        if (i & 1) {
            // 奇数
            currentAmplitude = _item.waveAmplitude;
        } else {
            //
            currentAmplitude = -_item.waveAmplitude;
        }
        CGPoint controlPoint = CGPointMake(_currentPoint.x + _halfCycleWidth * 0.5 + i * _halfCycleWidth, _currentPoint.y + currentAmplitude);
        [_wavePath addQuadCurveToPoint:endPoint controlPoint:controlPoint];
    }
    
    //  如果曲线的X轴没有达到自身宽度，就延续曲线，防止出现空白的现象
    if (_wavePath.currentPoint.x < _size.width) {
        CGPoint endPoint = CGPointMake(_wavePath.currentPoint.x + _halfCycleWidth, _currentPoint.y);
        CGPoint controlPoint = CGPointMake(_wavePath.currentPoint.x + _halfCycleWidth * 0.5, _currentPoint.y - currentAmplitude);
        [_wavePath addQuadCurveToPoint:endPoint controlPoint:controlPoint];
    }
    
    [_wavePath addLineToPoint:CGPointMake(_size.width, _size.height)];
    [_wavePath addLineToPoint:CGPointMake(0, _size.height)];
    [_wavePath closePath];
    [_wavePath fill];
}

- (void)updateCurrentPoint {
    CGFloat currentPointX = _currentPoint.x;
    if (currentPointX > -_halfCycleWidth * 2) {
        currentPointX -= _item.waveSpeed;
    } else {
        currentPointX += _halfCycleWidth * 2 - _item.waveSpeed;
    }
    
    CGFloat currentPointY = _currentPoint.y;
    
    //  如果没有上升速率，就直接设置目标Y轴高度
    if (_item.waveGrowth <= 0) {
        _currentPoint = CGPointMake(currentPointX, _targetPointY);
        return;
    }
    
    if (_isRising) {
        // 上升
        if (currentPointY > _targetPointY) {
            currentPointY -= _item.waveGrowth;
        }
    } else {
        // 下降
        if (currentPointY < _targetPointY) {
            currentPointY += _item.waveGrowth;
        }
    }
    
    _currentPoint = CGPointMake(currentPointX, currentPointY);
}

@end
