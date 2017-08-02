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

/**<#注释#>*/
@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UILabel *wishTitleL;

@property (nonatomic, strong) SSJWishProgressView *wishProgressView;

@property (nonatomic, strong) UILabel *saveAmountL;

@property (nonatomic, strong) UILabel *targetAmountL;

/**stateLabel*/
@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, strong) UIButton *stateBtn;

/**是否显示动画*/
@property (nonatomic, assign, getter=isShowAnimation) BOOL showAnimation;
@end



@implementation SSJWishListTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.bgView];
        [self.bgView addSubview:self.bgImageView];
        [self.bgImageView addSubview:self.coverView];
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

+ (SSJWishListTableViewCell *)cellWithTableView:(UITableView *)tableView animation:(BOOL)animation{
    static NSString *cellId = @"SSJWishListTableViewCellId";
    SSJWishListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SSJWishListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.showAnimation = animation;
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
        
        [self.wishProgressView setProgress:[item.wishSaveMoney doubleValue] / [item.wishMoney doubleValue] withAnimation:self.isShowAnimation];
        
        UIImage *image = [UIImage imageNamed:item.wishImage];
        if (!image) {
            NSString *imgPath = SSJImagePath(item.wishImage);
            image = [UIImage imageWithContentsOfFile:imgPath];
        }
        if (!image) {
            [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:SSJImageURLWithAPI(item.wishImage)] placeholderImage:[UIImage imageNamed:@"wish_image_def"]];
        } else {
            self.bgImageView.image = image;
        }

        [self updateStateBtnAppearance];
    }
    
}

#pragma mark - Layout
- (void)updateConstraints {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(kFinalImgHeight(SSJSCREENWITH));
    }];
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_offset(0);
    }];
    
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
    
    [self.wishTitleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leftMargin.mas_equalTo(15);
        make.right.mas_equalTo(self.stateBtn.mas_left).offset(-5);
        make.height.lessThanOrEqualTo(@50);
        make.centerY.mas_equalTo(self.wishProgressView.mas_top).multipliedBy(0.5);
        make.height.greaterThanOrEqualTo(@22);
    }];
    
    [self.wishProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(18);
        make.height.mas_equalTo(37);
        make.right.mas_equalTo(-18);
        make.centerY.mas_equalTo(kFinalImgHeight(SSJSCREENWITH)*0.5).offset(7);
    }];
    
    [self.saveAmountL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.wishTitleL);
        make.width.mas_equalTo(self.targetAmountL.mas_width);
        make.top.mas_equalTo(self.wishProgressView.mas_bottom).offset(15);
        make.height.greaterThanOrEqualTo(0);
    }];
    
    [self.targetAmountL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.saveAmountL.mas_right);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.saveAmountL);
        make.height.greaterThanOrEqualTo(0);
    }];

    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 20));
        make.centerX.mas_equalTo(self.bgView.mas_right).offset(-25);
        make.centerY.mas_equalTo(self.bgView.mas_top).offset(25);
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
//- (void)updateCellAppearanceAfterThemeChanged {
//    [super updateCellAppearanceAfterThemeChanged];
//    [self updateAppearance];
//}

- (void)updateAppearance {
    self.stateLabel.textColor = [UIColor whiteColor];
    self.stateLabel.backgroundColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].borderColor];
    self.textLabel.textColor = [UIColor whiteColor];
    self.saveAmountL.textColor = self.targetAmountL.textColor = [UIColor whiteColor];
    self.wishTitleL.textColor = [UIColor whiteColor];
    
    self.bgView.backgroundColor =[UIColor clearColor];
    [self updateStateBtnAppearance];
}

- (void)updateStateBtnAppearance {
    if (![self.cellItem isKindOfClass:[SSJWishModel class]]) return;
    SSJWishModel *item = self.cellItem;
    if (item.status == SSJWishStateTermination) {//终止
        self.stateLabel.hidden = NO;
        self.stateLabel.text = @"终止";
        self.stateBtn.hidden = YES;
        self.stateLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        self.wishProgressView.progressColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor alpha:0.5];
    } else if (item.status == SSJWishStateFinish) {//完成
        if ([item.wishSaveMoney doubleValue] > [item.wishMoney doubleValue]) {
            self.stateLabel.text = @"超额完成";
        } else {
            self.stateLabel.text = @"已完成";
        }
        self.stateBtn.hidden = YES;
        self.stateLabel.hidden = NO;
        self.stateLabel.textColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].buttonColor];
        self.wishProgressView.progressColor = [UIColor ssj_colorWithHex:@"#FFBB3C"];
    } else {//进行中
        [self.stateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.stateBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].buttonColor] forState:UIControlStateNormal];
        self.stateLabel.textColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].buttonColor];
        [self.stateBtn setTitle:@"存" forState:UIControlStateNormal];
        self.stateLabel.hidden = YES;
        self.stateBtn.hidden = NO;
        self.wishProgressView.progressColor = [UIColor ssj_colorWithHex:@"#FFBB3C"];
    }
}

#pragma mark - Lazy
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.userInteractionEnabled = YES;
    }
    return _bgImageView;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [UIColor ssj_colorWithHex:@"000000" alpha:0.3];
        _coverView.layer.cornerRadius = 6;
    }
    return _coverView;
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
        _stateLabel.transform = CGAffineTransformMakeRotation(M_PI_4);
        _stateLabel.layer.anchorPoint = CGPointMake(0.5, 0.5);
    }
    return _stateLabel;
}

- (UIButton *)stateBtn {
    if (!_stateBtn) {
        _stateBtn = [[UIButton alloc] init];
        _stateBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _stateBtn.layer.cornerRadius = 11;
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
