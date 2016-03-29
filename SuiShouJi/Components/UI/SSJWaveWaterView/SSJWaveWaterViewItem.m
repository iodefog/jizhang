//
//  SSJWaveWaterViewItem.m
//  SSJWaveWaterDemo
//
//  Created by old lang on 16/3/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJWaveWaterViewItem.h"

@implementation SSJWaveWaterViewItem

- (void)dealloc {
    
}

+ (instancetype)item {
    return [[self alloc] init];
}

+ (instancetype)itemWithAmplitude:(CGFloat)amplitude
                            speed:(CGFloat)speed
                            cycle:(CGFloat)cycle
                           growth:(CGFloat)growth
                          percent:(CGFloat)percent
                       waveOffset:(CGFloat)waveOffset
                            color:(UIColor *)color {
    
    SSJWaveWaterViewItem *item = [[SSJWaveWaterViewItem alloc] init];
    item.waveAmplitude = amplitude;
    item.waveSpeed = speed;
    item.waveCycle = cycle;
    item.waveGrowth = growth;
    item.wavePercent = percent;
    item.waveOffset = waveOffset;
    item.waveColor = color;
    return item;
}

- (instancetype)init {
    if (self = [super init]) {
        self.waveAmplitude = 1;
        self.waveSpeed = 1;
        self.waveCycle = 1;
        self.waveGrowth = 1;
        self.wavePercent = 0;
        self.waveOffset = 0;
        self.waveColor = [UIColor orangeColor];
    }
    return self;
}

@end
