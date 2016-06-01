//
//  SSJFundingTransferEdite.m
//  SuiShouJi
//
//  Created by ricky on 16/6/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingTransferEdite.h"

@interface SSJFundingTransferEdite()
@property(nonatomic, strong) UILabel *cellTitleLabel;
@property(nonatomic, strong) UILabel *cellDetailLabel;
@end

@implementation SSJFundingTransferEdite
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.cellTitleLabel];
        [self.contentView addSubview:self.cellDetailLabel];

    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.cellTitleLabel.centerY = self.cellDetailLabel.centerY = self.contentView.height / 2;
    self.cellTitleLabel.left = 10;
    self.cellDetailLabel.right = self.contentView.width - 10;
}

-(UILabel *)cellTitleLabel{
    if (!_cellTitleLabel) {
        _cellTitleLabel = [[UILabel alloc]init];
        _cellTitleLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _cellTitleLabel.font = [UIFont systemFontOfSize:18];
    }
    return _cellTitleLabel;
}

-(UILabel *)cellDetailLabel{
    if (!_cellDetailLabel) {
        _cellDetailLabel = [[UILabel alloc]init];
        _cellDetailLabel.textColor = [UIColor ssj_colorWithHex:@"929292"];
        _cellDetailLabel.font = [UIFont systemFontOfSize:18];
    }
    return _cellDetailLabel;
}

-(void)setCellTitle:(NSString *)cellTitle{
    _cellTitle = cellTitle;
    self.cellTitleLabel.text = _cellTitle;
    [self.cellTitleLabel sizeToFit];
}

-(void)setCellDetail:(NSString *)cellDetail{
    _cellDetail = cellDetail;
    self.cellDetailLabel.text = _cellDetail;
    [self.cellDetailLabel sizeToFit];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
