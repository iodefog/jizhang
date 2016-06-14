//
//  SSJMagicExportCalendarHeaderView.m
//  SuiShouJi
//
//  Created by old lang on 16/4/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportCalendarHeaderView.h"

@implementation SSJMagicExportCalendarHeaderView

- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.textLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        self.textLabel.font = [UIFont systemFontOfSize:18];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.contentView.backgroundColor = [UIColor ssj_colorWithHex:@"f6f6f6"];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.center = CGPointMake(self.contentView.width * 0.5, self.contentView.height * 0.5);
}

@end
