//
//  SSJWaveWaterScaleView.m
//  SSJWaveWaterDemo
//
//  Created by old lang on 16/3/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJWaveWaterScaleView.h"
#import "SSJWaveWaterView.h"

#warning test
#import "SSJViewAddition.h"

#define RGBCOLOR(_red, _green, _blue) [UIColor colorWithRed:(_red)/255.0f green:(_green)/255.0f blue:(_blue)/255.0f alpha:1]

@interface SSJWaveWaterScaleView ()

@property (nonatomic, strong) SSJWaveWaterView *growingView;

@property (nonatomic, strong) SSJWaveWaterView *fullView;

@end

@implementation SSJWaveWaterScaleView

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
        
        [self addSubview:self.growingView];
        [self addSubview:self.fullView];
    }
    return self;
}

- (void)layoutSubviews {
    self.growingView.frame = self.bounds;
    self.fullView.frame = self.bounds;
}

- (void)setPercent:(CGFloat)percent {
    if (percent < 1 && percent > 0) {
        self.growingView.hidden = NO;
        self.fullView.hidden = YES;
        [self.growingView startWave];
        [self.fullView stopWave];
        for (SSJWaveWaterViewItem *item in self.growingView.items) {
            item.wavePercent = percent;
        }
    } else if (percent >= 1) {
        self.growingView.hidden = YES;
        self.fullView.hidden = NO;
        [self.growingView stopWave];
        [self.fullView startWave];
    }
}

- (void)stopWave {
    [self.growingView stopWave];
    [self.fullView stopWave];
}

- (SSJWaveWaterView *)growingView {
    if (!_growingView) {
        SSJWaveWaterViewItem *lightItem = [SSJWaveWaterViewItem item];
        lightItem.waveColor = RGBCOLOR(121, 248, 221);
        lightItem.waveAmplitude = 7;
        lightItem.waveSpeed = 6;
        
        SSJWaveWaterViewItem *heavyItem = [SSJWaveWaterViewItem item];
        heavyItem.waveColor = RGBCOLOR(38, 227, 198);
        heavyItem.waveAmplitude = 5;
        heavyItem.waveSpeed = 5;
        heavyItem.waveOffset = 7;
        
        _growingView = [[SSJWaveWaterView alloc] initWithRadius:40];
        _growingView.layer.borderColor = [UIColor redColor].CGColor;
        _growingView.layer.borderWidth = 1;
        _growingView.items = @[lightItem,heavyItem];
    }
    return _growingView;
}

- (SSJWaveWaterView *)fullView {
    if (!_fullView) {
        
        NSArray *colors = @[[UIColor ssj_colorWithHex:@"ffb2a5"],
                            [UIColor ssj_colorWithHex:@"ff9381"],
                            [UIColor ssj_colorWithHex:@"ff7761"],
                            [UIColor ssj_colorWithHex:@"ff654c"],
                            [UIColor ssj_colorWithHex:@"ff654c"],
                            [UIColor ssj_colorWithHex:@"ff7761"],
                            [UIColor ssj_colorWithHex:@"ff9381"],
                            [UIColor ssj_colorWithHex:@"ffb2a5"]];
        
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:colors.count];
        CGFloat toffset = 0;
        CGFloat percent = 1;
        for (int i = 0; i < colors.count; i ++) {
            [items addObject:[SSJWaveWaterViewItem itemWithAmplitude:3
                                                               speed:3
                                                               cycle:4
                                                              growth:0
                                                             percent:percent
                                                          waveOffset:0
                                                               color:colors[i]]];
            toffset += 5;
            percent -= 0.125;
        }
        
        _fullView = [[SSJWaveWaterView alloc] initWithRadius:40];
        _fullView.layer.borderColor = [UIColor redColor].CGColor;
        _fullView.layer.borderWidth = 1;
        _fullView.items = items;
    }
    return _fullView;
}

@end
