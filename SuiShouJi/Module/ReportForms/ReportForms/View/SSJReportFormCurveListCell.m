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
        self.backgroundColor = [UIColor ssj_colorWithHex:@"cacaca"];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 3;
    }
    return self;
}

- (void)layoutSubviews {
    _surfaceView.frame = CGRectMake(0, 0, self.width * _progress, self.height);
}

- (void)setFillColor:(UIColor *)fillColor {
    _surfaceView.backgroundColor = fillColor;
}

- (void)setProgress:(CGFloat)progress {
    if (_progress != progress) {
        _progress = progress;
        _surfaceView.frame = CGRectMake(0, 0, self.width * MAX(1, _progress), self.height);
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

@end

@implementation SSJReportFormCurveListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _progressView = [[SSJReportFormProgressView alloc] init];
        [self.contentView addSubview:_progressView];
        
        self.textLabel.font = [UIFont systemFontOfSize:12];
        self.detailTextLabel.font = [UIFont systemFontOfSize:12];
        self.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.textLabel sizeToFit];
    [self.detailTextLabel sizeToFit];
    
    self.textLabel.leftTop = CGPointMake(10, 20);
    self.detailTextLabel.rightTop = CGPointMake(self.contentView.width - 10, 20);
    self.detailTextLabel.left = MAX(self.detailTextLabel.left, self.textLabel.right + 20);
    
    _progressView.frame = CGRectMake(10, 40, self.contentView.width - 20, 30);
}

- (void)setCellItem:(SSJBaseItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJReportFormCurveListCellItem class]]) {
        return;
    }
    
    [super setCellItem:cellItem];
    
    self.textLabel.text = self.item.leftTitle;
    self.detailTextLabel.text = self.item.rightTitle;
    _progressView.progress = self.item.scale;
    [_progressView setFillColor:[UIColor ssj_colorWithHex:self.item.progressColorValue]];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.detailTextLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

- (SSJReportFormCurveListCellItem *)item {
    return (SSJReportFormCurveListCellItem *)self.cellItem;
}

@end
