//
//  SSJBooksTypeCollectionViewCell.m
//  SuiShouJi
//
//  Created by ricky on 16/5/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBooksTypeCollectionViewCell.h"

@interface SSJBooksTypeCollectionViewCell()

@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) UIView *seperatorLineView;

@property(nonatomic, strong) UIImageView *lineImage;

@property(nonatomic, strong) UIImageView *selectImageView;

@property(nonatomic, strong) UIImageView *booksIcionImageView;

@property(nonatomic, strong) UIButton *selectedButton;

@end

@implementation SSJBooksTypeCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.booksIcionImageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.seperatorLineView];
        [self.contentView addSubview:self.lineImage];
        [self.contentView addSubview:self.selectImageView];
        [self.contentView addSubview:self.selectedButton];
        self.clipsToBounds = NO;
        self.layer.cornerRadius = 4.f;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.seperatorLineView.size = CGSizeMake(2, self.height);
    self.seperatorLineView.leftTop = CGPointMake(22, 0);
    if (self.titleLabel.text.length >= 4) {
        self.titleLabel.height = [[self.titleLabel.text substringWithRange:NSMakeRange(0, 1)] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]}].height * 4;
    }else{
        self.titleLabel.height = [[self.titleLabel.text substringWithRange:NSMakeRange(0, 1)] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]}].height * self.titleLabel.text.length;
    }
    self.titleLabel.width = [[self.titleLabel.text substringWithRange:NSMakeRange(0, 1)] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]}].width;
    self.titleLabel.centerX = self.width - (self.width - 24) / 2;
    self.titleLabel.centerY = self.height / 2;
    self.lineImage.size = CGSizeMake(7, 56);
    self.lineImage.center = CGPointMake(12, self.height / 2);
    self.selectImageView.rightBottom = CGPointMake(self.width, self.height - 10);
    self.booksIcionImageView.rightBottom = CGPointMake(self.width , self.height);
    if (self.item.booksId.length) {
        self.booksIcionImageView.transform = CGAffineTransformMakeRotation( - M_PI_4);
        self.booksIcionImageView.transform = CGAffineTransformTranslate(self.booksIcionImageView.transform, 0, -8);
    }
    if (self.item.booksId.length) {
        self.selectedButton.center = CGPointMake(self.contentView.width , 0);
    }else{
        self.selectedButton.hidden = YES;
    }
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

-(UIView *)seperatorLineView{
    if (!_seperatorLineView) {
        _seperatorLineView = [[UIView alloc]init];
        _seperatorLineView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.12];
    }
    return _seperatorLineView;
}

-(UIImageView *)lineImage{
    if (!_lineImage) {
        _lineImage = [[UIImageView alloc]init];
        _lineImage.image = [UIImage imageNamed:@"zhangben_bian"];
    }
    return _lineImage;
}

-(UIImageView *)selectImageView{
    if (!_selectImageView) {
        _selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 18, 9)];
        _selectImageView.image = [UIImage imageNamed:@"zhangben_mark"];
    }
    return _selectImageView;
}

-(UIImageView *)booksIcionImageView{
    if (!_booksIcionImageView) {
        _booksIcionImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 22, 22)];
        _booksIcionImageView.tintColor = [UIColor ssj_colorWithHex:@"#000000" alpha:0.15];
    }
    return _booksIcionImageView;
}

- (UIButton *)selectedButton{
    if (!_selectedButton) {
        _selectedButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_selectedButton setImage:[UIImage imageNamed:@"book_xuanzhong"] forState:UIControlStateNormal];
        [_selectedButton setImage:[UIImage imageNamed:@"book_sel"] forState:UIControlStateSelected];
    }
    return _selectedButton;
}

-(void)setItem:(SSJBooksTypeItem *)item{
    _item = item;
    self.backgroundColor = [UIColor ssj_colorWithHex:_item.booksColor];
    self.titleLabel.text = _item.booksName;
    [self.titleLabel sizeToFit];
    self.booksIcionImageView.image = [[UIImage imageNamed:_item.booksIcoin] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setNeedsLayout];
}

- (void)setSelectToEdite:(BOOL)selectToEdite{
    _selectToEdite = selectToEdite;
    self.selectedButton.selected = _selectToEdite;
}

-(void)setEditeModel:(BOOL)editeModel{
    _editeModel = editeModel;
    self.selectedButton.hidden = !_editeModel;
}

-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    self.selectImageView.hidden = !_isSelected;
}

@end
