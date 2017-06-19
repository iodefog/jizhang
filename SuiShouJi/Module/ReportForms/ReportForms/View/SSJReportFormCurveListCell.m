//
//  SSJReportFormCurveListCell.m
//  SuiShouJi
//
//  Created by old lang on 16/12/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormCurveListCell.h"

@interface SSJReportFormProgressView : UIView

@property (nonatomic) CGFloat progress;

- (void)setFillColor:(UIColor *)fillColor;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end

@interface SSJReportFormProgressView ()

@property (nonatomic, strong) UIView *surfaceView;

@end

@implementation SSJReportFormProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _surfaceView = [[UIView alloc] init];
        [self addSubview:_surfaceView];
        self.backgroundColor = [UIColor ssj_colorWithHex:@"f6f6f6"];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 3;
    }
    return self;
}

- (void)layoutSubviews {
    _surfaceView.frame = CGRectMake(0, 0, self.width * MIN(1, _progress), self.height);
}

- (void)setFillColor:(UIColor *)fillColor {
    _surfaceView.backgroundColor = fillColor;
}

- (void)setProgress:(CGFloat)progress {
    if (_progress != progress) {
        _progress = progress;
        _surfaceView.frame = CGRectMake(0, 0, self.width * MIN(1, _progress), self.height);
    }
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    NSTimeInterval duration = animated ? 0.25 : 0;
    [UIView animateWithDuration:duration animations:^{
        self.progress = progress;
    }];
}

@end

@interface SSJReportFormCurveListCell ()

@property (nonatomic, strong) SSJReportFormProgressView *progressView;

@property (nonatomic, strong) UILabel *rightLabel;

@end

@implementation SSJReportFormCurveListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.textLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        [self addSubview:_rightLabel];
        
        _progressView = [[SSJReportFormProgressView alloc] init];
        [self.contentView addSubview:_progressView];
        
        self.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self updateAppearance];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.textLabel sizeToFit];
    [_rightLabel sizeToFit];
    
    self.textLabel.leftTop = CGPointMake(10, 20);
    
    CGFloat maxRightLabWidth = (self.contentView.width - self.textLabel.right - 10 - 20);
    _rightLabel.width = MIN(_rightLabel.width, maxRightLabWidth);
    _rightLabel.rightTop = CGPointMake(self.contentView.width - 5, 20);
    
    _progressView.frame = CGRectMake(10, 40, self.contentView.width - 15, 30);
}

- (void)setCellItem:(SSJBaseCellItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJReportFormCurveListCellItem class]]) {
        return;
    }
    
    [super setCellItem:cellItem];
    
    self.textLabel.text = [NSString stringWithFormat:@"%@ %@", self.item.leftTitle1, self.item.leftTitle2];
    _rightLabel.text = self.item.rightTitle;
    _progressView.progress = self.item.scale;
    [_progressView setFillColor:[UIColor ssj_colorWithHex:self.item.progressColorValue]];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _rightLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

- (SSJReportFormCurveListCellItem *)item {
    return (SSJReportFormCurveListCellItem *)self.cellItem;
}

@end
