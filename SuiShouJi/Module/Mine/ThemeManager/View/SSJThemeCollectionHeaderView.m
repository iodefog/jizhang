//
//  SSJThemeCollectionHeaderView.m
//  SuiShouJi
//
//  Created by ricky on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeCollectionHeaderView.h"

@interface SSJThemeCollectionHeaderView()
@property(nonatomic, strong) UILabel *titleLabel;
@end

@implementation SSJThemeCollectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.frame = self.bounds;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        [_titleLabel ssj_setBorderStyle:SSJBorderStyleTop | SSJBorderStyleBottom];
        [_titleLabel ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
        _titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
    }
    return _titleLabel;
}

-(void)setTitle:(NSString *)title{
    _title = title;
    self.titleLabel.text = [NSString stringWithFormat:@"  %@",_title];
}

@end
