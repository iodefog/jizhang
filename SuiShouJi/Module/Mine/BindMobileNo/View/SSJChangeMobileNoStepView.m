//
//  SSJChangeMobileNoStepView.m
//  SuiShouJi
//
//  Created by old lang on 2017/6/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJChangeMobileNoStepView.h"

#define SSJ_COMPLETION_COLOR RGBCOLOR(255, 164, 140)
#define SSJ_INCOMPLETION_COLOR RGBCOLOR(221, 221, 221)

#pragma mark - _SSJChangeMobileNoStepDashedView
#pragma mark -
@interface _SSJChangeMobileNoStepDashedView : UIImageView

@end

@implementation _SSJChangeMobileNoStepDashedView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self drawDash];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self drawDash];
}

- (void)drawDash {
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    UIGraphicsBeginImageContext(self.frame.size);
//    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGFloat lengths[] = {2, 2};
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, self.height);
    CGContextSetStrokeColorWithColor(ctx, self.backgroundColor.CGColor);
    CGContextSetLineDash(ctx, 0, lengths, 2); //画虚线
    CGContextMoveToPoint(ctx, 0, 0); //开始画线
    CGContextAddLineToPoint(ctx, self.width, 0);
    CGContextStrokePath(ctx);
    self.image = UIGraphicsGetImageFromCurrentImageContext();
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [self drawDash];
}

@end

#pragma mark - _SSJChangeMobileNoStepNumberView
#pragma mark -
typedef NS_ENUM(NSInteger, SSJChangeMobileNoStepSingleViewStyle) {
    SSJChangeMobileNoStepSingleViewStyleBody,
    SSJChangeMobileNoStepSingleViewStyleFooter
};
@interface _SSJChangeMobileNoStepSingleView : UIView

@property (nonatomic) NSInteger number;

@property (nonatomic, readonly) SSJChangeMobileNoStepSingleViewStyle style;

@end

@interface _SSJChangeMobileNoStepSingleView ()

@property (nonatomic, strong) UILabel *lab;

@property (nonatomic, strong) _SSJChangeMobileNoStepDashedView *dash;

@property (nonatomic) SSJChangeMobileNoStepSingleViewStyle style;

@end

@implementation _SSJChangeMobileNoStepSingleView

- (instancetype)initWithStyle:(SSJChangeMobileNoStepSingleViewStyle)style {
    if (self = [super initWithFrame:CGRectZero]) {
        self.style = style;
        switch (self.style) {
            case SSJChangeMobileNoStepSingleViewStyleBody:
                [self addSubview:self.lab];
                [self addSubview:self.dash];
                break;
                
            case SSJChangeMobileNoStepSingleViewStyleFooter:
                [self addSubview:self.lab];
                break;
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithStyle:SSJChangeMobileNoStepSingleViewStyleBody];
}

- (void)updateConstraints {
    switch (self.style) {
        case SSJChangeMobileNoStepSingleViewStyleBody: {
            [self.lab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(16, 16));
                make.top.and.left.and.bottom.mas_equalTo(self);
            }];
            [self.dash mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(36, 2));
                make.left.mas_equalTo(self.lab).offset(4);
                make.top.and.right.bottom.mas_equalTo(self);
            }];
        }
            break;
            
        case SSJChangeMobileNoStepSingleViewStyleFooter: {
            [self.lab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(16, 16));
                make.edges.mas_equalTo(self);
            }];
        }
            break;
    }
    
    [super updateConstraints];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.lab.backgroundColor = backgroundColor;
    self.dash.backgroundColor = backgroundColor;
}

- (void)setNumber:(NSInteger)number {
    _number = number;
    self.lab.text = [NSString stringWithFormat:@"%d", (int)number];
}

- (UILabel *)lab {
    if (!_lab) {
        _lab = [[UILabel alloc] init];
        _lab.clipsToBounds = YES;
        _lab.layer.cornerRadius = 2;
        _lab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        _lab.textColor = [UIColor whiteColor];
    }
    return _lab;
}

- (_SSJChangeMobileNoStepDashedView *)dash {
    if (!_dash) {
        _dash = [[_SSJChangeMobileNoStepDashedView alloc] init];
    }
    return _dash;
}

@end

#pragma mark - SSJChangeMobileNoStepView
#pragma mark -
@interface SSJChangeMobileNoStepView ()

@property (nonatomic) NSInteger step;

@property (nonatomic, strong) NSMutableArray<_SSJChangeMobileNoStepSingleView *> *singleViews;

@end

@implementation SSJChangeMobileNoStepView

- (instancetype)initWithStep:(NSInteger)step {
    if (self = [super initWithFrame:CGRectZero]) {
        self.step = step;
        self.singleViews = [NSMutableArray arrayWithCapacity:step];
        [self setupSingleViews];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithStep:1];
}

- (void)updateConstraints {
    [self.singleViews enumerateObjectsUsingBlock:^(_SSJChangeMobileNoStepSingleView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        _SSJChangeMobileNoStepSingleView *lastView = nil;
        if (idx > 0) {
            lastView = self.singleViews[idx - 1];
        }
        
        [obj mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.mas_equalTo(self);
            make.left.mas_equalTo(lastView ? lastView.mas_right : self.mas_left);
            if (idx == self.singleViews.count - 1) {
                make.right.mas_equalTo(self);
            }
        }];
    }];
    [super updateConstraints];
}

- (void)setCurrentStep:(NSInteger)currentStep {
    _currentStep = currentStep;
    [self.singleViews enumerateObjectsUsingBlock:^(_SSJChangeMobileNoStepSingleView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.backgroundColor = idx < currentStep ? SSJ_COMPLETION_COLOR : SSJ_INCOMPLETION_COLOR;
    }];
}

- (void)setupSingleViews {
    for (int i = 0; i < self.step; i ++) {
        SSJChangeMobileNoStepSingleViewStyle style = (i == self.step - 1) ? SSJChangeMobileNoStepSingleViewStyleFooter : SSJChangeMobileNoStepSingleViewStyleBody;
        _SSJChangeMobileNoStepSingleView *view = [[_SSJChangeMobileNoStepSingleView alloc] initWithStyle:style];
        view.number = i + 1;
        view.backgroundColor = i < self.currentStep ? SSJ_COMPLETION_COLOR : SSJ_INCOMPLETION_COLOR;
        [self.singleViews addObject:view];
    }
}

@end
