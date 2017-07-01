//
//  SSJEncourageCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 2017/7/1.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJEncourageCell.h"

@interface SSJEncourageCell()

@property (nonatomic , strong) UILabel *detailLab;

@property (nonatomic,strong) UILabel *subdetailLab;

@property (nonatomic,strong) UIImageView *celldetailImage;

@end

@implementation SSJEncourageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.detailLab];
        [self.contentView addSubview:self.subdetailLab];
        [self.contentView addSubview:self.celldetailImage];
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
