//
//  SSJReportFormsCurveDescriptionView.m
//  SuiShouJi
//
//  Created by old lang on 16/6/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveDescriptionView.h"
#import "SSJDatePeriod.h"

const UIEdgeInsets kTextInset = {15, 5, 10, 5};

@interface SSJReportFormsCurveDescriptionView ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation SSJReportFormsCurveDescriptionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _label = [[UILabel alloc] init];
        _label.numberOfLines = 0;
        _label.font = [UIFont systemFontOfSize:10];
        _label.width = [UIScreen mainScreen].bounds.size.width * 0.94 - kTextInset.left - kTextInset.right;
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
    [path moveToPoint:CGPointMake(4, 5)];
    [path addLineToPoint:CGPointMake(10, 0)];
    [path addLineToPoint:CGPointMake(16, 5)];
    
    [[UIColor ssj_colorWithHex:@"f6f6f6"] setFill];
    [path fill];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    return CGSizeMake(screenSize.width * 0.94, _label.height + kTextInset.top + kTextInset.bottom);
}

- (void)setPeriod:(SSJDatePeriod *)period {
    _period = period;
    
    NSString *beginDateStr = [_period.startDate formattedDateWithFormat:@"M月d日"];
    NSString *endDateStr = [_period.endDate formattedDateWithFormat:@"M月d日"];
    NSAttributedString *titleText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@-%@\n\n", beginDateStr, endDateStr] attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"393939"]}];
    NSMutableAttributedString *bodyText = [[NSMutableAttributedString alloc] initWithString:@"注：选择自定义时间，第一周以截止到周日计，最有一周计至截止日的最后一天，其它周则以正常7天计数。" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"929292"]}];
    [bodyText setAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"393939"]} range:NSMakeRange(0, 2)];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    [text appendAttributedString:titleText];
    [text appendAttributedString:bodyText];
    _label.attributedText = text;
    [_label sizeToFit];
    [self sizeToFit];
}

- (void)showInView:(UIView *)view atPoint:(CGPoint)point {
    if (self.superview != view) {
        self.leftTop = CGPointMake(point.x - 10, point.y);
        [UIView transitionWithView:view duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [view addSubview:self];
        } completion:NULL];
    }
}

- (void)dismiss {
    if (self.superview) {
        [UIView transitionWithView:self.superview duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self removeFromSuperview];
        } completion:NULL];
    }
}

@end
