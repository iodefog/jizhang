//
//  SSJCreditCardEditeCell.m
//  SuiShouJi
//
//  Created by ricky on 16/8/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCreditCardEditeCell.h"

@interface SSJCreditCardEditeCell()

@property(nonatomic, strong) UIImageView *cellImage;

@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic,strong) UIImageView *cellDetailImage;

@end

@implementation SSJCreditCardEditeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.cellImage];
        [self.contentView addSubview:self.textInput];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailLabel];
        [self.contentView addSubview:self.cellDetailImage];
        [self.contentView addSubview:self.subTitleLabel];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    switch (self.type) {
        case SSJCreditCardCellTypeTextField:{
            self.cellImage.left = 10;
            self.cellImage.centerY = self.contentView.height / 2;
            self.accessoryView.centerY = self.cellImage.centerY;
            self.textInput.size = CGSizeMake(self.contentView.width - self.cellImage.right - 10, self.contentView.height);
            self.textInput.left = self.cellImage.right + 10;
            self.textInput.centerY = self.contentView.height / 2;
            self.textInput.hidden = NO;
            self.titleLabel.hidden = YES;
            self.detailLabel.hidden = YES;
            self.cellDetailImage.hidden = YES;
            self.subTitleLabel.hidden = YES;
        }
            break;
            
        case SSJCreditCardCellTypeDetail:{
            self.cellImage.left = 10;
            self.cellImage.centerY = self.contentView.height / 2;
            self.accessoryView.centerY = self.cellImage.centerY;
            self.titleLabel.left = self.cellImage.right + 10;
            self.titleLabel.centerY = self.contentView.height / 2;
            if (self.contentView.width == self.width) {
                self.detailLabel.right = self.contentView.width - 10;
            }else{
                self.detailLabel.right = self.contentView.width;
            }
            self.detailLabel.centerY = self.contentView.height /  2;
            self.detailLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
            self.cellDetailImage.right = self.detailLabel.left - 10;
            self.cellDetailImage.centerY = self.contentView.height /  2;

            self.cellDetailImage.hidden = NO;
            self.textInput.hidden = YES;
            self.subTitleLabel.hidden = YES;
        }
            break;
            
        case SSJCreditCardCellTypeassertedDetail:{
            self.cellImage.left = 10;
            self.cellImage.centerY = self.contentView.height / 2;
            self.accessoryView.centerY = self.cellImage.centerY;
            self.titleLabel.left = self.cellImage.right + 10;
            self.titleLabel.centerY = self.contentView.height / 2;
            if (self.contentView.width == self.width) {
                self.detailLabel.right = self.contentView.width - 10;
            }else{
                self.detailLabel.right = self.contentView.width;
            }
            self.detailLabel.centerY = self.contentView.height /  2;
            self.detailLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
            self.cellDetailImage.right = self.detailLabel.left - 10;
            self.cellDetailImage.centerY = self.contentView.height /  2;
            self.cellDetailImage.hidden = NO;
            self.textInput.hidden = YES;
            self.subTitleLabel.hidden = YES;
        }
            break;
            
        case SSJCreditCardCellTypeSubTitle:{
            self.cellImage.left = 10;
            self.cellImage.top = 20;
            self.accessoryView.centerY = self.cellImage.centerY;
            self.titleLabel.left = self.cellImage.right + 10;
            self.titleLabel.left = 20;
            self.subTitleLabel.bottom = self.height - 10;
        }
            break;
            
        default:
            break;
    }
}

- (UIImageView *)cellImage{
    if (!_cellImage) {
        _cellImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    }
    return _cellImage;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel{
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _detailLabel.font = [UIFont systemFontOfSize:15];
    }
    return _detailLabel;
}

- (UILabel *)subTitleLabel{
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _subTitleLabel.font = [UIFont systemFontOfSize:14];
        _subTitleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _subTitleLabel;
}

- (UIImageView *)cellDetailImage{
    if (!_cellDetailImage) {
        _cellDetailImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    }
    return _cellDetailImage;
}

- (UITextField *)textInput{
    if (!_textInput) {
        _textInput = [[UITextField alloc]init];
        _textInput.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _textInput;
}

- (void)setCellImageName:(NSString *)cellImageName{
    _cellImageName = cellImageName;
    self.cellImage.image = [UIImage imageNamed:_cellImageName];
}

- (void)setCellDetailImageName:(NSString *)cellDetailImageName{
    _cellDetailImageName = cellDetailImageName;
    self.cellDetailImage.image = [UIImage imageNamed:_cellDetailImageName];
    [self.cellDetailImage sizeToFit];
}

- (void)setCellTitle:(NSString *)cellTitle{
    _cellTitle = cellTitle;
    self.titleLabel.text = _cellTitle;
    [self.titleLabel sizeToFit];
}

- (void)setCellSubTitle:(NSString *)cellSubTitle{
    _cellSubTitle = cellSubTitle;
    self.subTitleLabel.text = _cellSubTitle;
    [self.subTitleLabel sizeToFit];
}

- (void)setType:(SSJCreditCardCellType)type{
    _type = type;
    [self setNeedsLayout];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
