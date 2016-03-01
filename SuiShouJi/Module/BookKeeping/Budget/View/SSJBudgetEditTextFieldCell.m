//
//  SSJBudgetEditTextFieldCell.m
//  SuiShouJi
//
//  Created by old lang on 16/2/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetEditTextFieldCell.h"

@interface SSJBudgetEditTextFieldCell ()

@property (nonatomic, strong) UITextField *textField;

@end

@implementation SSJBudgetEditTextFieldCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.textLabel.font = [UIFont systemFontOfSize:18];
        self.textLabel.textColor = [UIColor lightGrayColor];
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:11];
        self.detailTextLabel.textColor = [UIColor ssj_colorWithHex:@"999999"];
        
        self.textField = [[UITextField alloc] init];
        self.textField.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.textField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.left = self.detailTextLabel.left = 10;
    self.textLabel.centerY = self.contentView.height * 0.5;
    
    self.detailTextLabel.width = MIN(self.detailTextLabel.width, self.contentView.width - 20);
    self.detailTextLabel.centerY = self.contentView.height - (self.contentView.height - self.textLabel.bottom) * 0.5;
    
    self.textField.frame = CGRectMake(self.contentView.width * 0.5 - 10, 0, self.contentView.width * 0.5, self.contentView.height);
}

@end
