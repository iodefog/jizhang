//
//  SSJBudgetWaveWaterView.m
//  SuiShouJi
//
//  Created by old lang on 16/3/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetWaveWaterView.h"
#import "SSJWaveWaterView.h"

static CGFloat kTitleGap = 2;

static CGFloat kTopTitleSize = 12;

static CGFloat kBottomTitleSize = 22;

@interface SSJBudgetWaveWaterView ()

@property (nonatomic, strong) SSJWaveWaterView *growingView;

@property (nonatomic, strong) NSArray *growingItems;

// 剩余0颜色
@property (nonatomic, strong) NSArray *fullColors;

// 超支颜色
@property (nonatomic, strong) NSArray *overrunColors;

@end

@implementation SSJBudgetWaveWaterView

- (void)dealloc {
    [_growingView stopWave];
}

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
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.growingView];
        
        self.layer.borderColor = [UIColor ssj_colorWithHex:SSJSurplusGreenColorValue alpha:0.1].CGColor;
    }
    return self;
}

- (void)layoutSubviews {
    self.growingView.frame = CGRectInset(self.bounds, _outerBorderWidth, _outerBorderWidth);
    self.layer.cornerRadius = self.width * 0.5;
}

- (void)drawRect:(CGRect)rect {
    [[UIColor whiteColor] setFill];
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    [circlePath fill];
    
    if (_expendMoney > _budgetMoney || _expendMoney == 0) {
        [circlePath addClip];
        
        NSString *imageName = _expendMoney > _budgetMoney ? @"budget_wave_red" : @"budget_wave_green";
        NSString *topStr = _expendMoney > _budgetMoney ? @"超支" : @"剩余";
        NSString *bottomStr = [NSString stringWithFormat:@"%.2f", (_budgetMoney - _expendMoney)];
        
        [[UIImage imageNamed:imageName] drawInRect:self.bounds];
        
        CGSize topSize = [topStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kTopTitleSize]}];
        CGSize bottomSize = [bottomStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kBottomTitleSize]}];
        bottomSize.width = MIN(bottomSize.width, self.width - _outerBorderWidth * 2);
        
        CGFloat top = (self.height - topSize.height - bottomSize.height - kTitleGap) * 0.5;
        CGRect topRect = CGRectMake((self.width - topSize.width) * 0.5, top, topSize.width, topSize.height);
        CGRect bottomRect = CGRectMake((self.width - bottomSize.width) * 0.5, CGRectGetMaxY(topRect) + kTitleGap, bottomSize.width, bottomSize.height);
        
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByTruncatingTail;
        [topStr drawInRect:topRect withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kTopTitleSize],
                                                    NSForegroundColorAttributeName:[UIColor whiteColor],
                                                    NSParagraphStyleAttributeName:paragraph}];
        [bottomStr drawInRect:bottomRect withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kBottomTitleSize],
                                                          NSForegroundColorAttributeName:[UIColor whiteColor],
                                                          NSParagraphStyleAttributeName:paragraph}];
    }
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

- (void)setBudgetMoney:(double)budgetMoney {
    if (budgetMoney <= 0) {
        return;
    }
    
    if (_budgetMoney != budgetMoney) {
        _budgetMoney = budgetMoney;
        [self updateAppearance];
    }
}

- (void)setExpendMoney:(double)expendMoney {
    if (expendMoney < 0) {
        return;
    }
    
    if (_expendMoney != expendMoney) {
        _expendMoney = expendMoney;
        [self updateAppearance];
    }
}

- (void)stopWave {
    [self.growingView stopWave];
}

#pragma mark - Private
- (void)updateAppearance {
    
    if (_budgetMoney <= 0 || _expendMoney < 0) {
        return;
    }
    
    [self setNeedsDisplay];
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    
    if (_expendMoney > _budgetMoney || _expendMoney == 0) {
        self.growingView.hidden = YES;
    } else {
        self.growingView.hidden = NO;
        self.layer.borderColor = [UIColor ssj_colorWithHex:SSJSurplusGreenColorValue alpha:0.1].CGColor;
        
        if (!self.growingView.items) {
            self.growingView.items = self.growingItems;
        }
        
        [self.growingView startWave];
        
        for (SSJWaveWaterViewItem *item in self.growingView.items) {
            item.wavePercent = 1;
            item.waveGrowth = 0;
        }
        
        [self performSelector:@selector(decline) withObject:nil afterDelay:0.2];
        
        self.growingView.topTitle = @"剩余";
        self.growingView.bottomTitle = [NSString stringWithFormat:@"%.2f", _budgetMoney - _expendMoney];
    }
}

- (void)decline {
    CGFloat percent;
    if (_expendMoney >= _budgetMoney) {
        percent = 0;
    } else {
        percent = 1 - (_expendMoney / _budgetMoney);
    }
    
    for (SSJWaveWaterViewItem *item in self.growingView.items) {
        item.wavePercent = percent;
        item.waveGrowth = _waveGrowth;
    }
    
    if (percent == 0) {
        [self performSelector:@selector(reset) withObject:nil afterDelay:self.growingView.height / (12 * _waveGrowth)];
    }
}

- (void)reset {
    [self.growingView reset];
}

#pragma mark - Getter
- (SSJWaveWaterView *)growingView {
    if (!_growingView) {
        _growingView = [[SSJWaveWaterView alloc] initWithRadius:40];
        _growingView.backgroundColor = [UIColor clearColor];
        _growingView.topTitleColor = [UIColor blackColor];
        _growingView.bottomTitleColor = [UIColor blackColor];
        _growingView.titleGap = kTitleGap;
        _growingView.borderColor = [UIColor ssj_colorWithHex:SSJSurplusGreenColorValue];
        _growingView.titleGap = kTitleGap;
        _growingView.topTitleFontSize = kTopTitleSize;
        _growingView.bottomTitleFontSize = kBottomTitleSize;
    }
    return _growingView;
}

- (NSArray *)growingItems {
    if (!_growingItems) {
        SSJWaveWaterViewItem *lightItem = [SSJWaveWaterViewItem item];
        lightItem.waveColor = [UIColor ssj_colorWithHex:@"bdeedd"];
        lightItem.waveAmplitude = _waveAmplitude;
        lightItem.waveSpeed = _waveSpeed;
        lightItem.waveCycle = _waveCycle;
        lightItem.waveGrowth = _waveGrowth;
        
        SSJWaveWaterViewItem *heavyItem = [SSJWaveWaterViewItem item];
        heavyItem.waveColor = [UIColor ssj_colorWithHex:SSJSurplusGreenColorValue];
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
