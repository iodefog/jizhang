//
//  SSJMemberCell.m
//  SuiShouJi
//
//  Created by ricky on 16/7/20.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMemberCell.h"

@interface SSJMemberCell()

@property(nonatomic, strong) UILabel *titleLab;

@property(nonatomic, strong) UIImageView *addImage;

@end

@implementation SSJMemberCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.titleLab];
        [self.contentView addSubview:self.addImage];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
}

-(UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc]init];
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _titleLab;
}

-(UIImageView *)addImage{
    if (!_addImage) {
        _addImage = [[UIImageView alloc]init];

    }
    return _addImage;
}

-(void)setItem:(SSJChargeMemberItem *)item{
    _item = item;
    self.titleLab.text = _item.memberName;
    [self.titleLab sizeToFit];
    if ([_item.memberName isEqualToString:@"添加新成员"]) {
        _addImage.image = [[UIImage imageNamed:@"border_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_addImage sizeToFit];
        _addImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }else{
        _addImage.image = nil;
    }
    [self setNeedsLayout];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
