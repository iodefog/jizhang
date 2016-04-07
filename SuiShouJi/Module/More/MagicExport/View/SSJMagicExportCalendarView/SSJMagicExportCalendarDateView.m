//
//  SSJMagicExportCalendarDateView.m
//  SuiShouJi
//
//  Created by old lang on 16/4/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportCalendarDateView.h"
#import "SSJMagicExportCalendarViewCellItem.h"

@interface SSJMagicExportCalendarDateView ()

@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, strong) UILabel *descLabel;

@property (nonatomic, strong) UIImageView *marker;

@end

@implementation SSJMagicExportCalendarDateView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.dateLabel];
        [self addSubview:self.descLabel];
        [self addSubview:self.marker];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.dateLabel.top = 5;
    self.dateLabel.centerX = self.width * 0.5;
    self.descLabel.frame = CGRectMake(0, self.dateLabel.bottom, self.width, self.height - self.dateLabel.bottom);
    self.marker.center = CGPointMake(self.width * 0.5, self.dateLabel.bottom - self.marker.height * 0.8);
}

- (void)setSelected:(BOOL)selected {
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

#pragma mark - UIResponder
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (!_item.canSelect) {
        return;
    }
    
    _item.selected = !_item.selected;
    self.dateLabel.clipsToBounds = _item.selected;
    self.marker.tintColor = _item.selected ? [UIColor whiteColor] : [UIColor ssj_colorWithHex:@"ffa81c"];
    [UIView transitionWithView:self duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.dateLabel.backgroundColor = _item.selected ? [UIColor ssj_colorWithHex:@"00ccb3"] : [UIColor whiteColor];
        self.dateLabel.textColor = _item.selected ? [UIColor whiteColor] : _item.dateColor;
    } completion:NULL];
    
    if (_clickBlcok) {
        _clickBlcok(self);
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

#pragma mark - Getter
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
        _marker = [[UIImageView alloc] init];
        _marker.image = [[UIImage imageNamed:@"calender_star"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_marker sizeToFit];
    }
    return _marker;
}

@end
