//
//  SSJReminderWeekDaySelectView.m
//  SuiShouJi
//
//  Created by ricky on 16/9/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReminderWeekDaySelectView.h"

@interface SSJReminderWeekDaySelectView()

@property(nonatomic, strong) UIImageView *imageView;

@property(nonatomic, strong) UILabel *dateLabel;

@end

@implementation SSJReminderWeekDaySelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        [self addSubview:self.dateLabel];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.size = CGSizeMake(90, 40);
    self.imageView.center = CGPointMake(self.width / 2, self.height / 2);
    self.dateLabel.bottom = self.height;
    self.dateLabel.center = CGPointMake(self.width / 2, self.height / 2) ;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.image = [UIImage imageNamed:@"xingqi"];
    }
    return _imageView;
}

- (UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.textColor = [UIColor whiteColor];
        _dateLabel.font = [UIFont systemFontOfSize:13];
    }
    return _dateLabel;
}

- (void)setCurrentDate:(NSDate *)currentDate{
    _currentDate = currentDate;
    switch (_currentDate.weekday) {
        case 1:
            self.dateLabel.text = @"星期日";
            break;
            
        case 2:
            self.dateLabel.text = @"星期一";
            break;
            
        case 3:
            self.dateLabel.text = @"星期二";
            break;
            
        case 4:
            self.dateLabel.text = @"星期三";
            break;
            
        case 5:
            self.dateLabel.text = @"星期四";
            break;
            
        case 6:
            self.dateLabel.text = @"星期五";
            break;
            
        case 7:
            self.dateLabel.text = @"星期六";
            break;
            
        default:
            break;
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
