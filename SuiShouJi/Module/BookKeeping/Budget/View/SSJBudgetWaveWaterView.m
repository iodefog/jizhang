//
//  SSJBudgetWaveWaterView.m
//  SuiShouJi
//
//  Created by old lang on 16/3/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetWaveWaterView.h"
#import "SSJWaveWaterView.h"

@interface SSJBudgetWaveWaterView ()

@property (nonatomic, strong) SSJWaveWaterView *growingView;

@property (nonatomic, strong) SSJWaveWaterView *fullView;

@property (nonatomic, strong) NSArray *growingItems;

// 剩余0颜色
@property (nonatomic, strong) NSArray *fullColors;

// 超支颜色
@property (nonatomic, strong) NSArray *overrunColors;

@end

@implementation SSJBudgetWaveWaterView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithRadius:0];
}

- (instancetype)initWithRadius:(CGFloat)radius {
    if (self = [super initWithFrame:CGRectMake(0, 0, radius, radius)]) {
        self.waveAmplitude = 1;
        self.waveSpeed = 1;
        self.waveCycle = 1;
        self.waveGrowth = 1;
        self.waveAmplitude = 1;
        
        self.fullWaveAmplitude = 1;
        self.fullWaveSpeed = 1;
        self.fullWaveCycle = 1;
        
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.growingView];
        [self addSubview:self.fullView];
        
        self.layer.borderColor = [UIColor ssj_colorWithHex:@"f4f4f4"].CGColor;
    }
    return self;
}

- (void)layoutSubviews {
    self.growingView.frame = CGRectInset(self.bounds, _outerBorderWidth, _outerBorderWidth);
    self.fullView.frame = CGRectInset(self.bounds, _outerBorderWidth, _outerBorderWidth);
    self.layer.cornerRadius = self.width * 0.5;
}

- (void)setWaveAmplitude:(CGFloat)waveAmplitude {
    if (_waveAmplitude != waveAmplitude) {
        _waveAmplitude = waveAmplitude;
        for (SSJWaveWaterViewItem *item in _growingView.items) {
            item.waveAmplitude = waveAmplitude;
        }
    }
}

- (void)setWaveSpeed:(CGFloat)waveSpeed {
    if (_waveSpeed != waveSpeed) {
        _waveSpeed = waveSpeed;
        for (SSJWaveWaterViewItem *item in _growingView.items) {
            item.waveSpeed = waveSpeed;
        }
    }
}

- (void)setWaveCycle:(CGFloat)waveCycle {
    if (_waveCycle != waveCycle) {
        _waveCycle = waveCycle;
        for (SSJWaveWaterViewItem *item in _growingView.items) {
            item.waveCycle = waveCycle;
        }
    }
}

- (void)setWaveGrowth:(CGFloat)waveGrowth {
    if (_waveGrowth != waveGrowth) {
        _waveGrowth = waveGrowth;
        for (SSJWaveWaterViewItem *item in _growingView.items) {
            item.waveGrowth = waveGrowth;
        }
    }
}

- (void)setWaveOffset:(CGFloat)waveOffset {
    if (_waveOffset != waveOffset) {
        _waveOffset = waveOffset;
        SSJWaveWaterViewItem *item = [_growingView.items lastObject];
        item.waveOffset = waveOffset;
    }
}

- (void)setFullWaveAmplitude:(CGFloat)fullWaveAmplitude {
    if (_fullWaveAmplitude != fullWaveAmplitude) {
        _fullWaveAmplitude = fullWaveAmplitude;
        for (SSJWaveWaterViewItem *item in _fullView.items) {
            item.waveAmplitude = fullWaveAmplitude;
        }
    }
}

- (void)setFullWaveSpeed:(CGFloat)fullWaveSpeed {
    if (_fullWaveSpeed != fullWaveSpeed) {
        _fullWaveSpeed = fullWaveSpeed;
        for (SSJWaveWaterViewItem *item in _fullView.items) {
            item.waveSpeed = fullWaveSpeed;
        }
    }
}

- (void)setFullWaveCycle:(CGFloat)fullWaveCycle {
    if (_fullWaveCycle != fullWaveCycle) {
        _fullWaveCycle = fullWaveCycle;
        for (SSJWaveWaterViewItem *item in _fullView.items) {
            item.waveCycle = fullWaveCycle;
        }
    }
}

- (void)setInnerBorderWidth:(CGFloat)innerBorderWidth {
    _innerBorderWidth = innerBorderWidth;
    self.growingView.borderWidth = _innerBorderWidth;
}

- (void)setOuterBorderWidth:(CGFloat)outerBorderWidth {
    if (_outerBorderWidth != outerBorderWidth) {
        _outerBorderWidth = outerBorderWidth;
        self.layer.borderWidth = _outerBorderWidth;
    }
}

- (void)setMoney:(double)money {
    _money = money;
    if (self.showText) {
        _fullView.bottomTitle = [NSString stringWithFormat:@"%.2f", _money];
        _growingView.bottomTitle = [NSString stringWithFormat:@"%.2f", _money];
    }
}

