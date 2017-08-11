//
//  SSJCalenderView.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSmallCalendarView.h"
@interface SSJSmallCalendarView()
@property (nonatomic,strong) UIImageView *calenderImage;
@property (nonatomic,strong) UILabel *dateLabel;
@end

@implementation SSJSmallCalendarView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        [self addSubview:self.calenderImage];
        [self addSubview:self.dateLabel];
    }
    return self;
}

-(void)layoutSubviews{
    _calenderImage.frame = CGRectMake(0, 0, self.width, self.height);
    _dateLabel.bottom = self.height;
    _dateLabel.center = CGPointMake(self.width / 2, self.height / 2);
}

-(UIImageView *)calenderImage{
    if (_calenderImage == nil) {
        _calenderImage = [[UIImageView alloc]init];
        _calenderImage.image = [UIImage imageNamed:@"calender"];
    }
    return _calenderImage;
}

-(UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.textColor = [UIColor ssj_colorWithHex:@"EE4F4F"];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
    }
    return _dateLabel;
}

-(void)setCurrentDay:(NSString *)currentDay{
    _currentDay = currentDay;
    self.dateLabel.text = _currentDay;
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
