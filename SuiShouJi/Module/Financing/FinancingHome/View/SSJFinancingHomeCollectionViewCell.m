//
//  SSJFinancingHomeCollectionViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFinancingHomeCollectionViewCell.h"

@interface SSJFinancingHomeCollectionViewCell()
//@property(nonatomic, strong) UIView *fundingColorView;
@property(nonatomic, strong) UILabel *fundingNameLabel;
@property(nonatomic, strong) UIImageView *fundingIcon;
@property (nonatomic,strong) UILabel *fundingBalanceLabel;
@end

@implementation SSJFinancingHomeCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 2;
        self.layer.masksToBounds = YES;
    }
    return self;
}

-(void)layoutSubviews{
    self.fundingIcon.size = CGSizeMake(36, self.height);
    self.fundingIcon.leftTop = CGPointMake(0, 0);
    self.fundingNameLabel.centerY = self.height / 2;
    self.fundingNameLabel.left = self.fundingIcon.right + 10;
    self.fundingBalanceLabel.centerY = self.height / 2;
    self.fundingBalanceLabel.right = self.width - 10;
}

//-(UIView *)fundingColorView{
//    if (_fundingColorView == nil) {
//        _fundingColorView = [[UIView alloc]init];
//    }
//    return _fundingColorView;
//}

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
        _fundingBalanceLabel.font = [UIFont systemFontOfSize:15];
    }
    return _fundingBalanceLabel;
}

-(void)setItem:(SSJFinancingHomeitem *)item{
    _item = item;
    self.layer.borderColor = [UIColor ssj_colorWithHex:_item.fundingColor].CGColor;
    self.fundingIcon.backgroundColor = [UIColor ssj_colorWithHex:_item.fundingColor];
    self.fundingIcon.image = [UIImage imageNamed:_item.fundingIcon];
    self.fundingNameLabel.text = _item.fundingName;
    [self.fundingNameLabel sizeToFit];
    self.fundingBalanceLabel.text = [NSString stringWithFormat:@"%.2f",_item.fundingAmount];
    [self.fundingBalanceLabel sizeToFit];
}
@end
