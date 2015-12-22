//
//  SJJCalendarCollectionViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/14.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCalendarCollectionViewCell.h"
@interface SSJCalendarCollectionViewCell()
@property(nonatomic,strong)UILabel *dateLabel;
@end
@implementation SSJCalendarCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.dateLabel];
        self.isSelected = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.dateLabel.frame = CGRectMake(0, 0, self.width - 10, 30);
    self.dateLabel.center = CGPointMake(self.width / 2, self.height / 2);
}

-(UILabel*)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _dateLabel;
}

-(void)setCurrentDay:(NSString *)currentDay{
    _currentDay = currentDay;
    self.dateLabel.text = self.currentDay;
}

-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    if (isSelected) {
        self.layer.cornerRadius = self.width / 2;
        self.layer.borderColor = [UIColor ssj_colorWithHex:@"47cfbe"].CGColor;
        self.layer.borderWidth = 1.f;
    }else{
        self.layer.borderWidth = 0;
    }
}
@end
