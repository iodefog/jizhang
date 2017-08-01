//
//  SSJBooksParentSelectCell.m
//  SuiShouJi
//
//  Created by ricky on 16/11/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBooksParentSelectCell.h"

@implementation SSJBooksParentSelectCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.arrowImageView];
        self.textLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        self.textLabel.backgroundColor = [UIColor clearColor];
        [self themeUpdate];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeUpdate) name:SSJThemeDidChangeNotification object:nil];
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    self.arrowImageView.right = self.width - 20;
    self.arrowImageView.centerY = self.height * 0.5;
}
- (UIImageView *)arrowImageView{
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"bk_selectedParentBook_mark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    }
    return _arrowImageView;
}

- (void)setImage:(NSString *)imageName title:(NSString *)title {
    self.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.textLabel.text = title;
}

- (void)themeUpdate {
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    self.imageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.arrowImageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
}

@end
