//
//  SSJPersonalDetailUserIconCell.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/4.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJPersonalDetailUserIconCell.h"

@interface SSJPersonalDetailUserIconCell ()

@property (nonatomic, strong) UILabel *leftLab;

@property (nonatomic, strong) UIImageView *userIcon;

@end

@implementation SSJPersonalDetailUserIconCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.leftLab];
        [self.contentView addSubview:self.userIcon];
    }
    return self;
}

- (void)updateConstraints {
    [self.leftLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(self.contentView);
    }];
    [self.userIcon mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(66, 66));
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self.contentView);
    }];
    [super updateConstraints];
}

- (UILabel *)leftLab {
    if (!_leftLab) {
        _leftLab = [[UILabel alloc] init];
        _leftLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _leftLab;
}

- (UIImageView *)userIcon {
    if (!_userIcon) {
//        _userIcon = [UIImageView alloc]
    }
    return _userIcon;
}

@end
