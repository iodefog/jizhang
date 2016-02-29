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

@property (nonatomic, strong) UILabel *topLabel;

@property (nonatomic, strong) UILabel *bottomLabel;

@end

@implementation SSJBudgetWaveScaleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderColor = [UIColor ssj_colorWithHex:@"e9e9e9"].CGColor;
        self.layer.borderWidth = 3;
        
        self.waveIndicator = [[WaveLoadingIndicator alloc] init];
        self.waveIndicator.isShowProgressText = NO;
        [self addSubview:self.waveIndicator];
        
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
    self.waveIndicator.frame = CGRectInset(self.bounds, self.layer.borderWidth * 0.5, self.layer.borderWidth * 0.5);
    
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

- (void)setScale:(CGFloat)scale {
    self.waveIndicator.progress = scale;
}

- (void)setTopTitle:(NSString *)title {
    if (![self.topLabel.text isEqualToString:title]) {
        self.topLabel.text = title;
        [self.topLabel sizeToFit];
        [self setNeedsLayout];
    }
}

- (void)setBottomTitle:(NSString *)title {
    if (![self.bottomLabel.text isEqualToString:title]) {
        self.bottomLabel.text = title;
        [self.bottomLabel sizeToFit];
        [self setNeedsLayout];
    }
}

@end
