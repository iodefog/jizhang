//
//  SSJMagicExportCalendarViewCell.m
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportCalendarViewCell.h"

@interface SSJMagicExportCalendarViewCell ()

@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, strong) UILabel *descLabel;

@property (nonatomic, strong) UIImageView *marker;

@end

@implementation SSJMagicExportCalendarViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.descLabel];
        [self.contentView addSubview:self.marker];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.dateLabel.top = 5;
    self.dateLabel.centerX = self.contentView.width * 0.5;
    self.descLabel.frame = CGRectMake(0, self.dateLabel.bottom, self.contentView.width, self.contentView.height - self.dateLabel.bottom);
    self.marker.center = CGPointMake(self.contentView.width * 0.5, self.dateLabel.bottom - self.marker.height * 0.8);
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    _item.selected = selected;
    [UIView animateWithDuration:0.25 animations:^{
        [self updateAccordingToSelectState];
    }];
}

- (void)setItem:(SSJMagicExportCalendarViewCellItem *)item {
    _item = item;
    self.userInteractionEnabled = _item.canSelect;
    self.marker.hidden = (!_item.showMarker || !_item.showContent);
    self.dateLabel.hidden = self.descLabel.hidden = !_item.showContent;
    self.dateLabel.text = [NSString stringWithFormat:@"%d", _item.date.day];
    [self updateAccordingToSelectState];
}

- (void)updateAccordingToSelectState {
    self.dateLabel.clipsToBounds = _item.selected;
    self.dateLabel.backgroundColor = _item.selected ? [UIColor ssj_colorWithHex:@"00ccb3"] : [UIColor whiteColor];
    self.dateLabel.textColor = _item.selected ? [UIColor whiteColor] : _item.dateColor;
    self.marker.tintColor = _item.selected ? [UIColor whiteColor] : [UIColor ssj_colorWithHex:@"ffa81c"];
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        _dateLabel.layer.cornerRadius = _dateLabel.width * 0.5;
        _dateLabel.backgroundColor = [UIColor whiteColor];
        _dateLabel.font = [UIFont systemFontOfSize:13];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _dateLabel;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.backgroundColor = [UIColor whiteColor];
        _descLabel.font = [UIFont systemFontOfSize:13];
        _descLabel.textColor = [UIColor  ssj_colorWithHex:@"00ccb3"];
        _descLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _descLabel;
}

- (UIImageView *)marker {
    if (!_marker) {
        _marker = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calender_star"]];
    }
    return _marker;
}

@end
