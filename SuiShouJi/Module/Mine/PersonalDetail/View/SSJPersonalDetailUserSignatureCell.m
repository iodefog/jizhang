//
//  SSJPersonalDetailUserSignatureCell.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/4.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJPersonalDetailUserSignatureCell.h"
#import "SSJCustomTextView.h"

@implementation SSJPersonalDetailUserSignatureCellItem

+ (instancetype)itemWithSignatureLimit:(NSUInteger)signatureLimit signature:(NSString *)signature {
    SSJPersonalDetailUserSignatureCellItem *item = [[SSJPersonalDetailUserSignatureCellItem alloc] init];
    item.signatureLimit = signatureLimit;
    item.signature = signature;
    return item;
}

@end

@interface SSJPersonalDetailUserSignatureCell ()

@property (nonatomic, strong) UILabel *leftLab;

@property (nonatomic, strong) UILabel *counter;

@property (nonatomic, strong) UITextField *signatureField;

@end

@implementation SSJPersonalDetailUserSignatureCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.leftLab];
        [self.contentView addSubview:self.counter];
        [self.contentView addSubview:self.signatureField];
        [self setNeedsUpdateConstraints];
        [self updateAppearance];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)updateConstraints {
    [self.leftLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(18);
        make.left.mas_equalTo(15);
    }];
    [self.signatureField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.leftLab.mas_bottom).offset(8);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(20);
    }];
    [self.counter mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-10);
        make.right.mas_equalTo(-15);
    }];
    [super updateConstraints];
}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJPersonalDetailUserSignatureCellItem class]]) {
        return;
    }
    [super setCellItem:cellItem];
    
    SSJPersonalDetailUserSignatureCellItem *item = cellItem;
    self.signatureField.text = item.signature;
    RACChannelTo(item, signature) = self.signatureField.rac_newTextChannel;
    
    RAC(self.counter, text) = [[RACSignal merge:@[[RACObserve(item, signature) takeUntil:self.rac_prepareForReuseSignal],
                      self.signatureField.rac_textSignal]] map:^id(NSString *text) {
        return [NSString stringWithFormat:@"%d", (int)(item.signatureLimit - text.length)];
    }];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.leftLab.textColor = SSJ_MAIN_COLOR;
    self.counter.textColor = SSJ_SECONDARY_COLOR;
    self.signatureField.textColor = SSJ_SECONDARY_COLOR;
    self.signatureField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入记账小目标，更有利于小目标实现哦" attributes:@{NSForegroundColorAttributeName:SSJ_SECONDARY_COLOR}];
}

- (UILabel *)leftLab {
    if (!_leftLab) {
        _leftLab = [[UILabel alloc] init];
        _leftLab.text = @"记账小目标";
        _leftLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _leftLab;
}

- (UILabel *)counter {
    if (!_counter) {
        _counter = [[UILabel alloc] init];
        _counter.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _counter;
}

- (UITextField *)signatureField {
    if (!_signatureField) {
        _signatureField = [[UITextField alloc] init];
        _signatureField.adjustsFontSizeToFitWidth = YES;
        _signatureField.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _signatureField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _signatureField;
}

@end
