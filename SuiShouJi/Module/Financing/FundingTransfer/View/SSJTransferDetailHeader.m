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
        [self addSubview:self.dateLabel];
        [self ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        [self ssj_setBorderStyle:SSJBorderStyleBottom];
        if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
            self.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
        } else {
            self.backgroundColor = [UIColor clearColor];
        }
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.dateLabel.left = 10;
    self.dateLabel.centerY = self.height / 2;
}

-(UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _dateLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _dateLabel;
}

- (void)setDate:(NSDate *)date {
    NSDate *currentDate = [NSDate date];
    if (date.year == currentDate.year && date.month == currentDate.month) {
        self.dateLabel.text = @"本月";
    } else if (date.year == currentDate.year && date.month != currentDate.month) {
        self.dateLabel.text = [NSString stringWithFormat:@"%d月", (int)date.month];
    } else {
        self.dateLabel.text = [NSString stringWithFormat:@"%d年%d月", (int)date.year, (int)date.month];
    }
    [self.dateLabel sizeToFit];
}

@end
