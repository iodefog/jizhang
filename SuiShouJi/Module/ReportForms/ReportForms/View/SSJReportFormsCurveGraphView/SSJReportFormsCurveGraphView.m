//
//  SSJReportFormsCurveGraphView.m
//  SSJCurveGraphDemo
//
//  Created by old lang on 16/6/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveGraphView.h"
#import "SSJReportFormsCurveView.h"
#import "SSJReportFormsCurveAxisView.h"

static const CGFloat kTopSpaceHeight = 106;
static const CGFloat kBottomSpaceHeight = 32;

@interface SSJReportFormsCurveGraphView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) SSJReportFormsCurveView *curveView;

@property (nonatomic, strong) SSJReportFormsCurveAxisView *axisXView;

@property (nonatomic, strong) UIView *verticalLine;

@property (nonatomic, strong) UIView *paymentPoint;

@property (nonatomic, strong) UIView *incomePoint;

@property (nonatomic, strong) UILabel *paymentLabel;

@property (nonatomic, strong) UILabel *paymentValueLabel;

@property (nonatomic, strong) UILabel *incomeLabel;

@property (nonatomic, strong) UILabel *incomeValueLabel;

@property (nonatomic, strong) UILabel *surplusLabel;

@property (nonatomic, strong) UILabel *surplusValueLabel;

@property (nonatomic, strong) UIImageView *balloonView;

@property (nonatomic, strong) NSMutableArray *paymentValues;

@property (nonatomic, strong) NSMutableArray *incomeValues;

@property (nonatomic, strong) NSMutableArray *axisYLabels;

@property (nonatomic, strong) NSMutableArray *horizontalLines;

@property (nonatomic) long maxValue;

@property (nonatomic) NSUInteger axisXCount;

@property (nonatomic) NSUInteger selectedAxisXIndex;

// X轴刻度宽度
@property (nonatomic) CGFloat unitX;

@property (nonatomic) CGFloat margin;

@end

@implementation SSJReportFormsCurveGraphView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        _displayAxisXCount = 7;
        _bezierSmoothingTension = 0.3;
        _selectedAxisXIndex = 1;
        
        _paymentValues = [[NSMutableArray alloc] init];
        _incomeValues = [[NSMutableArray alloc] init];
        _axisYLabels = [[NSMutableArray alloc] init];
        _horizontalLines = [[NSMutableArray alloc] init];
        
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        _scrollView.showsHorizontalScrollIndicator = NO;
//        _scrollView.bounces = NO;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        
        _curveView = [[SSJReportFormsCurveView alloc] init];
        [_scrollView addSubview:_curveView];
        
        _axisXView = [[SSJReportFormsCurveAxisView alloc] init];
        [_scrollView addSubview:_axisXView];
        
        _verticalLine = [[UIView alloc] init];
        _verticalLine.backgroundColor = [UIColor ssj_colorWithHex:@"f56262"];
        [self addSubview:_verticalLine];
        
        _paymentPoint = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
        _paymentPoint.layer.cornerRadius = 4;
        _paymentPoint.clipsToBounds = YES;
        _paymentPoint.backgroundColor = [UIColor ssj_colorWithHex:@"59ae65"];
        [self addSubview:_paymentPoint];
        
        _incomePoint = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
        _incomePoint.layer.cornerRadius = 4;
        _incomePoint.clipsToBounds = YES;
        _incomePoint.backgroundColor = [UIColor ssj_colorWithHex:@"f56262"];
        [self addSubview:_incomePoint];
        
        _paymentLabel = [[UILabel alloc] init];
        _paymentLabel.backgroundColor = [UIColor clearColor];
        _paymentLabel.font = [UIFont systemFontOfSize:10];
        _paymentLabel.textColor = [UIColor ssj_colorWithHex:@"389F47"];
        _paymentLabel.text = @"支出";
        [_paymentLabel sizeToFit];
        [self addSubview:_paymentLabel];
        
        _paymentValueLabel = [[UILabel alloc] init];
        _paymentValueLabel.backgroundColor = [UIColor clearColor];
        _paymentValueLabel.font = [UIFont systemFontOfSize:12];
        _paymentValueLabel.textColor = [UIColor ssj_colorWithHex:@"389F47"];
        [self addSubview:_paymentValueLabel];
        
        _incomeLabel = [[UILabel alloc] init];
        _incomeLabel.backgroundColor = [UIColor clearColor];
        _incomeLabel.font = [UIFont systemFontOfSize:10];
        _incomeLabel.textColor = [UIColor ssj_colorWithHex:@"D73939"];
        _incomeLabel.text = @"收入";
        [_incomeLabel sizeToFit];
        [self addSubview:_incomeLabel];
        
        _incomeValueLabel = [[UILabel alloc] init];
        _incomeValueLabel.backgroundColor = [UIColor clearColor];
        _incomeValueLabel.font = [UIFont systemFontOfSize:12];
        _incomeValueLabel.textColor = [UIColor ssj_colorWithHex:@"D73939"];
        [self addSubview:_incomeValueLabel];
        
        _balloonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reportForms_balloon"]];
        [self addSubview:_balloonView];
        
        _surplusLabel = [[UILabel alloc] init];
        _surplusLabel.backgroundColor = [UIColor clearColor];
        _surplusLabel.font = [UIFont systemFontOfSize:10];
        _surplusLabel.textColor = [UIColor whiteColor];
        _surplusLabel.text = @"结余";
        [_surplusLabel sizeToFit];
        [_balloonView addSubview:_surplusLabel];
        
        _surplusValueLabel = [[UILabel alloc] init];
        _surplusValueLabel.textAlignment = NSTextAlignmentCenter;
        _surplusValueLabel.backgroundColor = [UIColor clearColor];
        _surplusValueLabel.font = [UIFont systemFontOfSize:12];
        _surplusValueLabel.textColor = [UIColor whiteColor];
        [_balloonView addSubview:_surplusValueLabel];
        
        [self updateSubviewHidden];
    }
    return self;
}

