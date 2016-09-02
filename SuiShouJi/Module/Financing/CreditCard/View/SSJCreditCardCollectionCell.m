//
//  SSJCreditCardCollectionCell.m
//  SuiShouJi
//
//  Created by ricky on 16/9/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCreditCardCollectionCell.h"
#import "SSJCreditCardStore.h"

@interface SSJCreditCardCollectionCell()

@property(nonatomic, strong) UILabel *cardNameLabel;

@property(nonatomic, strong) UILabel *cardMemoLabel;

@property(nonatomic, strong) UIImageView *cardImage;

@property(nonatomic, strong) UIView *backView;

@property(nonatomic, strong) UIButton *deleteButton;

@end

@implementation SSJCreditCardCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 8.f;
        [self.contentView addSubview:self.deleteButton];
        [self.contentView addSubview:self.cardImage];
        [self.contentView addSubview:self.cardBalanceLabel];
        [self.contentView addSubview:self.cardNameLabel];
        [self.contentView addSubview:self.cardMemoLabel];
    }
    return self;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    self.cardImage.left = 10;
    self.cardImage.centerY = self.contentView.height / 2;
    self.deleteButton.size = CGSizeMake(50, 50);
    self.deleteButton.center = CGPointMake(self.width - 10, 5);
    self.cardNameLabel.bottom = self.contentView.height / 2 - 3;
    self.cardNameLabel.left = self.cardImage.right + 10;
    self.cardMemoLabel.top = self.contentView.height / 2 + 3;
    self.cardMemoLabel.left = self.cardImage.right + 10;
    self.cardBalanceLabel.centerY = self.cardNameLabel.centerY;
    self.cardBalanceLabel.right = self.contentView.width - 10;
}

-(UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc]init];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.layer.borderWidth = 1;
        _backView.layer.cornerRadius = 2;
    }
    return _backView;
}

-(UILabel *)cardNameLabel{
    if (!_cardNameLabel) {
        _cardNameLabel = [[UILabel alloc]init];
        _cardNameLabel.textColor = [UIColor whiteColor];
        _cardNameLabel.font = [UIFont systemFontOfSize:18];
    }
    return _cardNameLabel;
}

-(UILabel *)cardBalanceLabel{
    if (!_cardBalanceLabel) {
        _cardBalanceLabel = [[UILabel alloc]init];
        _cardBalanceLabel.textColor = [UIColor whiteColor];
        _cardBalanceLabel.font = [UIFont systemFontOfSize:22];
    }
    return _cardBalanceLabel;
}

-(UILabel *)cardMemoLabel{
    if (!_cardMemoLabel) {
        _cardMemoLabel = [[UILabel alloc]init];
        _cardMemoLabel.textColor = [UIColor whiteColor];
        _cardMemoLabel.font = [UIFont systemFontOfSize:13];
    }
    return _cardMemoLabel;
}

-(UIButton *)deleteButton{
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc]init];
        [_deleteButton setImage:[UIImage imageNamed:@"ft_delete"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

-(UIImageView *)cardImage{
    if (!_cardImage) {
        _cardImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
        _cardImage.tintColor = [UIColor whiteColor];
    }
    return _cardImage;
}

-(void)setItem:(SSJCreditCardItem *)item{
    _item = item;
    self.backgroundColor = [UIColor ssj_colorWithHex:_item.cardColor];
    self.cardNameLabel.text = _item.cardName;
    [self.cardNameLabel sizeToFit];
    self.cardBalanceLabel.hidden = NO;
    self.cardBalanceLabel.text = [NSString stringWithFormat:@"%.2f",_item.cardBalance];
    [self.cardBalanceLabel sizeToFit];
    self.cardBalanceLabel.hidden = YES;
    self.cardMemoLabel.text = _item.cardMemo;
    [self.cardMemoLabel sizeToFit];
    self.cardImage.image = [[UIImage imageNamed:@"ft_creditcard"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setNeedsLayout];
}

-(void)setEditeModel:(BOOL)editeModel{
    _editeModel = editeModel;
    self.deleteButton.hidden = !_editeModel;
}


-(void)deleteButtonClicked:(id)sender{
    [MobClick event:@"fund_delete"];
//    [SSJCreditCardStore de:self.item];
    if (self.deleteButtonClickBlock) {
        self.deleteButtonClickBlock(self);
    }
}


@end
