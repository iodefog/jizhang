
//
//  SSJSharebooksMemberCollectionViewCell.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/15.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJSharebooksMemberCollectionViewCell.h"

@interface SSJSharebooksMemberCollectionViewCell()

@property(nonatomic, strong) UIImageView *iconImageView;

@property(nonatomic, strong) UILabel *nickNameLabel;

@end


@implementation SSJSharebooksMemberCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.iconImageView];
        [self.contentView addSubview:self.nickNameLabel];
        
    }
    return self;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.layer.cornerRadius = self.width / 2;
        _iconImageView.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    }
    return _iconImageView;
}

- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _nickNameLabel.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _nickNameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nickNameLabel;
}

- (void)updateConstraints {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(self.contentView.mas_width);
        make.left.top.mas_equalTo(0);
    }];
    
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconImageView.mas_top).offset(10);
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.width.mas_equalTo(self.contentView.mas_width);
    }];
    
    [super updateConstraints];
}

@end
