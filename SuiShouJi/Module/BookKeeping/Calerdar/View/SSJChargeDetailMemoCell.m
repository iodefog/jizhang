
//
//  SSJChargeDetailMemoCell.m
//  SuiShouJi
//
//  Created by ricky on 16/4/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJChargeDetailMemoCell.h"

@interface SSJChargeDetailMemoCell()
@property(nonatomic, strong) UILabel *memoLabel;
@property(nonatomic, strong) UILabel *cellTitleLabel;
@end
@implementation SSJChargeDetailMemoCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.cellTitleLabel];
        [self.contentView addSubview:self.memoLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.cellTitleLabel.leftTop = CGPointMake(10, 15);
    self.memoLabel.width = self.contentView .width / 2 - 10;
    self.memoLabel.right = self.contentView .width - 10;
    self.memoLabel.top = self.cellTitleLabel.top;
}

-(UILabel *)cellTitleLabel{
    if (!_cellTitleLabel) {
        _cellTitleLabel = [[UILabel alloc]init];
        _cellTitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _cellTitleLabel.textAlignment = NSTextAlignmentLeft;
        _cellTitleLabel.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
    }
    return _cellTitleLabel;
}

-(UILabel *)memoLabel{
    if (!_memoLabel) {
        _memoLabel = [[UILabel alloc]init];
        _memoLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _memoLabel.textAlignment = NSTextAlignmentRight;
        _memoLabel.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_2);
        _memoLabel.numberOfLines = 2;
    }
    return _memoLabel;
}

-(void)setCellMemo:(NSString *)cellMemo{
    _cellMemo = cellMemo;
    self.memoLabel.text = _cellMemo;
    [self.memoLabel sizeToFit];
}

-(void)setCellTitle:(NSString *)cellTitle{
    _cellTitle = cellTitle;
    self.cellTitleLabel.text = _cellTitle;
    [self.cellTitleLabel sizeToFit];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
