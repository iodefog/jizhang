//
//  SSJCalendarTabelViewHeaderView.m
//  SuiShouJi
//
//  Created by ricky on 2017/2/8.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCalendarTabelViewHeaderView.h"

@interface SSJCalendarTabelViewHeaderView()

@property(nonatomic, strong) UILabel *dateLabel;

@property(nonatomic, strong) UILabel *incomeLabel;

@property(nonatomic, strong) UILabel *expenceLabel;

@property(nonatomic, strong) UILabel *balanceLabel;

@end

@implementation SSJCalendarTabelViewHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.dateLabel];
        [self addSubview:self.incomeLabel];
        [self addSubview:self.expenceLabel];
        [self addSubview:self.balanceLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (UILabel *)dateLabel {
    
    if (_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
    }
    
    return _dateLabel;
}

- (UILabel *)incomeLabel {
    
    if (_incomeLabel) {
        _incomeLabel = [[UILabel alloc] init];
    }
    
    return _incomeLabel;
}

- (UILabel *)expenceLabel {
    
    if (_expenceLabel) {
        _expenceLabel = [[UILabel alloc] init];

    }
    
    return _expenceLabel;
}

- (UILabel *)balanceLabel {
    
    if (_balanceLabel) {
        _balanceLabel = [[UILabel alloc] init];

    }
    
    return _balanceLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