- (void)updateSubviewHidden {
    if (_axisXCount > 0) {
        _verticalLine.hidden = NO;
        _paymentPoint.hidden = NO;
        _incomePoint.hidden = NO;
        _paymentLabel.hidden = NO;
        _paymentValueLabel.hidden = NO;
        _balloonView.hidden = NO;
    } else {
        _verticalLine.hidden = YES;
        _paymentPoint.hidden = YES;
        _incomePoint.hidden = YES;
        _paymentLabel.hidden = YES;
        _paymentValueLabel.hidden = YES;
        _balloonView.hidden = YES;
    }
}

- (void)layoutSubviews {
    if (_axisXCount == 0) {
        return;
    }
    
    CGFloat unitHeight = (self.height - kTopSpaceHeight - kBottomSpaceHeight) * 0.2;
    
    for (int i = 0; i < _axisYLabels.count; i ++) {
        UILabel *label = _axisYLabels[i];
        label.bottom = unitHeight * i + kTopSpaceHeight - 2;
    }
    
    for (int i = 0; i < _horizontalLines.count; i ++) {
        UIView *line = _horizontalLines[i];
        line.frame = CGRectMake(0, kTopSpaceHeight + unitHeight * i, self.width, 1 / [UIScreen mainScreen].scale);
    }
    
    if (_axisXCount == 1) {
        _unitX = 0;
        _margin = self.width * 0.5;
    } else if (_axisXCount <= 4) {
        _unitX = self.width * 0.5 / (_axisXCount - 0.5);
        _margin = _unitX * 0.5;
    } else {
        _unitX = self.width / _displayAxisXCount;
        _margin = _unitX * 0.5;
    }
    
    CGFloat width = _unitX * (_axisXCount - 1) + _margin;
    
    _curveView.frame = CGRectMake(0, kTopSpaceHeight, width, self.height - kTopSpaceHeight - kBottomSpaceHeight);
    _curveView.margin = _margin;
    
    _axisXView.frame = CGRectMake(0, self.height - kBottomSpaceHeight, width, kBottomSpaceHeight);
    _axisXView.margin = _margin;
    
    _scrollView.frame = self.bounds;
    _scrollView.contentSize = CGSizeMake(width, self.height);
    _scrollView.contentInset = UIEdgeInsetsMake(0, _axisXCount == 1 ? 0 : _scrollView.width * 0.5 - _margin, 0, _scrollView.width * 0.5);
    [_scrollView setContentOffset:CGPointMake(_margin + _unitX * (_selectedAxisXIndex - 1) - self.width * 0.5, 0) animated:NO];
    
    _verticalLine.frame = CGRectMake(self.width * 0.5, 60, 1 / [UIScreen mainScreen].scale, self.height - 60 - kBottomSpaceHeight);
    
    _balloonView.centerX = self.width * 0.5;
    _balloonView.top = 10;
    _surplusLabel.top = 10;
    _surplusLabel.centerX = _balloonView.width * 0.5;
    _surplusValueLabel.size = CGSizeMake(100, 12);
    _surplusValueLabel.top = _surplusLabel.bottom + 2;
    _surplusValueLabel.centerX = _balloonView.width * 0.5;
    
    [self adjustPaymentAndIncomePoint];
}

