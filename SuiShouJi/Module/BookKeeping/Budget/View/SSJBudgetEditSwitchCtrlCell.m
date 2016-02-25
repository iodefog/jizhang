//
//  SSJBudgetSwitchCtrlCell.m
//  SuiShouJi
//
//  Created by old lang on 16/2/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetEditSwitchCtrlCell.h"

@interface SSJBudgetEditSwitchCtrlCell ()

@property (nonatomic, strong) UISwitch *switchCtrl;

@end

@implementation SSJBudgetEditSwitchCtrlCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.textLabel.font = [UIFont systemFontOfSize:18];
        self.textLabel.textColor = [UIColor lightGrayColor];
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:11];
        self.detailTextLabel.textColor = [UIColor ssj_colorWithHex:@"999999"];
        
        self.switchCtrl = [[UISwitch alloc] init];
        self.accessoryView = self.switchCtrl;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.left = self.detailTextLabel.left = 10;
    self.textLabel.centerY = self.contentView.height * 0.5;
    self.detailTextLabel.centerY = (self.contentView.height - self.textLabel.bottom) * 0.5;
}

@end
