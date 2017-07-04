//
//  SSJCreditCardListCell.m
//  SuiShouJi
//
//  Created by ricky on 16/8/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReminderListCell.h"
#import "SSJReminderItem.h"

@interface SSJReminderListCell()

@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) UILabel *memoLabel;

@property(nonatomic, strong) UISwitch *switchButton;

@property(nonatomic, strong) UIImageView *cellImageView;

@end

@implementation SSJReminderListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.memoLabel];
        [self.contentView addSubview:self.cellImageView];
        self.accessoryView = self.switchButton;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.cellImageView.left = 10;
    self.cellImageView.centerY = self.height / 2;
    self.titleLabel.width = self.contentView.width - 30;
    self.titleLabel.left = self.cellImageView.right + 10;
    if (!((SSJReminderItem *)self.cellItem).remindMemo.length) {
        self.titleLabel.centerY = self.height / 2;
    }else{
        self.titleLabel.top = 15;
        self.memoLabel.left = self.titleLabel.left;
        self.memoLabel.top = self.titleLabel.bottom + 10;
    }

}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _titleLabel;
}

-(UILabel *)memoLabel{
    if (!_memoLabel) {
        _memoLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _memoLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _memoLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _memoLabel;
}

- (UISwitch *)switchButton{
    if (!_switchButton) {
        _switchButton = [[UISwitch alloc]init];
        _switchButton.onTintColor = [UIColor ssj_colorWithHex:@"43cf78"];
        [_switchButton addTarget:self action:@selector(switchControlAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchButton;
}

- (void)setCellItem:(SSJBaseCellItem *)cellItem{
    [super setCellItem:cellItem];
    if (![cellItem isKindOfClass:[SSJReminderItem class]]) {
        return;
    }
    SSJReminderItem *item = (SSJReminderItem *)cellItem;
    self.titleLabel.text = item.remindName;
    [self.titleLabel sizeToFit];
    self.memoLabel.text = item.remindMemo;
    [self.memoLabel sizeToFit];
    self.switchButton.on = item.remindState;
    if (item.remindType == SSJReminderTypeCreditCard) {
        self.cellImageView.image = [[UIImage imageNamed:@"ft_creditcard"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }else if(item.remindType == SSJReminderTypeBorrowing){
        if (!item.borrowtOrLend) {
            self.cellImageView.image = [[UIImage imageNamed:@"ft_qiankuan"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }else{
            self.cellImageView.image = [[UIImage imageNamed:@"ft_yingshouqian"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }else{
        self.cellImageView.image = [[UIImage imageNamed:@"loan_remind"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
}

- (void)switchControlAction:(UISwitch *)switchA {
//    SSJReminderItem *item = (SSJReminderItem *)self.cellItem;
//    item.remindState = self.switchButton.on;
    if (_switchAction) {
        _switchAction(self,switchA);
    }
}

- (void)updateCellAppearanceAfterThemeChanged{
    [super updateCellAppearanceAfterThemeChanged];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
