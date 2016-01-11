//
//  SSJFundingTypeTableViewCell.m
//  SuiShouJi
//
//  Created by ricky on 15/12/23.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJFundingTypeTableViewCell.h"
@interface SSJFundingTypeTableViewCell()
@property (nonatomic,strong) UIImageView *fundingImage;
@property (nonatomic,strong) UIImageView *checkMark;
@property (nonatomic,strong) UILabel *fundingTitle;

@end
@implementation SSJFundingTypeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.fundingImage];
        [self.contentView addSubview:self.fundingTitle];
        [self addSubview:self.checkMark];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.fundingImage.centerY = self.height / 2;
    self.fundingImage.left = 10;
    self.fundingTitle.centerY = self.fundingImage.centerY;
    self.fundingTitle.left = self.fundingImage.right + 10;
    self.checkMark.centerY = self.fundingImage.centerY;
    self.checkMark.right = self.width - 10;
}

-(UIImageView *)fundingImage{
    if (!_fundingImage) {
        _fundingImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    }
    return _fundingImage;
}

-(UILabel *)fundingTitle{
    if (!_fundingTitle) {
        _fundingTitle = [[UILabel alloc]initWithFrame:CGRectZero];
        _fundingTitle.font = [UIFont systemFontOfSize:18];
        _fundingTitle.textColor = [UIColor ssj_colorWithHex:@"393939"];
    }
    return _fundingTitle;
}

-(UIImageView *)checkMark{
    if (!_checkMark) {
        _checkMark = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        _checkMark.image = [UIImage imageNamed:@"checkmark"];
        _checkMark.hidden = YES;
    }
    return _checkMark;
}

-(void)setSelectedOrNot:(BOOL)selectedOrNot{
    _selectedOrNot = selectedOrNot;
    if (_selectedOrNot) {
        self.checkMark.hidden = NO;
    }else{
        self.checkMark.hidden = YES;
    }
}

-(void)setItem:(SSJFundingItem *)item{
    _item = item;
    _fundingTitle.text = self.item.fundingName;
    [_fundingTitle sizeToFit];
    _fundingImage.image = [UIImage imageNamed:self.item.fundingIcon];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
