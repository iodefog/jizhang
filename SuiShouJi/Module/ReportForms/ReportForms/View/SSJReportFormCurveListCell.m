//
//  SSJReportFormCurveListCell.m
//  SuiShouJi
//
//  Created by old lang on 16/12/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormCurveListCell.h"

@interface SSJReportFormCurveListCell ()

@property (nonatomic, strong) UIView *progressView;

@end

@implementation SSJReportFormCurveListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _progressView = [[UIView alloc] init];
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
    
    _progressView.leftTop = CGPointMake(10, 40);
    _progressView.height = 30;
    [self updateProgress:NO];
}

- (void)setCellItem:(SSJBaseItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJReportFormCurveListCellItem class]]) {
        return;
    }
    
    [super setCellItem:cellItem];
    
    self.textLabel.text = self.item.leftTitle;
    self.detailTextLabel.text = self.item.rightTitle;
    [self updateProgress:NO];
    _progressView.backgroundColor = [UIColor ssj_colorWithHex:self.item.progressColorValue];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.detailTextLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

- (void)updateProgress:(BOOL)animated {
    NSTimeInterval duration = animated ? 0.25 : 0;
    [UIView animateWithDuration:duration animations:^{
        _progressView.width = self.item.scale * (self.contentView.width - 20);
    }];
}

- (SSJReportFormCurveListCellItem *)item {
    return (SSJReportFormCurveListCellItem *)self.cellItem;
}

@end
