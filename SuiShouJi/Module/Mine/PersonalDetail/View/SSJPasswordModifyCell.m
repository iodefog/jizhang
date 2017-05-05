//
//  SSJPasswordModifyCell.m
//  SuiShouJi
//
//  Created by ricky on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJPasswordModifyCell.h"

@implementation SSJPasswordModifyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.passwordInput];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.passwordInput.frame = self.contentView.frame;
}

-(UITextField *)passwordInput{
    if (!_passwordInput) {
        _passwordInput = [[UITextField alloc]init];
        _passwordInput.secureTextEntry = YES;
        _passwordInput.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
        _passwordInput.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [_passwordInput ssj_setBorderStyle:SSJBorderStyleBottom];
        [_passwordInput ssj_setBorderWidth:1.f / [UIScreen mainScreen].scale];
        UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, self.contentView.height)];
        _passwordInput.leftView = leftView;
        _passwordInput.leftViewMode = UITextFieldViewModeAlways;
        [_passwordInput ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
        
    }
    return _passwordInput;
}


@end
