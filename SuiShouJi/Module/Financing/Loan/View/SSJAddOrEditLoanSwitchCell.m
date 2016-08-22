//
//  SSJAddOrEditLoanSwitchCell.m
//  SuiShouJi
//
//  Created by old lang on 16/8/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAddOrEditLoanSwitchCell.h"

@implementation SSJAddOrEditLoanSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _switchControl = [[UISwitch alloc] init];
        [self.contentView addSubview:_switchControl];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _switchControl.rightTop = CGPointMake(self.contentView.width - 28, (self.contentView.height - self.contentView.height) * 0.5);
}

@end
