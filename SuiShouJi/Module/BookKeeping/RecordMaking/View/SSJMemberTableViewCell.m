//
//  SSJMemberTableViewCell.m
//  SuiShouJi
//
//  Created by ricky on 16/10/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMemberTableViewCell.h"

@interface SSJMemberTableViewCell()

@property (nonatomic,strong) UILabel *memberIcon;

@property (nonatomic,strong) UILabel *titleLab;

@property (nonatomic,strong) UILabel *detailLab;

@property(nonatomic, strong) UIImageView *addImage;
@end

@implementation SSJMemberTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.memberIcon];
        [self.contentView addSubview:self.addImage];
        [self.contentView addSubview:self.titleLab];
        [self.contentView addSubview:self.detailLab];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.memberIcon.left = 10;
    self.memberIcon.centerY = self.height / 2;
    self.addImage.frame = self.memberIcon.frame;
    self.titleLab.left = self.memberIcon.right + 10;
    self.titleLab.centerY = self.height / 2;
    self.detailLab.right = self.contentView.width - 10;
    self.detailLab.centerY = self.height / 2;
}

- (UILabel *)memberIcon{
    if (!_memberIcon) {
        _memberIcon = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        _memberIcon.layer.cornerRadius = 15;
        _memberIcon.textAlignment = NSTextAlignmentCenter;
        _memberIcon.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    }
    return _memberIcon;
}

- (UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc]init];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _titleLab;
}

- (UILabel *)detailLab{
    if (!_detailLab) {
        _detailLab = [[UILabel alloc]init];
        _detailLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _detailLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _detailLab;
}

- (UIImageView *)addImage{
    if (!_addImage) {
        _addImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        _addImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _addImage;
}

- (void)setMemberItem:(SSJChargeMemberItem *)memberItem{
    _memberItem = memberItem;
    self.memberIcon.text = [_memberItem.memberName substringWithRange:NSMakeRange(0, 1)];
    self.memberIcon.textColor = [UIColor ssj_colorWithHex:_memberItem.memberColor];
    self.memberIcon.layer.borderColor = [UIColor ssj_colorWithHex:_memberItem.memberColor].CGColor;
    self.titleLab.text = memberItem.memberName;
    [self.titleLab sizeToFit];
    self.addImage.image = [memberItem.memberName isEqualToString:@"添加新成员"] ? [[UIImage imageNamed:@"border_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : nil;
    self.memberIcon.hidden = [memberItem.memberName isEqualToString:@"添加新成员"];
    if ([memberItem.memberId isEqualToString:[NSString stringWithFormat:@"%@-0",SSJUSERID()]]) {
        self.detailLab.text = @"默认";
    }else{
        self.detailLab.text = @"";
    }
    [self.detailLab sizeToFit];

}

- (void)setSelectable:(BOOL)selectable{
    _selectable = selectable;
    if (_selectable) {
        self.detailLab.hidden = YES;
    }else{
        self.detailLab.hidden = NO;
    }
}

- (void)updateCellAppearanceAfterThemeChanged{
    [super updateCellAppearanceAfterThemeChanged];
    self.titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.detailLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
