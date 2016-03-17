//
//  SSJFinancingHomeCollectionViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFinancingHomeCollectionViewCell.h"

@interface SSJFinancingHomeCollectionViewCell()
@property(nonatomic, strong) UIView *fundingColorView;
@property(nonatomic, strong) UILabel *fundingNameLabel;
@property(nonatomic, strong) UILabel *fundingMemoLabel;
@property(nonatomic, strong) UIImageView *fundingIcon;
@end

@implementation SSJFinancingHomeCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 2;
        self.layer.masksToBounds = YES;
        [self addSubview:self.fundingBalanceLabel];
        [self addSubview:self.fundingNameLabel];
        [self addSubview:self.fundingColorView];
        [self addSubview:self.fundingMemoLabel];
        [self.fundingColorView addSubview:self.fundingIcon];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.fundingColorView.size = CGSizeMake(36, self.height);
    self.fundingColorView.leftTop = CGPointMake(0, 0);
    self.fundingIcon.size = CGSizeMake(25, 25);
    self.fundingIcon.center = CGPointMake(self.fundingColorView.width / 2, self.fundingColorView.height / 2);
    if ([_item.fundingMemo isEqualToString:@""]||_item.fundingMemo == nil) {
        self.fundingNameLabel.left = self.fundingColorView.right + 10;
        self.fundingNameLabel.centerY = self.height / 2;
    }else{
        self.fundingNameLabel.leftTop = CGPointMake(self.fundingColorView.right + 10, 10) ;
        self.fundingMemoLabel.leftTop = CGPointMake(self.fundingColorView.right + 10, self.fundingNameLabel.bottom + 7);
    }
    self.fundingBalanceLabel.centerY = self.height / 2;
    self.fundingBalanceLabel.right = self.width - 10;
}

-(UIView *)fundingColorView{
    if (_fundingColorView == nil) {
        _fundingColorView = [[UIView alloc]init];
    }
    return _fundingColorView;
}

-(UIImageView *)fundingIcon{
    if (!_fundingIcon) {
        _fundingIcon = [[UIImageView alloc]init];
    }
    return _fundingIcon;
}

-(UILabel *)fundingNameLabel{
    if (!_fundingNameLabel) {
        _fundingNameLabel = [[UILabel alloc]init];
        _fundingNameLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _fundingNameLabel.font = [UIFont systemFontOfSize:14];
    }
    return _fundingNameLabel;
}

-(UILabel *)fundingBalanceLabel{
    if (!_fundingBalanceLabel) {
        _fundingBalanceLabel = [[UILabel alloc]init];
        _fundingBalanceLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _fundingBalanceLabel.font = [UIFont systemFontOfSize:18];
    }
    return _fundingBalanceLabel;
}

-(UILabel *)fundingMemoLabel{
    if (!_fundingMemoLabel) {
        _fundingMemoLabel = [[UILabel alloc]init];
        _fundingMemoLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        _fundingMemoLabel.font = [UIFont systemFontOfSize:13];
    }
    return _fundingMemoLabel;
}

-(void)setItem:(SSJFinancingHomeitem *)item{
    _item = item;
    self.layer.borderColor = [UIColor ssj_colorWithHex:_item.fundingColor].CGColor;
    self.fundingColorView.backgroundColor = [UIColor ssj_colorWithHex:self.item.fundingColor];
    self.fundingIcon.tintColor  = [UIColor whiteColor];
    self.fundingIcon.image = [[UIImage imageNamed:self.item.fundingIcon]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.fundingNameLabel.text = _item.fundingName;
    [self.fundingNameLabel sizeToFit];
    if (item.isAddOrNot == NO) {
        self.fundingBalanceLabel.hidden = NO;
        self.fundingBalanceLabel.text = [NSString stringWithFormat:@"%.2f",_item.fundingAmount];
        [self.fundingBalanceLabel sizeToFit];
    }else{
        self.fundingBalanceLabel.hidden = YES;
    }
    self.fundingMemoLabel.text = _item.fundingMemo;
    [self.fundingMemoLabel sizeToFit];
    [self setNeedsLayout];
}

@end
