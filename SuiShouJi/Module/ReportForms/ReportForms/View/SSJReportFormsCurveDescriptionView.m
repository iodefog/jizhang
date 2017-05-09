//
//  SSJReportFormsCurveDescriptionView.m
//  SuiShouJi
//
//  Created by old lang on 16/6/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveDescriptionView.h"
#import "SSJDatePeriod.h"

@interface SSJReportFormsCurveDescriptionBackView : UIControl

@end

@implementation SSJReportFormsCurveDescriptionBackView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self sendActionsForControlEvents:UIControlEventTouchDown];
}

@end

const UIEdgeInsets kTextInset = {15, 5, 10, 5};

const CGFloat kSuperMargin = 5;


@interface SSJReportFormsCurveDescriptionView ()

@property (nonatomic, strong) SSJReportFormsCurveDescriptionBackView *backgroundView;

@property (nonatomic, strong) UILabel *label;

@property (nonatomic) CGPoint showPoint;

@end

@implementation SSJReportFormsCurveDescriptionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _label = [[UILabel alloc] init];
        _label.numberOfLines = 0;
        _label.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6];
        [self addSubview:_label];
    }
    return self;
}

- (void)layoutSubviews {
    _label.left = kTextInset.left;
    _label.top = kTextInset.top;
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 5, self.width , self.height - 5) cornerRadius:3];
    [path moveToPoint:_showPoint];
    [path addLineToPoint:CGPointMake(_showPoint.x - 4, 5)];
    [path addLineToPoint:CGPointMake(_showPoint.x + 4, 5)];
    
    [[UIColor ssj_colorWithHex:@"f6f6f6"] setFill];
    [path fill];
}

- (CGSize)sizeThatFits:(CGSize)size {
    _label.width = self.superview.width - kTextInset.left - kTextInset.right - kSuperMargin * 2;
    [_label sizeToFit];
    return CGSizeMake(_label.width + kTextInset.left + kTextInset.right, _label.height + kTextInset.top + kTextInset.bottom);
}

- (void)setPeriod:(SSJDatePeriod *)period {
    _period = period;
    
    NSString *beginDateStr = [_period.startDate formattedDateWithFormat:@"M月d日"];
    NSString *endDateStr = [_period.endDate formattedDateWithFormat:@"M月d日"];
    NSAttributedString *titleText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@-%@\n\n", beginDateStr, endDateStr] attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"393939"]}];
    NSMutableAttributedString *bodyText = [[NSMutableAttributedString alloc] initWithString:@"注：选择自定义时间，第一周以截止到周日计，最后一周计至截止日的最后一天，其它周则以正常7天计数。" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"929292"]}];
    [bodyText setAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"393939"]} range:NSMakeRange(0, 2)];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    [text appendAttributedString:titleText];
    [text appendAttributedString:bodyText];
    _label.attributedText = text;
    [self sizeToFit];
}

- (void)showInView:(UIView *)view atPoint:(CGPoint)point {
    if (self.superview != view) {
        self.leftTop = CGPointMake(point.x - 10, point.y);
        
        [view addSubview:self];
        [self sizeToFit];
        self.left = kSuperMargin;
        self.top = point.y;
        self.alpha = 0;
        
        _showPoint = [self.superview convertPoint:point toView:self];
        
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 1;
        }];
    }
}

- (void)showInWindowAtPoint:(CGPoint)point {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    if (self.superview == window) {
        return;
    }
    
    [window addSubview:self.backgroundView];
    [window addSubview:self];
    
    [self sizeToFit];

    self.left = kSuperMargin;
    self.top = point.y;
    self.alpha = 0;
    
    _showPoint = [self.superview convertPoint:point toView:self];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    }];
}

- (void)dismiss {
    if (self.superview) {
        [self.backgroundView removeFromSuperview];
        [UIView transitionWithView:self.superview duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self removeFromSuperview];
        } completion:NULL];
    }
}

- (SSJReportFormsCurveDescriptionBackView *)backgroundView {
    if (!_backgroundView) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        _backgroundView = [[SSJReportFormsCurveDescriptionBackView alloc] initWithFrame:window.bounds];
        _backgroundView.backgroundColor = [UIColor clearColor];
        [_backgroundView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchDown];
    }
    return _backgroundView;
}

@end
