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
@property(nonatomic, strong) UIImageView *selectImage;
@end

@implementation SSJBooksTypeCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
        longPressGr.minimumPressDuration = 0.5f;
        [self addGestureRecognizer:longPressGr];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.seperatorLineView];
        [self.contentView addSubview:self.lineImage];
        [self.contentView addSubview:self.selectImage];
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
    self.selectImage.rightBottom = CGPointMake(self.width, self.height - 10);
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

-(UIImageView *)selectImage{
    if (!_selectImage) {
        _selectImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 18, 9)];
        _selectImage.image = [UIImage imageNamed:@"zhangben_mark"];
    }
    return _selectImage;
}

-(void)setItem:(SSJBooksTypeItem *)item{
    _item = item;
    self.backgroundColor = [UIColor ssj_colorWithHex:_item.booksColor];
    self.titleLabel.text = _item.booksName;
    [self.titleLabel sizeToFit];
    [self setNeedsLayout];
}

-(void)longPressToDo:(id)sender{
    if (self.longPressBlock) {
        self.longPressBlock();
    }
}

-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    self.selectImage.hidden = !_isSelected;
}

@end
