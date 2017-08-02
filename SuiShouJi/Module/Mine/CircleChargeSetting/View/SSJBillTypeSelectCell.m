
//
//  SSJBillTypeSelectCell.m
//  SuiShouJi
//
//  Created by ricky on 16/6/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBillTypeSelectCell.h"


@interface SSJBillTypeSelectCell()
@property (nonatomic,strong) UILabel *titleLabel;
@property(nonatomic, strong) UIImageView *cellImageView;
@property(nonatomic, strong) UIImageView *checkMarkImageView;
@end

@implementation SSJBillTypeSelectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.cellImageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.checkMarkImageView];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.cellImageView.size = CGSizeMake(20, 20);
    self.cellImageView.left = 15;
    self.cellImageView.centerY = self.contentView.height / 2;
    self.titleLabel.left = self.cellImageView.right + 15;
    self.titleLabel.centerY = self.contentView.height / 2;
    self.checkMarkImageView.size = CGSizeMake(24, 24);
    self.checkMarkImageView.right = self.contentView.width - 10;
    self.checkMarkImageView.centerY = self.contentView.height / 2;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _titleLabel;
}

-(UIImageView *)cellImageView{
    if (!_cellImageView) {
        _cellImageView = [[UIImageView alloc]init];
    }
    return _cellImageView;
}

-(UIImageView *)checkMarkImageView{
    if (!_checkMarkImageView) {
        _checkMarkImageView = [[UIImageView alloc]init];
        _checkMarkImageView.image = [[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _checkMarkImageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    }
    return _checkMarkImageView;
}

-(void)setItem:(SSJRecordMakingBillTypeSelectionCellItem *)item{
    _item = item;
    self.titleLabel.text = _item.title;
    [self.titleLabel sizeToFit];
    self.cellImageView.image = [[UIImage imageNamed:_item.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.cellImageView.tintColor = [UIColor ssj_colorWithHex:_item.colorValue];
}

-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    self.checkMarkImageView.hidden = !_isSelected;
}

-(void)updateCellAppearanceAfterThemeChanged{
    [super updateCellAppearanceAfterThemeChanged];
    self.backgroundColor = [UIColor clearColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
