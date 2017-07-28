//
//  SSJMakeWishMoneyCollectionViewCell.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJMakeWishMoneyCollectionViewCell.h"

@interface SSJMakeWishMoneyCollectionViewCell ()

@property (nonatomic, strong) UILabel *moneyBtn;
@end

@implementation SSJMakeWishMoneyCollectionViewCell
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.moneyBtn];
        
        [self updateConstraintsIfNeeded];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateThemeAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];
        [self updateThemeAfterThemeChanged];
    }
    return self;
}

- (void)updateThemeAfterThemeChanged {
    UIImage *selectedImage = [UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha] size:CGSizeZero];
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:selectedImage];
    
    self.moneyBtn.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.moneyBtn.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha].CGColor;
}


- (UILabel *)moneyBtn {
    if (!_moneyBtn) {
        _moneyBtn = [[UILabel alloc] init];
        _moneyBtn.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _moneyBtn.textAlignment = NSTextAlignmentCenter;
        _moneyBtn.layer.borderWidth = 1;
        _moneyBtn.layer.cornerRadius = 6;
        _moneyBtn.layer.masksToBounds = YES;
        _moneyBtn.backgroundColor = [UIColor clearColor];
    }
    return _moneyBtn;
}

- (void)updateConstraints {
    
    [self.moneyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.mas_equalTo(0);
    }];
    [super updateConstraints];
}

- (void)setAmontStr:(NSString *)amontStr {
    _amontStr = amontStr;
    _moneyBtn.text = amontStr;
}

@end
