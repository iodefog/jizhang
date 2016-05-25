//
//  SJJCalendarCollectionViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/14.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCalendarCollectionViewCell.h"
#import "SSJDatabaseQueue.h"
@interface SSJCalendarCollectionViewCell()
@property (nonatomic,strong) UIImageView *starImage;
@end
@implementation SSJCalendarCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.starImage];
        self.isSelected = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.dateLabel.frame = CGRectMake(0, 0, self.width - 10, 30);
    self.dateLabel.center = CGPointMake(self.width / 2, self.height / 2);
    self.starImage.size = CGSizeMake(8, 8);
    self.starImage.bottom = self.dateLabel.bottom;
    self.starImage.centerX = self.width / 2;
}

-(UILabel*)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _dateLabel;
}


-(UIImageView *)starImage{
    if (!_starImage) {
        _starImage = [[UIImageView alloc]init];
        _starImage.image = [[UIImage imageNamed:@"calender_star"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return _starImage;
}


-(void)setItem:(SSJCalenderCellItem *)item{
    _item = item;
    self.backgroundColor = [UIColor ssj_colorWithHex:_item.backGroundColor];
    self.dateLabel.textColor = [UIColor ssj_colorWithHex:_item.titleColor];
    if (_item.isSelectable) {
        self.userInteractionEnabled = YES;
    }else{
        self.userInteractionEnabled = NO;
    }
    if (self.item.dateStr.length != 10) {
        self.dateLabel.text = self.item.dateStr;
    }else{
        self.dateLabel.text = [NSString stringWithFormat:@"%d",[[[self.item.dateStr componentsSeparatedByString:@"-"] lastObject] intValue]];
    }
    if ([_item.backGroundColor isEqualToString:@"eb4a64"]) {
        self.starImage.tintColor = [UIColor whiteColor];
    }else{
        self.starImage.tintColor = [UIColor ssj_colorWithHex:@"ffa81c"];
    }
    if (_item.haveDataOrNot) {
        self.starImage.hidden = NO;
    }else{
        self.starImage.hidden = YES;
    }
    if ([_item.backGroundColor isEqualToString:@"eb4a64"] || [_item.backGroundColor isEqualToString:@"cccccc"]) {
        self.layer.cornerRadius = self.height / 2;
    }
}

-(void)setIsSelectOnly:(BOOL)isSelectOnly{
    if (isSelectOnly) {
        self.starImage.hidden = YES;
    }else{
        if (_item.haveDataOrNot) {
            self.starImage.hidden = NO;
        }else{
            self.starImage.hidden = YES;
        }
    }
}


@end
