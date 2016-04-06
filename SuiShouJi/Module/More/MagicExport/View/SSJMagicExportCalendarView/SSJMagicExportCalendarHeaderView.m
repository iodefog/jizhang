//
//  SSJMagicExportCalendarHeaderView.m
//  SuiShouJi
//
//  Created by old lang on 16/4/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportCalendarHeaderView.h"

@interface SSJMagicExportCalendarHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation SSJMagicExportCalendarHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor ssj_colorWithHex:@"00ccb3"];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _titleLabel.frame = self.bounds;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

@end
