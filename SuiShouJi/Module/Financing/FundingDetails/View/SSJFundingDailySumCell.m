
//
//  SSJFundingDailySumCell.m
//  SuiShouJi
//
//  Created by ricky on 16/3/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingDailySumCell.h"

@interface SSJFundingDailySumCell()

@property(nonatomic, strong) UILabel *dateLabel;

@end

@implementation SSJFundingDailySumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.dateLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.dateLabel.left = 15;
    self.dateLabel.bottom = self.height;
}

-(UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _dateLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _dateLabel;
}


-(void)setItem:(SSJFundingListDayItem *)item{
    _item = item;
    NSDate *billDate = [NSDate dateWithString:_item.date formatString:@"yyyy-MM-dd"];
    NSString *dateStr;
    if ([billDate isSameDay:[NSDate date]]) {
        dateStr = @"今天";
        self.dateLabel.text = dateStr;
    } else  if ([billDate isSameDay:[[NSDate date] dateBySubtractingDays:1]]) {
        dateStr = @"昨天";
        self.dateLabel.text = dateStr;
    } else {
        dateStr = [billDate formattedDateWithFormat:@"yyyy年MM月dd日"];
        NSString *weekStr;
        
        switch (billDate.weekday) {
            case 1 : {
                weekStr = @"星期日";
                break;
            }
            case 2 : {
                weekStr = @"星期一";
                break;
            }
            case 3 : {
                weekStr = @"星期二";
                break;
            }
            case 4 : {
                weekStr = @"星期三";
                break;
            }
            case 5 : {
                weekStr = @"星期四";
                break;
            }
            case 6 : {
                weekStr = @"星期五";
                break;
            }
            case 7 : {
                weekStr = @"星期六";
                break;
            }
                
            default : {
                weekStr = @"";
                break;
            }
        }
        self.dateLabel.text = [NSString stringWithFormat:@"%@ %@",dateStr,weekStr];

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
