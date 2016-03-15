//
//  SSJWaveLoadingIndicator.m
//  WateTest
//
//  Created by old lang on 16/2/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetWaveScaleView.h"
#import "SuiShouJi-Swift.h"

@interface SSJBudgetWaveScaleView ()

@property (nonatomic, strong) WaveLoadingIndicator *waveIndicator;

@property (nonatomic, strong) UIImageView *fullView;

@property (nonatomic, strong) UILabel *topLabel;

@property (nonatomic, strong) UILabel *bottomLabel;

@end

@implementation SSJBudgetWaveScaleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderWidth = 4;
        self.layer.borderColor = [UIColor ssj_colorWithHex:@"e9e9e9"].CGColor;
        
        self.waveIndicator = [[WaveLoadingIndicator alloc] init];
        self.waveIndicator.isShowProgressText = NO;
        self.waveIndicator.waveAmplitude = 10;
        [self addSubview:self.waveIndicator];
        
        self.fullView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"budget_wave_full"]];
        [self addSubview:self.fullView];
        
        self.topLabel = [[UILabel alloc] init];
        self.topLabel.backgroundColor = [UIColor clearColor];
        self.topLabel.textColor = [UIColor blackColor];
        self.topLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.topLabel];
        
        self.bottomLabel = [[UILabel alloc] init];
        self.bottomLabel.backgroundColor = [UIColor clearColor];
        self.bottomLabel.textColor = [UIColor blackColor];
        self.bottomLabel.font = [UIFont systemFontOfSize:18];
        [self addSubview:self.bottomLabel];
    }
    return self;
}

- (void)layoutSubviews {
    self.layer.cornerRadius = self.width * 0.5;
    self.waveIndicator.frame = self.fullView.frame = CGRectInset(self.bounds, self.layer.borderWidth * 0.5, self.layer.borderWidth * 0.5);
    
    self.topLabel.width = MIN(self.topLabel.width, self.waveIndicator.width);
    self.bottomLabel.width = MIN(self.bottomLabel.width, self.waveIndicator.width);
    
    if (self.topLabel.text.length && self.bottomLabel.text.length) {
        CGFloat gap = 5;
        CGFloat top = (self.height - self.topLabel.height - self.bottomLabel.height - gap) * 0.5;
        self.topLabel.top = top;
        self.bottomLabel.top = self.topLabel.bottom;
        self.topLabel.centerX = self.bottomLabel.centerX = self.width * 0.5;
    } else if (self.topLabel.text.length || self.bottomLabel.text.length) {
        UILabel *tLabel = self.topLabel.text.length ? self.topLabel : self.bottomLabel;
        tLabel.center = CGPointMake(self.width * 0.5, self.height * 0.5);
    }
}

- (void)setWaveAmplitude:(CGFloat)waveAmplitude {
    if (_waveAmplitude != waveAmplitude) {
        _waveAmplitude = waveAmplitude;
        self.waveIndicator.waveAmplitude = waveAmplitude;
    }
}

- (void)setScale:(CGFloat)scale {
    if (_scale != scale) {
        _scale = scale;
        
        self.fullView.hidden = _scale < 1;
        self.waveIndicator.hidden = _scale >= 1;
        if (!self.waveIndicator.hidden) {
            self.waveIndicator.progress = scale;
        }
    }
}

- (void)setTopTitle:(NSString *)title {
    if (![_title isEqualToString:title]) {
        _title = title;
        self.topLabel.text = title;
        [self.topLabel sizeToFit];
        [self setNeedsLayout];
    }
}

- (void)setSubtitlle:(NSString *)subtitlle {
    if (![_subtitlle isEqualToString:subtitlle]) {
        _subtitlle = subtitlle;
        self.bottomLabel.text = subtitlle;
        [self.bottomLabel sizeToFit];
        [self setNeedsLayout];
    }
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    if (self.layer.borderWidth != borderWidth) {
        self.layer.borderWidth = borderWidth;
        [self setNeedsLayout];
    }
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
}

@end
