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
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.textLabel.font = [UIFont systemFontOfSize:18];
        self.textLabel.textColor = [UIColor lightGrayColor];
        
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
    
    self.textField.frame = CGRectMake(self.contentView.width * 0.5 - 10, 0, self.contentView.width * 0.5, self.contentView.height);
}

@end