- (void)setPercent:(CGFloat)percent {
    _percent = percent;
    if (percent >= 0 && percent < 1) {
        self.growingView.hidden = NO;
        self.fullView.hidden = YES;
        if (percent == 0) {
            [self.growingView reset];
        } else {
            
            if (!self.growingView.items) {
                self.growingView.items = self.growingItems;
            }
            [self.growingView startWave];
        }
        
        [self.fullView stopWave];
        for (SSJWaveWaterViewItem *item in self.growingView.items) {
            item.wavePercent = percent;
        }
        
        if (self.showText) {
            self.growingView.topTitle = @"剩余";
            self.growingView.bottomTitle = [NSString stringWithFormat:@"%.2f", _money];
        }
        
    } else if (percent == 1) {
        self.growingView.hidden = YES;
        self.fullView.hidden = NO;
        [self.growingView stopWave];
        [self.fullView startWave];
//        [self.fullView drawWave];
        self.fullView.borderColor = [UIColor ssj_colorWithHex:@"0fceb6"];
        for (int i = 0; i < self.fullView.items.count; i ++) {
            SSJWaveWaterViewItem *item = self.fullView.items[i];
            item.waveColor = self.fullColors[i];
        }
        
        if (self.showText) {
            self.fullView.topTitle = @"剩余";
            self.fullView.bottomTitle = [NSString stringWithFormat:@"%.2f", _money];
        }
        
    } else if (percent > 1) {
        self.growingView.hidden = YES;
        self.fullView.hidden = NO;
        [self.growingView stopWave];
        [self.fullView startWave];
//        [self.fullView drawWave];
        self.fullView.borderColor = [UIColor ssj_colorWithHex:@"ff654c"];
        for (int i = 0; i < self.fullView.items.count; i ++) {
            SSJWaveWaterViewItem *item = self.fullView.items[i];
            item.waveColor = self.overrunColors[i];
        }
        
        if (self.showText) {
            self.fullView.topTitle = @"超支";
            self.fullView.bottomTitle = [NSString stringWithFormat:@"%.2f", _money];
        }
    }
}

- (void)stopWave {
    [self.growingView stopWave];
    [self.fullView stopWave];
}

- (SSJWaveWaterView *)growingView {
    if (!_growingView) {
        _growingView = [[SSJWaveWaterView alloc] initWithRadius:40];
        _growingView.backgroundColor = [UIColor clearColor];
        _growingView.topTitleColor = [UIColor blackColor];
        _growingView.bottomTitleColor = [UIColor blackColor];
        _growingView.titleGap = 2;
        _growingView.borderColor = RGBCOLOR(38, 227, 198);
    }
    return _growingView;
}

- (SSJWaveWaterView *)fullView {
    if (!_fullView) {
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:self.fullColors.count];
        CGFloat toffset = 0;
        CGFloat percent = 1;
        for (int i = 0; i < self.fullColors.count; i ++) {
            [items addObject:[SSJWaveWaterViewItem itemWithAmplitude:_fullWaveAmplitude
                                                               speed:_fullWaveSpeed
                                                               cycle:_fullWaveCycle
                                                              growth:0
                                                             percent:percent
                                                          waveOffset:0
                                                               color:self.fullColors[i]]];
            toffset += 5;
            percent -= 0.125;
        }
        
        _fullView = [[SSJWaveWaterView alloc] initWithRadius:40];
        _fullView.backgroundColor = [UIColor clearColor];
        _fullView.topTitleColor = [UIColor whiteColor];
        _fullView.bottomTitleColor = [UIColor whiteColor];
        _fullView.items = items;
        _fullView.titleGap = 2;
    }
    return _fullView;
}

- (NSArray *)growingItems {
    if (!_growingItems) {
        SSJWaveWaterViewItem *lightItem = [SSJWaveWaterViewItem item];
        lightItem.waveColor = RGBCOLOR(121, 248, 221);
        lightItem.waveAmplitude = _waveAmplitude;
        lightItem.waveSpeed = _waveSpeed;
        lightItem.waveCycle = _waveCycle;
        lightItem.waveGrowth = _waveGrowth;
        
        SSJWaveWaterViewItem *heavyItem = [SSJWaveWaterViewItem item];
        heavyItem.waveColor = RGBCOLOR(38, 227, 198);
        heavyItem.waveAmplitude = _waveAmplitude;
        heavyItem.waveSpeed = _waveSpeed;
        heavyItem.waveCycle = _waveCycle;
        heavyItem.waveGrowth = _waveGrowth;
        heavyItem.waveOffset = _waveOffset;
        
        _growingItems = [NSArray arrayWithObjects:lightItem, heavyItem, nil];
    }
    return _growingItems;
}

- (NSArray *)fullColors {
    if (!_fullColors) {
        _fullColors = @[[UIColor ssj_colorWithHex:@"a3ece3"],
                        [UIColor ssj_colorWithHex:@"66e0d0"],
                        [UIColor ssj_colorWithHex:@"37d6c2"],
                        [UIColor ssj_colorWithHex:@"0fceb6"],
                        [UIColor ssj_colorWithHex:@"0fceb6"],
                        [UIColor ssj_colorWithHex:@"37d6c2"],
                        [UIColor ssj_colorWithHex:@"66e0d0"],
                        [UIColor ssj_colorWithHex:@"a3ece3"]];
    }
    return _fullColors;
}

- (NSArray *)overrunColors {
    if (!_overrunColors) {
        _overrunColors = @[[UIColor ssj_colorWithHex:@"ffb2a5"],
                           [UIColor ssj_colorWithHex:@"ff9381"],
                           [UIColor ssj_colorWithHex:@"ff7761"],
                           [UIColor ssj_colorWithHex:@"ff654c"],
                           [UIColor ssj_colorWithHex:@"ff654c"],
                           [UIColor ssj_colorWithHex:@"ff7761"],
                           [UIColor ssj_colorWithHex:@"ff9381"],
                           [UIColor ssj_colorWithHex:@"ffb2a5"]];
    }
    return _overrunColors;
}

@end
