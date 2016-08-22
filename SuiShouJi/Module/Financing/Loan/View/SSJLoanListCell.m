//
//  SSJLoanListCell.m
//  SuiShouJi
//
//  Created by old lang on 16/8/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanListCell.h"

@interface SSJLoanListCell ()

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, strong) UILabel *subtitle;

@property (nonatomic, strong) UILabel *money;

@property (nonatomic, strong) UILabel *date;

@end

@implementation SSJLoanListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _icon = [[UIImageView alloc] init];
        [self.contentView addSubview:_icon];
        
        _title = [[UILabel alloc] init];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
