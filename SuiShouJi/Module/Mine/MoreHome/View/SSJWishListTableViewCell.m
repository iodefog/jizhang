//
//  SSJWishListTableViewCell.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishListTableViewCell.h"

#import "SSJWishProgressView.h"
@interface SSJWishListTableViewCell ()
/**bg*/
@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UILabel *wishTitleL;

@property (nonatomic, strong) SSJWishProgressView *wishProgressView;

@property (nonatomic, strong) UILabel *saveAmountL;

@property (nonatomic, strong) UILabel *targetAmountL;

/**stateLabel*/
@property (nonatomic, strong) UILabel *stateLabel;
@end


@implementation SSJWishListTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.bgView];
        [self.bgView addSubview:self.wishTitleL];
        [self.bgView addSubview:self.wishProgressView];
        [self.bgView addSubview:self.saveAmountL];
        [self.bgView addSubview:self.targetAmountL];
        [self.bgView addSubview:self.stateLabel];

        [self setNeedsUpdateConstraints];
    }
    return self;
}

+ (SSJWishListTableViewCell *)cellWithTableView:(UITableView *)tableView {
    static NSString *cellId = @"SSJWishListTableViewCellId";
    SSJWishListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SSJWishListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

#pragma mark - Layout
- (void)updateConstraints {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.wishTitleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leftMargin.mas_equalTo(15);
        make.height.lessThanOrEqualTo(@50);
        make.top.mas_equalTo(15);
        make.rightMargin.mas_equalTo(-15);
        make.height.greaterThanOrEqualTo(@22);
    }];
    
    [self.wishProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.height.mas_equalTo(37);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.wishTitleL.mas_bottom).offset(52);
    }];
    
    [self.saveAmountL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.wishTitleL);
        make.width.mas_equalTo(self.wishTitleL.mas_width).multipliedBy(0.5);
        make.top.mas_equalTo(self.wishProgressView.mas_bottom).offset(15);
        make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-25);
    }];
    
    [self.targetAmountL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.saveAmountL.mas_right);
        make.width.top.bottom.mas_equalTo(self.saveAmountL);
    }];

    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.wishTitleL);
        make.height.mas_equalTo(22);
        make.right.mas_equalTo(0);
        make.width.mas_equalTo(66);
    }];

    [super updateConstraints];
}

#pragma mark - Lazy
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.layer.cornerRadius = 8;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (SSJWishProgressView *)wishProgressView {
    if (!_wishProgressView) {
        _wishProgressView = [[SSJWishProgressView alloc] initWithFrame:CGRectZero proColor:[UIColor ssj_colorWithHex:@"#FFBB3C"] trackColor:[UIColor whiteColor]];
    }
    return _wishProgressView;
}

- (UILabel *)saveAmountL {
    if (!_saveAmountL) {
        _saveAmountL = [[UILabel alloc] init];
        _saveAmountL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _saveAmountL.text = @"已存入";
    }
    return _saveAmountL;
}

- (UILabel *)targetAmountL {
    if (!_targetAmountL) {
        _targetAmountL = [[UILabel alloc] init];
        _targetAmountL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _targetAmountL.text = @"目标金额";
    }
    return _targetAmountL;
}

- (UILabel *)wishTitleL {
    if (!_wishTitleL) {
        _wishTitleL = [[UILabel alloc] init];
        _wishTitleL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _wishTitleL;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _stateLabel;
}
@end
