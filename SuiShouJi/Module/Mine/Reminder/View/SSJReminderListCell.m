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

@property(nonatomic, strong) UISwitch *switchButton;

@end

@implementation SSJReminderListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        self.accessoryView = self.switchButton;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.left = 10;
    self.titleLabel.centerY = self.height / 2;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _titleLabel;
}

- (UISwitch *)switchButton{
    if (!_switchButton) {
        _switchButton = [[UISwitch alloc]init];
        _switchButton.onTintColor = [UIColor ssj_colorWithHex:@"43cf78"];
    }
    return _switchButton;
}

- (void)setCellItem:(SSJBaseItem *)cellItem{
    [super setCellItem:cellItem];
    if (![cellItem isKindOfClass:[SSJReminderItem class]]) {
        return;
    }
    SSJReminderItem *item = (SSJReminderItem *)cellItem;
    self.titleLabel.text = item.remindName;
    [self.titleLabel sizeToFit];
    self.switchButton.on = item.remindState;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
