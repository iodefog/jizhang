//
//  SSJFinancingHomeAddCell.m
//  SuiShouJi
//
//  Created by ricky on 16/5/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFinancingHomeAddCell.h"

@interface SSJFinancingHomeAddCell()
@property(nonatomic, strong) UIImageView *backImage;
@property(nonatomic, strong) UIImageView *addImage;
@property(nonatomic, strong) UILabel *addLabel;
@end
@implementation SSJFinancingHomeAddCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 3.f;
        [self.contentView addSubview:self.backImage];
        [self.contentView addSubview:self.addImage];
        [self.contentView addSubview:self.addLabel];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChange) name:SSJThemeDidChangeNotification object:nil];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.backImage.frame = self.bounds;
    self.addImage.size = CGSizeMake(13, 13);
    self.addImage.centerY = self.height / 2;
    self.addImage.right = self.width / 2 - 40;
    self.addLabel.centerY = self.height / 2;
    self.addLabel.left = self.addImage.right + 10;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(UIImageView *)backImage{
    if (!_backImage) {
        _backImage = [[UIImageView alloc]init];
        _backImage.image = [[UIImage imageNamed:@"tianjia_border"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _backImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _backImage;
}

-(UIImageView *)addImage{
    if (!_addImage) {
        _addImage = [[UIImageView alloc]init];
        _addImage.image = [[UIImage imageNamed:@"add"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _addImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _addImage;
}

-(UILabel *)addLabel{
    if (!_addLabel) {
        _addLabel = [[UILabel alloc]init];
        _addLabel.font = [UIFont systemFontOfSize:18];
        _addLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _addLabel.text = @"添加资金帐户";
        [_addLabel sizeToFit];
    }
    return _addLabel;
}

-(void)themeChange{
    self.addLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.addImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.backImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

@end
