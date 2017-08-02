//
//  SSJRewardRankViewCell.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/31.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRewardRankViewCell.h"

#import "SSJRankListItem.h"


@interface SSJRewardRankViewCell ()
@property (nonatomic, strong) UILabel *rankL;

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UIImageView *markImageView;

@property (nonatomic, strong) UILabel *nameL;

@property (nonatomic, strong) UILabel *memoL;

@property (nonatomic, strong) UILabel *moneyL;
@end

@implementation SSJRewardRankViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.rankL];
        [self.contentView addSubview:self.iconImageView];
        [self.contentView addSubview:self.markImageView];
        [self.contentView addSubview:self.nameL];
        [self.contentView addSubview:self.memoL];
        [self.contentView addSubview:self.moneyL];
        
        [self setNeedsUpdateConstraints];
        [self updateAppearance];

    }
    return self;
}

+ (SSJRewardRankViewCell *)cellWithTableView:(UITableView *)tableView {
    static NSString *cellId = @"SSJRewardRankViewCellId";
    SSJRewardRankViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SSJRewardRankViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    return cell;
}

- (void)isNotShowSelfRank:(BOOL)isNotShow {
    if (isNotShow) {
        self.rankL.hidden = YES;
    } else {
        self.rankL.hidden = NO;
    }
}

#pragma mark - Layout
- (void)updateConstraints {
    [self.rankL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(79);
    }];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.rankL);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.left.mas_equalTo(self.rankL.mas_right).offset(10);
    }];
    
    [self.markImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.iconImageView);
        make.bottom.mas_equalTo(self.iconImageView.mas_top);
        make.size.mas_equalTo(CGSizeMake(15, 12));
    }];
    
    if ([self.cellItem isKindOfClass:[SSJRankListItem class]]) {
        SSJRankListItem *item = self.cellItem;
        if (item.memo.length) {
            [self.nameL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.rankL.mas_centerY).offset(-2);
                make.left.mas_equalTo(self.iconImageView.mas_right).offset(10);
                make.height.greaterThanOrEqualTo(0);
                make.right.mas_equalTo(self.moneyL.mas_left).offset(-5);
            }];
            
            [self.memoL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.rankL.mas_centerY).offset(2);
                make.left.mas_equalTo(self.nameL);
                make.right.mas_equalTo(self.nameL);
                make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-20);
            }];
            
        } else {
            [self.nameL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.rankL);
                make.left.mas_equalTo(self.iconImageView.mas_right).offset(10).offset(5);
                make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-32);
                make.right.mas_equalTo(self.moneyL.mas_left);
            }];
        }
    }
    
    [self.moneyL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView);
        make.right.mas_equalTo(-15);
        make.height.greaterThanOrEqualTo(0);
        make.width.lessThanOrEqualTo(@110);
    }];
    
    [super updateConstraints];
}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    [super setCellItem:cellItem];
    if (![cellItem isKindOfClass:[SSJRankListItem class]]) return;
    SSJRankListItem *item = cellItem;
    self.rankL.text = item.ranking;
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:item.cicon] placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];
    self.memoL.text = item.memo;
    self.moneyL.text = item.summoney;
    self.nameL.text = item.crealname;
    if ([item.ranking isEqualToString:@"1"]) {
        self.markImageView.hidden = NO;
        self.markImageView.image = [UIImage imageNamed:@"rank_mark_img_jin"];
    } else if ([item.ranking isEqualToString:@"2"]) {
        self.markImageView.hidden = NO;
        self.markImageView.image = [UIImage imageNamed:@"rank_mark_img_yin"];
    } else if ([item.ranking isEqualToString:@"3"]) {
        self.markImageView.hidden = NO;
        self.markImageView.image = [UIImage imageNamed:@"rank_mark_img_tong"];
    } else {
        self.markImageView.hidden = YES;
    }

}

#pragma mark - Theme
- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.rankL.textColor = self.nameL.textColor = self.moneyL.textColor = SSJ_MAIN_COLOR;
    self.memoL.textColor = SSJ_SECONDARY_COLOR;
}

#pragma mark - Lazy
- (UILabel *)rankL {
    if (!_rankL) {
        _rankL = [[UILabel alloc] init];
        _rankL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _rankL.textAlignment = NSTextAlignmentCenter;
    }
    return _rankL;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        CAShapeLayer *layer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 40, 40) cornerRadius:20];
        layer.path = path.CGPath;
        _iconImageView.layer.mask = layer;
    }
    return _iconImageView;
}

- (UIImageView *)markImageView {
    if (!_markImageView) {
        _markImageView = [[UIImageView alloc] init];
    }
    return _markImageView;
}

- (UILabel *)nameL {
    if (!_nameL) {
        _nameL = [[UILabel alloc] init];
        _nameL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _nameL;
}

-(UILabel *)memoL {
    if (!_memoL) {
        _memoL = [[UILabel alloc] init];
        _memoL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _memoL.numberOfLines = 0;
    }
    return _memoL;
}

- (UILabel *)moneyL {
    if (!_moneyL) {
        _moneyL = [[UILabel alloc] init];
        _moneyL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
        _moneyL.textAlignment = NSTextAlignmentRight;
    }
    return _moneyL;
}
@end
