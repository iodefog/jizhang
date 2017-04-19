//
//  SSJBookKeepingHomeBooksButton.m
//  SuiShouJi
//
//  Created by ricky on 16/9/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomeBooksButton.h"

@interface SSJBookKeepingHomeBooksButton()

@property(nonatomic, strong) UIImageView *booksImage;

@end

@implementation SSJBookKeepingHomeBooksButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.booksImage];
        [self addSubview:self.button];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    self.booksImage.left = 0;
    self.booksImage.centerY = self.height / 2;
    self.button.frame = self.bounds;
    self.booksImage.centerX = self.button.centerX;
}

- (UIButton *)button{
    if (!_button) {
        _button = [[UIButton alloc]init];
    }
    return _button;
}

- (UIImageView *)booksImage{
    if (!_booksImage) {
        _booksImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 21, 21)];
    }
    return _booksImage;
}

- (void)setItem:(SSJBooksTypeItem *)item{
    _item = item;
    self.booksImage.image = [[UIImage imageNamed:_item.booksIcoin] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.booksImage.tintColor = [UIColor ssj_colorWithHex:_item.booksColor];
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
