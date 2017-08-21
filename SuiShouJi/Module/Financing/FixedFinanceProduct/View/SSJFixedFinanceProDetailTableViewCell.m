//
//  SSJFixedFinanceProDetailTableViewCell.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceProDetailTableViewCell.h"

@interface SSJFixedFinanceProDetailTableViewCell()

@property (nonatomic, strong) UILabel *nameL;

@property (nonatomic, strong) UILabel *subNameL;

@property (nonatomic, strong) UIImageView *leftImageView;

@property (nonatomic, strong) UILabel *percentageL;

@end

@implementation SSJFixedFinanceProDetailTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.textField];
        [self.contentView addSubview:self.nameL];
        [self.contentView addSubview:self.subNameL];
        [self.contentView addSubview:self.segmentControl];
        [self.contentView addSubview:self.percentageL];
        
        [self updateAppearance];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(15);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.leftImageView);
        make.left.mas_equalTo(self.leftImageView.mas_right).offset(10);
        make.width.greaterThanOrEqualTo(0);
    }];
    
    [self.subNameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameL.mas_bottom).offset(10);
        make.left.mas_equalTo(self.nameL);
        make.width.greaterThanOrEqualTo(0);
    }];
    
    if (self.hasPercentageL) {
        [self.percentageL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
            make.width.greaterThanOrEqualTo(0);
        }];
        
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.leftImageView);
            make.left.mas_equalTo(self.nameL.mas_right);
            make.right.mas_equalTo(self.percentageL.mas_left);
        }];
    } else {
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.leftImageView);
            make.left.mas_equalTo(self.nameL.mas_right);
            make.right.mas_equalTo(-15);
        }];
        
        [self.segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.subNameL);
            make.right.mas_equalTo(-15);
            make.width.mas_equalTo(102);
        }];
    }
   
    [super updateConstraints];
}

- (void)updateAppearance {
    self.nameL.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.subNameL.textColor = self.percentageL.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.textField.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.imageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

#pragma mark - Lazy
- (UILabel *)nameL {
    if (!_nameL) {
        _nameL = [[UILabel alloc] init];
        _nameL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _nameL;
}

- (UILabel *)subNameL {
    if (!_subNameL) {
        _subNameL = [[UILabel alloc] init];
        _subNameL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _subNameL;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _textField.textAlignment = NSTextAlignmentRight;
    }
    return _textField;
}

- (UISegmentedControl *)segmentControl {
    if (!_segmentControl) {
        _segmentControl = [[UISegmentedControl alloc] init];
    }
    return _segmentControl;
}

- (UIImageView *)leftImageView {
    if (!_leftImageView) {
        _leftImageView = [[UIImageView alloc] init];
    }
    return _leftImageView;
}

- (UILabel *)percentageL {
    if (!_percentageL) {
        _percentageL = [[UILabel alloc] init];
        _percentageL.text = @"%";
        _percentageL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _percentageL;
}

@end
