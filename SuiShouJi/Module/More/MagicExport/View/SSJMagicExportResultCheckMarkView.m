//
//  SSJMagicExportResultCheckMarkView.m
//  SuiShouJi
//
//  Created by old lang on 16/4/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportResultCheckMarkView.h"

@interface SSJMagicExportResultCheckMarkView ()

@property (nonatomic, strong) CAShapeLayer *shaperLayer;

@end

@implementation SSJMagicExportResultCheckMarkView

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (instancetype)initWithRadius:(CGFloat)radius {
    if (self = [super initWithFrame:CGRectMake(0, 0, radius, radius)]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithRadius:MIN(CGRectGetWidth(frame), CGRectGetHeight(frame))];
}

- (void)startAnimation:(void (^)())finish {
//    UIBezierPath *path = [UIBezierPath ]
}

@end
