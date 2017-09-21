//
//  SSJFixedFinanceProDetailTableViewCell.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceProDetailTableViewCell.h"


@interface SSJFixedFinanceProDetailTableViewCell()


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
        [self.contentView addSubview:self.leftImageView];
        [self updateAppearance];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(16);
        make.size.mas_equalTo(CGSizeMake(21, 21));
    }];
    
    [self.nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.leftImageView);
        make.left.mas_equalTo(self.leftImageView.mas_right).offset(10);
        make.width.greaterThanOrEqualTo(0);
    }];
    
    if (!self.hasNotSegment) {//有
        [self.subNameL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.nameL.mas_bottom);
            make.left.mas_equalTo(self.nameL);
            make.right.mas_equalTo(self.segmentControl.mas_left);
            make.bottom.mas_equalTo(0);
        }];
    } else {
        [self.subNameL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.nameL.mas_bottom);
            make.left.mas_equalTo(self.nameL);
            make.right.mas_equalTo(-15);
            make.bottom.mas_equalTo(0);
        }];
    }
    
    
    if (self.hasPercentageL) {
        [self.percentageL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
            make.width.greaterThanOrEqualTo(0);
            make.height.mas_equalTo(self.textField);
            make.bottom.mas_equalTo(self.contentView.mas_centerY);
        }];
        
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(100);
            make.right.mas_equalTo(self.percentageL.mas_left);
            make.bottom.mas_equalTo(self.percentageL);
        }];
    } else {
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(100);
            make.right.mas_equalTo(-15);
            make.bottom.mas_equalTo(self.contentView.mas_centerY);
        }];
    }
    
    if (!self.hasNotSegment) {
        [self.segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_centerY);
            make.right.mas_equalTo(-15);
            make.width.mas_equalTo(102);
            make.height.mas_equalTo(20);
        }];
    }
    [super updateConstraints];
}

- (void)updateAppearance {
    self.nameL.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.subNameL.textColor = self.percentageL.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.textField.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.leftImageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.segmentControl.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.segmentControl.selectedBorderColor = [UIColor clearColor];
    [self.segmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} forState:UIControlStateNormal];
    [self.segmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateSelected];
    self.segmentControl.selectedbgColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
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
        _subNameL.numberOfLines = 0;
    }
    return _subNameL;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _textField.textAlignment = NSTextAlignmentRight;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _textField;
}

- (SSJSegmentedControl *)segmentControl {
    if (!_segmentControl) {
        _segmentControl = [[SSJSegmentedControl alloc] initWithItems:@[@"年",@"月",@"日"]];
        

        @weakify(self);
        [[_segmentControl rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(SSJSegmentedControl *segCtrl) {
            @strongify(self);
            self.segmentSelectedIndex = segCtrl.selectedSegmentIndex;
        }];

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
