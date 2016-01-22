//
//  SSJNewFundingTableViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJModifyFundingTableViewCell.h"

@interface SSJModifyFundingTableViewCell()
@end

@implementation SSJModifyFundingTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.cellTitle];
        [self.contentView addSubview:self.cellDetail];
        [self.contentView addSubview:self.colorView];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.cellTitle.left = 10;
    self.cellTitle.centerY = self.height / 2;
    self.cellDetail.size = self.contentView.size;
    self.cellDetail.right = self.contentView.width - 10;
    self.cellDetail.centerY = self.height / 2;
    self.colorView.size = CGSizeMake(30, 30);
    self.colorView.right = self.contentView.width - 10;
    self.colorView.centerY = self.height / 2;
}

-(UILabel *)cellTitle{
    if (!_cellTitle) {
        _cellTitle = [[UILabel alloc]init];
        _cellTitle.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _cellTitle.font = [UIFont systemFontOfSize:18];
    }
    return _cellTitle;
}

-(UITextField *)cellDetail{
    if (!_cellDetail) {
        _cellDetail = [[UITextField alloc]init];
        _cellDetail.textAlignment = NSTextAlignmentRight;
        _cellDetail.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _cellDetail.font = [UIFont systemFontOfSize:15];
    }
    return _cellDetail;
}

-(UIView *)colorView{
    if (!_colorView) {
        _colorView = [[UIView alloc]init];
    }
    return _colorView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
