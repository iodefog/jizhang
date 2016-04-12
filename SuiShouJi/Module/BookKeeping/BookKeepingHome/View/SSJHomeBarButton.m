//
//  SSJHomeBarButton.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJHomeBarButton.h"

@interface SSJHomeBarButton()
@property (nonatomic,strong) UIImageView *calenderImage;
@property (nonatomic,strong) UILabel *dateLabel;
@end

@implementation SSJHomeBarButton
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.calenderImage];
        [self addSubview:self.dateLabel];
        self.btn = [[UIButton alloc]init];
        [self addSubview:self.btn];
    }
    return self;
}

-(void)layoutSubviews{
    if (SSJSCREENWITH == 414 && SSJSCREENHEIGHT == 736) {
        _calenderImage.frame = CGRectMake(0, 0, 29, 29);
    }else{
        _calenderImage.frame = CGRectMake(0, 0, 22, 22);
    }
    _calenderImage.center = CGPointMake(self.width / 2, self.height / 2);
    _dateLabel.bottom = self.height;
    _dateLabel.center = CGPointMake(self.width / 2, self.height / 2);
    _btn.frame = CGRectMake(0, 0, self.width, self.height);
}

-(UIImageView *)calenderImage{
    if (_calenderImage == nil) {
        _calenderImage = [[UIImageView alloc]init];
        _calenderImage.image = [UIImage imageNamed:@"home_calender"];
        [_calenderImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return _calenderImage;
}

-(UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.textColor = [UIColor whiteColor];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        if (SSJSCREENWITH == 414 && SSJSCREENHEIGHT == 736) {
            _dateLabel.font = [UIFont systemFontOfSize:18];
        }else{
            _dateLabel.font = [UIFont systemFontOfSize:14];
        }
    }
    return _dateLabel;
}

-(void)setCurrentDay:(long)currentDay{
    _currentDay = currentDay;
    self.dateLabel.text = [NSString stringWithFormat:@"%02ld",_currentDay];
    [self.dateLabel sizeToFit];
}
@end
