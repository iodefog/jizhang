//
//  SSJMagicExportCalendarDateView.m
//  SuiShouJi
//
//  Created by old lang on 16/4/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportCalendarDateView.h"
#import "SSJMagicExportCalendarDateViewItem.h"

@interface SSJMagicExportCalendarDateView ()

@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, strong) UILabel *descLabel;

@property (nonatomic, strong) UIImageView *marker;

@property (nonatomic, strong) NSArray *observedKeyPaths;

@end

@implementation SSJMagicExportCalendarDateView

- (void)dealloc {
    for (NSString *keyPath in _observedKeyPaths) {
        [_item removeObserver:self forKeyPath:keyPath];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _observedKeyPaths = [NSArray arrayWithObjects:@"hidden", @"selected", @"showMarker", @"date", @"desc", @"dateColor", @"selectedDateColor", @"highlightColor", nil];
        
        [self addSubview:self.dateLabel];
        [self addSubview:self.descLabel];
        [self addSubview:self.marker];
        
        self.backgroundColor = [UIColor clearColor];
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

- (void)setItem:(SSJMagicExportCalendarDateViewItem *)item {
    if (_item != item) {
        
        for (NSString *keyPath in _observedKeyPaths) {
            [_item removeObserver:self forKeyPath:keyPath];
        }
        
        _item = item;
        
        for (NSString *keyPath in _observedKeyPaths) {
            [_item addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
        }
        
        [self updateAppearance];
    }
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    
    if (object == _item) {
        [self updateAppearance];
    }
}

- (void)updateAppearance {
    self.hidden = _item.hidden;
    
    self.dateLabel.text = [NSString stringWithFormat:@"%d", (int)_item.date.day];
    self.dateLabel.textColor = _item.selected ? _item.selectedDateColor : _item.dateColor;
    self.dateLabel.clipsToBounds = _item.selected;
    self.dateLabel.backgroundColor = _item.selected ? _item.highlightColor : [UIColor clearColor];
    
    self.descLabel.text = _item.selected ? _item.desc : nil;
    self.descLabel.textColor = _item.highlightColor;
    
    self.marker.hidden = !_item.showMarker;
    self.marker.tintColor = _item.selected ? [UIColor whiteColor] : _item.highlightColor;
}

#pragma mark - UIResponder
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    BOOL shouldSelect = YES;
    if (_shouldSelectBlock) {
        shouldSelect = _shouldSelectBlock(self);
    }
    
    if (shouldSelect) {
        _item.selected = YES;
        
        [self updateAppearance];
        
        if (_didSelectBlock) {
            _didSelectBlock(self);
        }
    }
}

#pragma mark - Getter
- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        _dateLabel.layer.cornerRadius = _dateLabel.width * 0.5;
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_4);
        _dateLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _dateLabel;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_4);
        _descLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _descLabel;
}

- (UIImageView *)marker {
    if (!_marker) {
        _marker = [[UIImageView alloc] init];
        _marker.image = [[UIImage imageNamed:@"calendar_star"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_marker sizeToFit];
    }
    return _marker;
}

@end
