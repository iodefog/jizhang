//
//  SSJTransferDetailHeader.m
//  SuiShouJi
//
//  Created by ricky on 16/6/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJTransferDetailHeader.h"
@interface SSJTransferDetailHeader()
@property(nonatomic, strong) UILabel *dateLabel;
@end
@implementation SSJTransferDetailHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.dateLabel];
        [self ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        [self ssj_setBorderStyle:SSJBorderStyleBottom];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.dateLabel.left = 10;
    self.dateLabel.centerY = self.height / 2;
    [self ssj_relayoutBorder];
}

-(UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _dateLabel.font = [UIFont systemFontOfSize:15];
    }
    return _dateLabel;
}

-(void)setCurrentMonth:(NSString *)currentMonth{
    _currentMonth = currentMonth;
    NSInteger month = [[[_currentMonth componentsSeparatedByString:@"-"] lastObject] integerValue];
    NSInteger year = [[[_currentMonth componentsSeparatedByString:@"-"] firstObject] integerValue];
    if ([_currentMonth isEqualToString:[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM"]]) {
        self.dateLabel.text = @"本月";
    }else if([_currentMonth hasPrefix:[NSString stringWithFormat:@"%ld",[NSDate date].year]]){
        self.dateLabel.text = [NSString stringWithFormat:@"%ld月",month];
    }else{
        self.dateLabel.text = [NSString stringWithFormat:@"%ld年%ld月",year,month];
    }
    [self.dateLabel sizeToFit];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
