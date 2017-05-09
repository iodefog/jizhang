//
//  SSJBooksParentButton.m
//  SuiShouJi
//
//  Created by ricky on 16/11/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBooksParentSelectCell.h"

@interface SSJBooksParentSelectCell()

@property(nonatomic, strong) UIImageView *booksIconImageView;

@property(nonatomic, strong) UILabel *booksTitleLab;

@property(nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation SSJBooksParentSelectCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = self.height / 2;
        self.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor].CGColor;
        self.layer.borderWidth = 1.f;
        [self.contentView addSubview:self.booksTitleLab];
        [self.contentView addSubview:self.booksIconImageView];
        [self.contentView addSubview:self.arrowImageView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.booksTitleLab.centerX = self.width / 2;
    self.booksTitleLab.centerY = self.booksIconImageView.centerY = self.arrowImageView.centerY = self.height / 2;
    self.booksIconImageView.right = self.booksTitleLab.left - 15;
    self.arrowImageView.right = self.width - 20;
}

- (UIImageView *)booksIconImageView{
    if (!_booksIconImageView) {
        _booksIconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
        _booksIconImageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _booksIconImageView;
}

- (UILabel *)booksTitleLab{
    if (!_booksTitleLab) {
        _booksTitleLab = [[UILabel alloc]init];
        _booksTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _booksTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _booksTitleLab;
}

- (UIImageView *)arrowImageView{
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc]init];
        _arrowImageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _arrowImageView.image = [[UIImage imageNamed:@"budget_right"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_arrowImageView sizeToFit];
    }
    return _arrowImageView;
}

- (void)setTitle:(NSString *)title{
    self.booksTitleLab.text = title;
    [self.booksTitleLab sizeToFit];
}

- (void)setImage:(NSString *)image{
    self.booksIconImageView.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)setIsSelected:(BOOL)isSelected{
    if (isSelected) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        self.booksTitleLab.textColor = [UIColor whiteColor];
        self.booksIconImageView.tintColor = [UIColor whiteColor];
        self.arrowImageView.tintColor = [UIColor whiteColor];
    }else{
        self.backgroundColor = [UIColor clearColor];
        self.booksTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        self.booksIconImageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        self.arrowImageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
