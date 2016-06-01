//
//  SSJFundingTransferDetailCell.m
//  SuiShouJi
//
//  Created by ricky on 16/5/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingTransferDetailCell.h"

@interface SSJFundingTransferDetailCell()
@property(nonatomic, strong) UILabel *dateLabel;
@property(nonatomic, strong) UIImageView *fundImage;
@property(nonatomic, strong) UILabel *moneyLabel;
@property(nonatomic, strong) UILabel *transferSourceLabel;
@property(nonatomic, strong) UILabel *memoLabel;
@end
@implementation SSJFundingTransferDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.fundImage];
        [self.contentView addSubview:self.moneyLabel];
        [self.contentView addSubview:self.transferSourceLabel];
        [self.contentView addSubview:self.memoLabel];
    }
    return self;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    if (!self.item.transferMemo.length) {
        self.dateLabel.left = 20;
        self.dateLabel.centerY = self.contentView.height / 2;
        self.fundImage.left = self.dateLabel.right + 10;
        self.fundImage.centerY = self.contentView.height / 2;
        self.moneyLabel.left = self.fundImage.right + 10;
        self.moneyLabel.bottom = self.contentView.height / 2 - 5;
        self.transferSourceLabel.left = self.fundImage.right + 10;
        self.transferSourceLabel.top = self.contentView.height / 2 + 5;
    }else{
        float moneyHeight = [self.moneyLabel.text sizeWithAttributes:@{NSFontAttributeName:self.moneyLabel.font}].height;
        self.dateLabel.left = 20;
        self.dateLabel.centerY = moneyHeight + 27;
        self.fundImage.left = self.dateLabel.right + 10;
        self.fundImage.centerY = moneyHeight + 27;;
        self.moneyLabel.left = self.fundImage.right + 10;
        self.moneyLabel.top = 17;
        self.transferSourceLabel.left = self.fundImage.right + 10;
        self.transferSourceLabel.top = self.moneyLabel.bottom + 10;
        self.memoLabel.left = self.fundImage.right + 10;
        self.memoLabel.top = self.transferSourceLabel.bottom + 10;
    }
}

-(UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _dateLabel.font = [UIFont systemFontOfSize:15];
    }
    return _dateLabel;
}

-(UIImageView *)fundImage{
    if (!_fundImage) {
        _fundImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 22, 22)];
    }
    return _fundImage;
}

-(UILabel *)moneyLabel{
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc]init];
        _moneyLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _moneyLabel.font = [UIFont systemFontOfSize:18];
    }
    return _moneyLabel;
}

-(UILabel *)transferSourceLabel{
    if (!_transferSourceLabel) {
        _transferSourceLabel = [[UILabel alloc]init];
        _transferSourceLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _transferSourceLabel.font = [UIFont systemFontOfSize:15];
    }
    return _transferSourceLabel;
}

-(UILabel *)memoLabel{
    if (!_memoLabel) {
        _memoLabel = [[UILabel alloc]init];
        _memoLabel.textColor = [UIColor ssj_colorWithHex:@"929292"];
        _memoLabel.font = [UIFont systemFontOfSize:15];
    }
    return _memoLabel;
}

-(void)setItem:(SSJFundingTransferDetailItem *)item{
    _item = item;
    self.dateLabel.text = _item.transferDate;
    [self.dateLabel sizeToFit];
    self.moneyLabel.text = _item.transferMoney;
    [self.moneyLabel sizeToFit];
    self.transferSourceLabel.text = [NSString stringWithFormat:@"%@转到%@",_item.transferOutName,_item.transferInName];
    [self.transferSourceLabel sizeToFit];
    self.fundImage.image = [UIImage imageNamed:_item.transferInImage];
    self.memoLabel.text = _item.transferMemo;
    [self.memoLabel sizeToFit];
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