- (void)reloadData {
    if (!_delegate
        || ![_delegate respondsToSelector:@selector(numberOfAxisXInCurveGraphView:)]
        || ![_delegate respondsToSelector:@selector(curveGraphView:titleAtAxisXIndex:)]
        || ![_delegate respondsToSelector:@selector(curveGraphView:paymentValueAtAxisXIndex:)]
        || ![_delegate respondsToSelector:@selector(curveGraphView:incomeValueAtAxisXIndex:)]) {
        return;
    }
    
    _axisXCount = [_delegate numberOfAxisXInCurveGraphView:self];
    if (_axisXCount == 0) {
        NSLog(@"numberOfAxisXInCurveGraphView不能返回0");
        return;
    }
    
    [_axisYLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_axisYLabels removeAllObjects];
    
    [_horizontalLines makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_horizontalLines removeAllObjects];
    
    [_paymentValues removeAllObjects];
    [_incomeValues removeAllObjects];
    
    [_paymentValues addObject:@0];
    [_incomeValues addObject:@0];
    
    CGFloat tMaxValue = 0;
    NSMutableArray *axisXTitles = [NSMutableArray arrayWithCapacity:_axisXCount];
    
    for (int idx = 0; idx < _axisXCount; idx ++) {
        
        CGFloat paymentValue = [_delegate curveGraphView:self paymentValueAtAxisXIndex:idx];
        if (paymentValue < 0) {
            NSLog(@"支出value不能为负数");
            return;
        }
        [_paymentValues addObject:@(paymentValue)];
        
        CGFloat incomeValue = [_delegate curveGraphView:self incomeValueAtAxisXIndex:idx];
        if (incomeValue < 0) {
            NSLog(@"收入value不能为负数");
            return;
        }
        [_incomeValues addObject:@(incomeValue)];
        
        NSString *title = [_delegate curveGraphView:self titleAtAxisXIndex:idx];
        if (!title) {
            NSLog(@"X轴title不能为nil");
            return;
        }
        [axisXTitles addObject:title];
        
        tMaxValue = MAX(MAX(tMaxValue, paymentValue), incomeValue);
    }
    
    int index = 0;
    int topDigit = tMaxValue;
    while (topDigit >= 10) {
        topDigit = topDigit / 10;
        index ++;
    }
    
    BOOL showScaleValue = topDigit > 0;
    _maxValue = (topDigit + 1) * pow(10, index);
    
    _curveView.maxValue = _maxValue;
    _curveView.width = self.width / _displayAxisXCount * _axisXCount;
    _curveView.paymentValues = _paymentValues;
    _curveView.incomeValues = _incomeValues;
    [_curveView setNeedsDisplay];
    
    [_axisXView setAxisTitles:axisXTitles];
    
    _scrollView.contentSize = _curveView.size;
    
    long unitValue = _maxValue * 0.2;
    for (int i = 0; i < 6; i ++) {
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor ssj_colorWithHex:@"CCCCCC"];
        label.text = [NSString stringWithFormat:@"%ld", _maxValue - i * unitValue];
        label.hidden = !showScaleValue;
        [label sizeToFit];
        [self addSubview:label];
        [_axisYLabels addObject:label];
        
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [UIColor ssj_colorWithHex:@"CCCCCC"];
        [self addSubview:line];
        [_horizontalLines addObject:line];
    }
    
    [self updateSubviewHidden];
    [self setNeedsLayout];
}

- (void)scrollToAxisXAtIndex:(NSUInteger)index animated:(BOOL)animted {
    if (index > _axisXCount - 1) {
        NSLog(@"超出最大X轴刻度范围");
        return;
    }
    _selectedAxisXIndex = index + 1;
    [_scrollView setContentOffset:CGPointMake(_margin + _unitX * (_selectedAxisXIndex - 1) - self.width * 0.5, 0) animated:animted];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x == -scrollView.contentInset.left) {
        _selectedAxisXIndex = 1;
        [self adjustPaymentAndIncomePoint];
    } else if (scrollView.contentOffset.x == _axisXView.width - _scrollView.width * 0.5) {
        _selectedAxisXIndex = _axisXCount;
        [self adjustPaymentAndIncomePoint];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self adjustOffSetXToCenter];
    if (_delegate && [_delegate respondsToSelector:@selector(curveGraphView:didScrollToAxisXIndex:)]) {
        [_delegate curveGraphView:self didScrollToAxisXIndex:_selectedAxisXIndex];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self adjustOffSetXToCenter];
        if (_delegate && [_delegate respondsToSelector:@selector(curveGraphView:didScrollToAxisXIndex:)]) {
            [_delegate curveGraphView:self didScrollToAxisXIndex:_selectedAxisXIndex];
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self adjustPaymentAndIncomePoint];
}

