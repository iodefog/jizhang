//
//  SSJFixedFinProductListCell.m
//  SuiShouJi
//
//  Created by yi cai on 2017/9/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinProductListCell.h"
#import "SSJLoanListCellItem.h"

@interface SSJFixedFinProductListCell()
@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UILabel *memoLab;

@property (nonatomic, strong) UILabel *moneyLab;

@property (nonatomic, strong) UILabel *dateLab;

@property (nonatomic, strong) UIImageView *stamp;

/**stateLabel*/
@property (nonatomic, strong) UILabel *stateLabel;

/**<#注释#>*/
@property (nonatomic, strong) UILabel *descLabel;
@end
@implementation SSJFixedFinProductListCell

+ (SSJFixedFinProductListCell *)cellWithTableView:(UITableView *)tableView {
    static NSString *cellId = @"SSJFixedFinProductListCellId";
    SSJFixedFinProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SSJFixedFinProductListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.stateLabel];
        _stamp = [[UIImageView alloc] initWithImage:[UIImage ssj_themeImageWithName:@"loan_stamp"]];
        _stamp.size = CGSizeMake(72, 72);
        [self.contentView addSubview:_stamp];
        
        [self.contentView addSubview:self.descLabel];
        
        _icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [self.contentView addSubview:_icon];
        
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
        [self.contentView addSubview:_titleLab];
        
        _memoLab = [[UILabel alloc] init];
        _memoLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [self.contentView addSubview:_memoLab];
        
        _moneyLab = [[UILabel alloc] init];
        _moneyLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [self.contentView addSubview:_moneyLab];
        
        _dateLab = [[UILabel alloc] init];
        _dateLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [self.contentView addSubview:_dateLab];
        
        [self.contentView addSubview:self.descLabel];
        
        [self updateAppearance];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    [_stamp mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-22);
        make.centerX.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(72, 72));
    }];
    
    [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_icon.mas_right).offset(10);
        make.centerY.mas_equalTo(_icon);
        make.width.mas_equalTo(100);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    
    [_dateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(21);
        make.left.mas_equalTo(_icon);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(15);
    }];
    
    [_memoLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_titleLab.mas_left);
        make.right.mas_equalTo(100);
        make.top.mas_equalTo(_titleLab.mas_bottom).offset(10);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    
    [_moneyLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(_icon);
        make.width.mas_greaterThanOrEqualTo(0);
        make.height.mas_greaterThanOrEqualTo(0);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_moneyLab.mas_bottom).offset(10);
        make.right.mas_equalTo(_moneyLab.mas_right);
        make.width.mas_greaterThanOrEqualTo(0);
        make.height.mas_equalTo(15);
    }];
    
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 70));
        make.centerX.mas_equalTo(self.contentView.width - 20);
        make.centerY.mas_equalTo(20);
    }];
}

- (void)setCellItem:(SSJBaseCellItem *)cellItem {
    SSJLoanListCellItem *item = (SSJLoanListCellItem *)cellItem;
    _icon.image = [UIImage imageNamed:item.icon];
    _titleLab.text = item.loanTitle;
    _memoLab.text = item.memo;
    _moneyLab.text = [NSString stringWithFormat:@"+%@",item.money];
    _dateLab.text = item.date;
    _stamp.hidden = !item.showStamp;
    self.descLabel.text = item.descStr;
    if (item.imageName.length) {
        _stamp.image = [UIImage imageNamed:item.imageName];
        [_stamp sizeToFit];
    }
    
    if (_stamp.hidden == NO) {
        self.stateLabel.hidden = YES;
    } else {
        self.stateLabel.hidden = !item.showStateL;
    }
    
}

#pragma mark - Lazy
- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.transform = CGAffineTransformMakeRotation(M_PI_4);
        _stateLabel.layer.anchorPoint = CGPointMake(0.5, 0.5);
        _stateLabel.text = @"已到期";
    }
    return _stateLabel;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _descLabel;
}


- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _stateLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    _memoLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _moneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _dateLab.textColor = self.descLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.stateLabel.backgroundColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].borderColor];
}

@end
