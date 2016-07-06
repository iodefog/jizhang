//
//  SSJCalenderDetailCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/20.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCalenderDetailCell.h"

@interface SSJCalenderDetailCell()

@end

@implementation SSJCalenderDetailCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.cellLabel];
        [self.contentView addSubview:self.detailLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.cellLabel.left = 10;
    self.cellLabel.centerY = self.contentView .height / 2;
    self.detailLabel.width = self.contentView .width / 2 - 10;
    self.detailLabel.right = self.contentView .width - 10;
    self.detailLabel.centerY = self.contentView .height / 2;
}

-(UILabel *)cellLabel{
    if (_cellLabel == nil) {
        _cellLabel = [[UILabel alloc]init];
        _cellLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _cellLabel.textAlignment = NSTextAlignmentLeft;
        _cellLabel.font = [UIFont systemFontOfSize:15];
    }
    return _cellLabel;
}

-(UILabel *)detailLabel{
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc]init];
        _detailLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.font = [UIFont systemFontOfSize:18];
    }
    return _detailLabel ;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
