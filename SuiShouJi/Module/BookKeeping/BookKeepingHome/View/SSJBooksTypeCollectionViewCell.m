//
//  SSJBooksTypeCollectionViewCell.m
//  SuiShouJi
//
//  Created by ricky on 16/5/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBooksTypeCollectionViewCell.h"
#import <YYText/YYText.h>

@interface SSJBooksTypeCollectionViewCell()
@property(nonatomic, strong) YYLabel *titleLabel;
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
    self.titleLabel.centerX = self.width - (self.width - 24) / 2;
    self.titleLabel.centerY = self.height / 2;
}

-(YYLabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[YYLabel alloc]init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.verticalForm = YES;
        _titleLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
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
    }
    return _lineImage;
}

-(UIImageView *)selectImage{
    if (!_selectImage) {
        _selectImage = [[UIImageView alloc]init];
    }
    return _lineImage;
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

@end
