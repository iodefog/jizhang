//
//  SJJCalendarCollectionViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/14.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCalendarCollectionViewCell.h"
@interface SSJCalendarCollectionViewCell()
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
    if (_isSelected) {
        self.dateLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor ssj_colorWithHex:@"47cfbe"];
        self.layer.cornerRadius = self.height / 2;
    }else{
        self.backgroundColor = [UIColor whiteColor];
        if (self.selectable) {
            self.dateLabel.textColor = [UIColor ssj_colorWithHex:@"#393939"];
        }else{
            self.dateLabel.textColor = [UIColor ssj_colorWithHex:@"#a7a7a7"];
            
        }
    }
}

-(void)setSelectable:(BOOL)selectable{
    _selectable = selectable;
    if (_selectable == YES) {
        self.userInteractionEnabled = YES;
        if (self.isSelected) {
            self.dateLabel.textColor = [UIColor whiteColor];
        }else{
            self.dateLabel.textColor = [UIColor ssj_colorWithHex:@"#393939"];
        }
    }else if (_selectable == NO){
        self.userInteractionEnabled = NO;
        self.dateLabel.textColor = [UIColor ssj_colorWithHex:@"#a7a7a7"];
    }
}

@end
