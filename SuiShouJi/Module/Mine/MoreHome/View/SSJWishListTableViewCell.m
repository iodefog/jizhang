//
//  SSJWishListTableViewCell.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishListTableViewCell.h"

#import "SSJWishProgressView.h"

#import "SSJWishModel.h"

@interface SSJWishListTableViewCell ()
/**bg*/
@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UILabel *wishTitleL;

@property (nonatomic, strong) SSJWishProgressView *wishProgressView;

@property (nonatomic, strong) UILabel *saveAmountL;

@property (nonatomic, strong) UILabel *targetAmountL;

/**stateLabel*/
@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, strong) UIButton *stateBtn;
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
        [self.bgView addSubview:self.stateBtn];

        [self setNeedsUpdateConstraints];
        [self updateAppearance];
        self.stateBtn.hidden = YES;
        self.stateLabel.hidden = YES;
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

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    [super setCellItem:cellItem];
    if ([cellItem isKindOfClass:[SSJWishModel class]]) {
        SSJWishModel *item = cellItem;
        self.wishTitleL.text = item.wishName;
        self.saveAmountL.text = [NSString stringWithFormat:@"已存入：%@",item.wishSaveMoney];
        self.targetAmountL.text = [NSString stringWithFormat:@"目标金额：%@",item.wishMoney];
        if (self.wishProgressView.width == 0) {
            self.wishProgressView.width = self.width - 30;
            self.wishProgressView.height = 37;
        }
        self.wishProgressView.progress = [item.wishSaveMoney floatValue] / [item.wishMoney floatValue];
        [self updateStateBtnAppearance];
    }
    
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
        make.right.mas_equalTo(11);
        make.width.mas_equalTo(66);
    }];
    
    [self.stateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.wishTitleL);
        make.height.mas_equalTo(22);
        make.right.mas_equalTo(-15);
        make.width.mas_equalTo(66);
    }];

    [super updateConstraints];
}

#pragma mark - Theme
- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.stateBtn.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor].CGColor;
        self.contentView.backgroundColor = [UIColor clearColor];
    self.stateLabel.textColor = [UIColor whiteColor];
    self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.saveAmountL.textColor = self.targetAmountL.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.stateLabel.backgroundColor = [UIColor lightGrayColor];

    if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
        self.bgView.backgroundColor =SSJ_DEFAULT_BACKGROUND_COLOR;
    } else {
        self.bgView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailHeaderColor alpha:SSJ_CURRENT_THEME.financingDetailHeaderAlpha];
    }
    [self updateStateBtnAppearance];
}

- (void)updateStateBtnAppearance {
    if (![self.cellItem isKindOfClass:[SSJWishModel class]]) return;
    SSJWishModel *item = self.cellItem;
    if (item.status == SSJWishStateTermination) {//终止
        self.stateLabel.hidden = NO;
        self.stateLabel.text = @"终止";
        self.stateBtn.hidden = YES;
    } else if (item.status == SSJWishStateFinish) {//完成
        if ([item.wishSaveMoney doubleValue] > [item.wishMoney doubleValue]) {
            self.stateLabel.text = @"超额完成";
        } else {
            self.stateLabel.text = @"已完成";
        }
        self.stateBtn.hidden = YES;
        self.stateLabel.hidden = NO;
    } else {//进行中
        [self.stateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.stateBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
        [self.stateBtn setTitle:@"存" forState:UIControlStateNormal];
        self.stateLabel.hidden = YES;
        self.stateBtn.hidden = NO;
    }
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
        _targetAmountL.textAlignment = NSTextAlignmentRight;
    }
    return _targetAmountL;
}

- (UILabel *)wishTitleL {
    if (!_wishTitleL) {
        _wishTitleL = [[UILabel alloc] init];
        _wishTitleL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _wishTitleL.numberOfLines = 0;
    }
    return _wishTitleL;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.layer.cornerRadius = 11;
        _stateLabel.layer.masksToBounds = YES;
    }
    return _stateLabel;
}

- (UIButton *)stateBtn {
    if (!_stateBtn) {
        _stateBtn = [[UIButton alloc] init];
        _stateBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _stateBtn.layer.cornerRadius = 11;
        _stateBtn.layer.borderWidth = 1;
        _stateBtn.layer.masksToBounds = YES;
        
        [_stateBtn addTarget:self action:@selector(stateBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stateBtn;
}

- (void)stateBtnClicked:(UIButton *)stateBtn {
    SSJWishModel *item = self.cellItem;
    if (self.wishSaveMoneyBlock) {
        self.wishSaveMoneyBlock(item);
    }
//    if (item.status == SSJWishStateTermination) {//终止
//
//    } else if (item.status == SSJWishStateFinish) {//完成
//    } else {//进行中
//        
//    }

}

@end