- (void)adjustOffSetXToCenter {
    CGFloat centerOffSetX = self.width * 0.5 + _scrollView.contentOffset.x - _margin;
    CGFloat unitCount = floor(centerOffSetX / _unitX);
    if (centerOffSetX - unitCount * _unitX >= _unitX * 0.5) {
        unitCount ++;
    }
    
    CGFloat offSetX = unitCount * _unitX + _margin - self.width * 0.5;
    [_scrollView setContentOffset:CGPointMake(offSetX, 0) animated:YES];
    _selectedAxisXIndex = unitCount + 1;
}

- (void)adjustPaymentAndIncomePoint {
    if (_axisXCount == 0) {
        return;
    }
    
    CGFloat paymentHeight = [_paymentValues[_selectedAxisXIndex] floatValue] / _maxValue * (self.height - kTopSpaceHeight - kBottomSpaceHeight);
    CGFloat paymentY = self.height - paymentHeight - kBottomSpaceHeight;
    _paymentPoint.center = CGPointMake(self.width * 0.5, paymentY);
    
    CGFloat incomeHeight = [_incomeValues[_selectedAxisXIndex] floatValue] / _maxValue * (self.height - kTopSpaceHeight - kBottomSpaceHeight);
    CGFloat incomeY = self.height - incomeHeight - kBottomSpaceHeight;
    _incomePoint.center = CGPointMake(self.width * 0.5, incomeY);
    
    _paymentValueLabel.text = [NSString stringWithFormat:@"%@", _paymentValues[_selectedAxisXIndex]];
    [_paymentValueLabel sizeToFit];
    _paymentValueLabel.centerX = self.width * 0.5;
    _paymentValueLabel.bottom = _paymentPoint.top;
    
    _paymentLabel.centerX = self.width * 0.5;
    _paymentLabel.bottom = _paymentValueLabel.top;
    
    _incomeValueLabel.text = [NSString stringWithFormat:@"%@", _incomeValues[_selectedAxisXIndex]];
    [_incomeValueLabel sizeToFit];
    _incomeValueLabel.centerX = self.width * 0.5;
    _incomeValueLabel.bottom = _incomePoint.top;
    
    _incomeLabel.centerX = self.width * 0.5;
    _incomeLabel.bottom = _incomeValueLabel.top;
    
    [self checkIfIncomeAndPaymentPointIntersect];
    
    float surplus = [_incomeValues[_selectedAxisXIndex] floatValue] - [_paymentValues[_selectedAxisXIndex] floatValue];
    _surplusValueLabel.text = [NSString stringWithFormat:@"%.2f", surplus];
}

- (void)checkIfIncomeAndPaymentPointIntersect {
    
    CGRect incomeTextRect = CGRectUnion(_incomeLabel.frame, _incomeValueLabel.frame);
    CGRect paymentTextRect = CGRectUnion(_paymentLabel.frame, _paymentValueLabel.frame);
    
    if (CGRectIntersectsRect(_incomePoint.frame, paymentTextRect)) {
        _paymentLabel.centerX = _paymentValueLabel.centerX = self.width * 0.5 + paymentTextRect.size.width * 0.5;
    }
    
    if (CGRectIntersectsRect(_paymentPoint.frame, incomeTextRect)) {
        _incomeLabel.centerX = _incomeValueLabel.centerX = self.width * 0.5 - incomeTextRect.size.width * 0.5;
    }
    
    if (CGRectIntersectsRect(incomeTextRect, paymentTextRect)) {
        _paymentLabel.centerX = _paymentValueLabel.centerX = self.width * 0.5 + paymentTextRect.size.width * 0.5;
        _incomeLabel.centerX = _incomeValueLabel.centerX = self.width * 0.5 - incomeTextRect.size.width * 0.5;
    }
}

@end
