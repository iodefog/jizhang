//
//  SSJMagicExportCalendarDateView.m
//  SuiShouJi
//
//  Created by old lang on 16/4/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportCalendarDateView.h"

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJMagicExportCalendarDateView
#pragma mark -

#define kCircleCenterY self.height * 0.37
static const CGFloat kCircleDiam = 35;

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
        
        _observedKeyPaths = [NSArray arrayWithObjects:@"hidden", @"showMarker", @"date", @"desc", @"dateColor", @"descColor", @"markerColor", @"fillColor", nil];
        
        [self addSubview:self.dateLabel];
        [self addSubview:self.descLabel];
        [self addSubview:self.marker];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.dateLabel sizeToFit];
    self.dateLabel.center = CGPointMake(self.width * 0.5, kCircleCenterY);
    self.marker.centerX = self.width * 0.5;
    self.marker.top = self.dateLabel.bottom;
    CGFloat descTop = kCircleCenterY + kCircleDiam * 0.5;
    self.descLabel.frame = CGRectMake(0, descTop, self.width, self.height - descTop);
}

- (void)drawRect:(CGRect)rect {
    if (_item.fillColor) {
        CGFloat left = (self.width - kCircleDiam) * 0.5;
        CGFloat top = kCircleCenterY - kCircleDiam * 0.5;
        CGRect roundedRect = CGRectMake(left, top, kCircleDiam, kCircleDiam);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:roundedRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(kCircleDiam * 0.5, kCircleDiam * 0.5)];
        [_item.fillColor setFill];
        [path fill];
    }
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
    self.dateLabel.textColor = _item.dateColor;
    
    self.descLabel.text = _item.desc;
    self.descLabel.textColor = _item.descColor;
    
    self.marker.hidden = !_item.showMarker;
    self.marker.tintColor = _item.markerColor;
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

#pragma mark - UIResponder
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (!_item.hidden && _clickBlock) {
        _clickBlock(self);
    }
}

#pragma mark - Getter
- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.layer.cornerRadius = _dateLabel.width * 0.5;
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _dateLabel;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
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


////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJMagicExportCalendarDateViewItem
#pragma mark -

@implementation SSJMagicExportCalendarDateViewItem

- (NSString *)debugDescription {
    return [self ssj_debugDescription];
}

@end
