//
//  SSJFundingDetailDateHeader.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingDetailDateHeader.h"
@interface SSJFundingDetailDateHeader()

@end

@implementation SSJFundingDetailDateHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.dateLabel];
        [self addSubview:self.balanceLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.dateLabel.left = 10;
    self.dateLabel.centerY = self.height / 2;
    self.balanceLabel.right = self.width - 10;
    self.balanceLabel.centerY = self.height / 2;
}

-(UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _dateLabel.font = [UIFont systemFontOfSize:15];
    }
    return _dateLabel;
}

-(UILabel *)balanceLabel{
    if (!_balanceLabel) {
        _balanceLabel = [[UILabel alloc]init];
        _balanceLabel.textColor = [UIColor ssj_colorWithHex:@"a9a9a9"];
        _balanceLabel.font = [UIFont systemFontOfSize:15];
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
