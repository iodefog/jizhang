//
//  SSJMineHomeTabelviewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJMineHomeTabelviewCell.h"

@interface SSJMineHomeTabelviewCell()
@property (nonatomic,strong) UILabel *titleLabel;
@end

@implementation SSJMineHomeTabelviewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.titleLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.left = 10;
    self.titleLabel.centerY = self.height / 2;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
    }
    return _titleLabel;
}

-(void)setCellTitle:(NSString *)cellTitle{
    _cellTitle = cellTitle;
    _titleLabel.text = _cellTitle;
    [_titleLabel sizeToFit];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
