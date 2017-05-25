
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

@property(nonatomic, strong) UIImageView *addImageView;

@end


@implementation SSJSharebooksMemberCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.iconImageView];
        [self addSubview:self.nickNameLabel];
        [self addSubview:self.addImageView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.iconImageView.layer.cornerRadius = self.iconImageView.height / 2;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.layer.cornerRadius = self.width / 2;
        _iconImageView.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha].CGColor;
        _iconImageView.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    }
    return _iconImageView;
}

- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _nickNameLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _nickNameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nickNameLabel;
}

- (UIImageView *)addImageView {
    if (!_addImageView) {
        _addImageView = [[UIImageView alloc] init];
        _addImageView.image = [[UIImage imageNamed:@"sharebk_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _addImageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [_addImageView sizeToFit];
    }
    return _addImageView;
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
    
    [self.addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.iconImageView);
    }];
    
    [super updateConstraints];
}

- (void)setMemberItem:(SSJShareBookMemberItem *)memberItem {
    if (![memberItem.memberId isEqualToString:@"-1"]) {
        self.nickNameLabel.text = self.memberItem.nickName;
        NSString *imageUrl = self.memberItem.icon;
        if (![imageUrl hasPrefix:@"http"]) {
            imageUrl = SSJImageURLWithAPI(imageUrl);
        }
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];
        self.addImageView.hidden = YES;
        self.backgroundColor = [UIColor clearColor];
    } else {
        self.nickNameLabel.text = @"";
        self.addImageView.hidden = NO;
        self.iconImageView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    [self setNeedsUpdateConstraints];
}

- (void)updateCellAppearanceAfterThemeChanged {
    _nickNameLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _iconImageView.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha].CGColor;
    _addImageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
}

@end
