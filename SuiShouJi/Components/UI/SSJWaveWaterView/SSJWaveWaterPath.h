//
//  SSJWaveWaterPath.h
//  SSJWaveWaterDemo
//
//  Created by old lang on 16/3/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSJWaveWaterViewItem;

@interface SSJWaveWaterPath : NSObject

//
@property (nonatomic, retain) SSJWaveWaterViewItem *item;

//
@property (nonatomic) CGSize size;

+ (instancetype)pathWithItem:(SSJWaveWaterViewItem *)item
                        size:(CGSize)size;


//- (void)drawWavePath;

- (void)updateCurrentPoint;

- (void)drawPath;

@end
