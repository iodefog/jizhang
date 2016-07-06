//
//  SSJBaseTableViewCell.m
//  MoneyMore
//
//  Created by old lang on 15-3-23.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@implementation SSJBaseTableViewCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
    return 48;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [self setPreservesSuperviewLayoutMargins:NO];
        }
        
        if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
            [self setLayoutMargins:UIEdgeInsetsZero];
        }
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
