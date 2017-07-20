//
//  SSJWishChargeCell.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishChargeCell.h"

@interface SSJWishChargeCell ()

@property (nonatomic, strong) UILabel *wishTimeL;

@property (nonatomic, strong) UILabel *wishNameL;

@property (nonatomic, strong) UILabel *wishMemoL;

@property (nonatomic, strong) UIView *verticalLine;

@property (nonatomic, strong) UIView *circleView;

@property (nonatomic, strong) UIButton *wishEditBtn;

@property (nonatomic, strong) UIButton *wishDeleteBtn;

/**是否已经选中*/
@property (nonatomic, assign) BOOL isSelected;
@end

@implementation SSJWishChargeCell

+ (SSJWishChargeCell *)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJWishChargeCell";
    SSJWishChargeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SSJWishChargeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.wishTimeL.text = @"2017-10-3";
        cell.wishNameL.text = @"+100000";
        cell.wishMemoL.text = @"我要买房我要买房我要买房我要买房我要买房我要买房我要买房我要买房我要买房我要买房我要买房我要买房我要买房我要买房";
        [cell layoutIfNeeded];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.wishTimeL];
        [self.contentView addSubview:self.wishNameL];
        [self.contentView addSubview:self.wishMemoL];
        [self.contentView addSubview:self.verticalLine];
        [self.contentView addSubview:self.circleView];
        [self.contentView addSubview:self.wishEditBtn];
        [self.contentView addSubview:self.wishDeleteBtn];
        
        [self normalSubviewsAlpha];
        [self updateAppearance];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (selected == YES) {
        if (self.isSelected == YES) {
            [self normalSubviewsAlpha];
            self.isSelected = NO;
        } else {
            [self selectedSubviewsAlpha];
            self.isSelected = YES;
        }
    } else {
        if (self.isSelected == YES) {
            self.isSelected = NO;
        }
        [self normalSubviewsAlpha];
    }
}

#pragma mark - Private
- (void)normalSubviewsAlpha {
    self.wishTimeL.alpha = 1;
    self.wishNameL.alpha = 1;
    self.wishMemoL.alpha = 1;
    self.wishEditBtn.alpha = 0;
    self.wishDeleteBtn.alpha = 0;
    self.wishDeleteBtn.transform = CGAffineTransformIdentity;
    self.wishEditBtn.transform = CGAffineTransformIdentity;
}

- (void)selectedSubviewsAlpha {
    @weakify(self);
    [UIView animateWithDuration:0.2 animations:^{
        @strongify(self);
        self.wishTimeL.alpha = 0;
        self.wishNameL.alpha = 0;
        self.wishMemoL.alpha = 0;
        self.wishEditBtn.alpha = 1;
        self.wishDeleteBtn.alpha = 1;
        self.wishDeleteBtn.transform = CGAffineTransformMakeTranslation(-self.contentView.width * 0.25, 0);
        self.wishEditBtn.transform = CGAffineTransformMakeTranslation(self.contentView.width * 0.25, 0);;
    }];
}


#pragma mark - Layout
- (void)updateConstraints {
    [self.wishTimeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(self.contentView.mas_centerX).offset(-22.5);
        make.width.greaterThanOrEqualTo(0);
    }];
    
    [self.wishNameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_centerX).offset(24.5);
        make.top.mas_equalTo(self.wishTimeL);
        make.width.greaterThanOrEqualTo(0);
    }];
    
    [self.wishMemoL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.wishNameL.mas_bottom).offset(4);
        make.height.greaterThanOrEqualTo(0);
        make.left.mas_equalTo(self.wishNameL);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-35);
    }];
    
    [self.verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.width.mas_equalTo(1);
        make.centerX.mas_equalTo(self.contentView);
    }];
    
    [self.circleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.centerY.mas_equalTo(self.wishTimeL);
        make.size.mas_equalTo(CGSizeMake(8, 8));
    }];
    
    [self.wishEditBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.centerY.mas_equalTo(self.wishTimeL);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    [self.wishDeleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.centerY.mas_equalTo(self.wishTimeL);
        make.size.mas_equalTo(self.wishEditBtn);
    }];
    
    [super updateConstraints];
}

#pragma mark - Theme
- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.backgroundColor = [UIColor clearColor];
    self.wishTimeL.textColor = self.wishNameL.textColor = SSJ_MAIN_COLOR;
    self.wishMemoL.textColor = SSJ_SECONDARY_COLOR;
    self.verticalLine.backgroundColor = self.circleView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor];
}

#pragma mark - Lazy
- (UILabel *)wishTimeL {
    if (!_wishTimeL) {
        _wishTimeL = [[UILabel alloc] init];
        _wishTimeL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _wishTimeL;
}

- (UILabel *)wishNameL {
    if (!_wishNameL) {
        _wishNameL = [[UILabel alloc] init];
        _wishNameL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _wishNameL;
}

- (UILabel *)wishMemoL {
    if (!_wishMemoL) {
        _wishMemoL = [[UILabel alloc] init];
        _wishMemoL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _wishMemoL.numberOfLines = 2;
    }
    return _wishMemoL;
}

- (UIView *)verticalLine {
    if (!_verticalLine) {
        _verticalLine = [[UIView alloc] init];
    }
    return _verticalLine;
}

- (UIView *)circleView {
    if (!_circleView) {
        _circleView = [[UIView alloc] init];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 8, 8) cornerRadius:4];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.path = path.CGPath;
        _circleView.layer.mask = maskLayer;
    }
    return _circleView;
}

- (UIButton *)wishEditBtn {
    if (!_wishEditBtn) {
        _wishEditBtn = [[UIButton alloc] init];
        [_wishEditBtn setImage:[UIImage imageNamed:@"home_edit"] forState:UIControlStateNormal];
        @weakify(self);
        [[_wishEditBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.wishChargeEdidBlock) {
                self.wishChargeEdidBlock(self);
            }
        }];
    }
    return _wishEditBtn;
}

- (UIButton *)wishDeleteBtn {
    if (!_wishDeleteBtn) {
        _wishDeleteBtn = [[UIButton alloc] init];
        [_wishDeleteBtn setImage:[UIImage imageNamed:@"home_delete"] forState:UIControlStateNormal];
        @weakify(self);
        [[_wishDeleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.wishChargeDelegateBlock) {
                self.wishChargeDelegateBlock(self);
            }
        }];
    }
    return _wishDeleteBtn;
}
@end
