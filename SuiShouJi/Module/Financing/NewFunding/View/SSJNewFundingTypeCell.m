
//
//  SSJNewFundingTypeCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNewFundingTypeCell.h"

@interface SSJNewFundingTypeCell()

@end

@implementation SSJNewFundingTypeCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.cellText];
        [self.contentView addSubview:self.typeLabel];
        [self.contentView addSubview:self.colorView];
        [self.contentView addSubview:self.typeImage];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.cellText.frame = CGRectMake(20, 0, self.contentView.width - 20, self.contentView.height);
    self.typeLabel.right = self.contentView.width - 10;
    self.typeLabel.centerY = self.contentView.height / 2;
    self.colorView.size = CGSizeMake(30, 30);
    self.colorView.layer.cornerRadius = 15;
    self.colorView.right = self.contentView.width - 10;
    self.colorView.centerY = self.contentView.height / 2;
    self.typeImage.size = CGSizeMake(18, 18);
    self.typeImage.right = self.typeLabel.left - 10;
    self.typeImage.centerY = self.height / 2;
}

-(UITextField *)cellText{
    if (!_cellText) {
        _cellText = [[UITextField alloc]init];
        _cellText.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _cellText.font = [UIFont systemFontOfSize:18];
        _cellText.textAlignment = NSTextAlignmentLeft;
    }
    return _cellText;
}

-(UILabel *)typeLabel{
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc]init];
        _typeLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _typeLabel.font = [UIFont systemFontOfSize:18];
    }
    return _typeLabel;
}

-(UIView *)colorView{
    if (!_colorView) {
        _colorView = [[UIView alloc]init];
    }
    return _colorView;
}

-(UIImageView *)typeImage{
    if (!_typeImage) {
        _typeImage = [[UIImageView alloc]init];
    }
    return _typeImage;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
