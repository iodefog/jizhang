
//
//  SSJCanlenderChargeDetailCell.m
//  SuiShouJi
//
//  Created by ricky on 16/8/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCanlenderChargeDetailCell.h"

@interface SSJCanlenderChargeDetailCell()
@property(nonatomic, strong) UILabel *dateLab;
@property(nonatomic, strong) UILabel *fundLab;
@property(nonatomic, strong) UILabel *booksLab;
@end

@implementation SSJCanlenderChargeDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {

    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
