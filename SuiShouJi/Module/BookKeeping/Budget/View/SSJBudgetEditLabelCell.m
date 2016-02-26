//
//  SSJBudgetEditLabelCell.m
//  SuiShouJi
//
//  Created by old lang on 16/2/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetEditLabelCell.h"

@interface SSJBudgetEditLabelCell ()

@property (nonatomic, strong) UILabel *subtitleLab;

@end

@implementation SSJBudgetEditLabelCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        
        self.textLabel.font = [UIFont systemFontOfSize:18];
        self.textLabel.textColor = [UIColor lightGrayColor];
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:11];
        self.detailTextLabel.textColor = [UIColor ssj_colorWithHex:@"999999"];
        
        self.subtitleLab = [[UILabel alloc] init];
        self.subtitleLab.backgroundColor = [UIColor whiteColor];
        self.subtitleLab.font = [UIFont systemFontOfSize:18];
        self.subtitleLab.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.subtitleLab];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.left = self.detailTextLabel.left = 10;
    self.textLabel.centerY = self.contentView.height * 0.5;
    self.detailTextLabel.centerY = self.contentView.height - (self.contentView.height - self.textLabel.bottom) * 0.5;
    if (self.accessoryType == UITableViewCellAccessoryNone) {
        self.subtitleLab.frame = CGRectMake(self.textLabel.right + 20, 0, self.contentView.width - self.textLabel.right - 30, self.contentView.height);
    } else {
        self.subtitleLab.frame = CGRectMake(self.textLabel.right + 20, 0, self.contentView.width - self.textLabel.right - 20, self.contentView.height);
    }
}

@end
