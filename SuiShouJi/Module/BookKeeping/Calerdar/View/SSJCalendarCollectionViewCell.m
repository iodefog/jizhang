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
        [self addSubview:self.dateLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.dateLabel.frame = CGRectMake(0, 0, self.width - 10, 30);
}

-(UILabel*)dateLabel{
    if (!_dateLabel) {
        _dateLabel.text = self.currentDay;
        _dateLabel.textAlignment = NSTextAlignmentRight;
    }
    return _dateLabel;
}


@end
