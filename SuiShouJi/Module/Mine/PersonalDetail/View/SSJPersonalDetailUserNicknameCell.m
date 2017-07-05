//
//  SSJPersonalDetailUserNicknameCell.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/4.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJPersonalDetailUserNicknameCell.h"

@implementation SSJPersonalDetailUserNicknameCellItem

+ (instancetype)itemWithNickname:(NSString *)nickname {
    SSJPersonalDetailUserNicknameCellItem *item = [[SSJPersonalDetailUserNicknameCellItem alloc] init];
    item.nickname = nickname;
    return item;
}

@end

@interface SSJPersonalDetailUserNicknameCell ()

@property (nonatomic, strong) UILabel *leftLab;

@property (nonatomic, strong) UITextField *nicknameField;

@end

@implementation SSJPersonalDetailUserNicknameCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.leftLab];
        [self.contentView addSubview:self.nicknameField];
        [self setNeedsUpdateConstraints];
        [self updateAppearance];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)updateConstraints {
    [self.leftLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(self.contentView);
    }];
    [self.nicknameField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(self.leftLab.mas_right).offset(20);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(self.contentView);
    }];
    [super updateConstraints];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJPersonalDetailUserNicknameCellItem class]]) {
        return;
    }
    
    SSJPersonalDetailUserNicknameCellItem *item = cellItem;
    self.nicknameField.text = item.nickname;
    RACChannelTo(item, nickname) = self.nicknameField.rac_newTextChannel;
}

- (void)updateAppearance {
    self.leftLab.textColor = SSJ_MAIN_COLOR;
    self.nicknameField.textColor = SSJ_SECONDARY_COLOR;
    self.nicknameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入昵称" attributes:@{NSForegroundColorAttributeName:SSJ_SECONDARY_COLOR}];
}

- (UILabel *)leftLab {
    if (!_leftLab) {
        _leftLab = [[UILabel alloc] init];
        _leftLab.text = @"昵称";
        _leftLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _leftLab;
}

- (UITextField *)nicknameField {
    if (!_nicknameField) {
        _nicknameField = [[UITextField alloc] init];
        _nicknameField.textAlignment = NSTextAlignmentRight;
        _nicknameField.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _nicknameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _nicknameField;
}

@end
