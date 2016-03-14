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
        self.layer.cornerRadius = self.height / 2;
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

-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    if (_isSelected) {
        if (_currentDay) {
            self.dateLabel.textColor = [UIColor whiteColor];
            self.backgroundColor = [UIColor ssj_colorWithHex:@"47cfbe"];
            self.layer.cornerRadius = self.height / 2;
        }else{
            self.dateLabel.textColor = [UIColor whiteColor];
            self.backgroundColor = [UIColor ssj_colorWithHex:@"e7e7e7"];
            self.layer.cornerRadius = self.height / 2;
        }

    }else{
        if (self.iscurrentDay) {
            self.dateLabel.textColor = [UIColor whiteColor];
            self.backgroundColor = [UIColor ssj_colorWithHex:@"e7e7e7"];
        }else{
            self.backgroundColor = [UIColor whiteColor];
        }
        if (self.selectable) {
            self.dateLabel.textColor = [UIColor ssj_colorWithHex:@"#393939"];
        }else{
            self.dateLabel.textColor = [UIColor ssj_colorWithHex:@"#a7a7a7"];
            
        }
    }
}

-(void)setIscurrentDay:(BOOL)iscurrentDay{
    _iscurrentDay = iscurrentDay;
    if (_iscurrentDay) {
        self.dateLabel.textColor = [UIColor ssj_colorWithHex:@"47cfbe"];
    }else{
        self.backgroundColor = [UIColor whiteColor];
    }
}

-(void)setSelectable:(BOOL)selectable{
    _selectable = selectable;
    if (_selectable == YES) {
        self.userInteractionEnabled = YES;
        self.dateLabel.textColor = [UIColor whiteColor];
    }else if (_selectable == NO){
        self.userInteractionEnabled = NO;
        self.dateLabel.textColor = [UIColor ssj_colorWithHex:@"#a7a7a7"];
    }
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
    if ([_item.backGroundColor isEqualToString:@"cccccc"] || [_item.backGroundColor isEqualToString:@"47cfbe"]) {
        self.starImage.tintColor = [UIColor whiteColor];
    }else{
        self.starImage.tintColor = [UIColor orangeColor];
    }
}

-(void)getHaveRecordOrNot{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        BOOL haveRecordOrNot = [db intForQuery:@"select * from BK_USER_CHARGE where CBILLDATE = ? and CUSERID = ? and OPERATORTYPE <> 2",weakSelf.item.dateStr,SSJUSERID()];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (haveRecordOrNot) {
                weakSelf.starImage.hidden = YES;
            }else{
                weakSelf.starImage.hidden = NO;
            }
        });
    }];
}


@end
