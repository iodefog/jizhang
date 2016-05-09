//
//  SSJMineHomeTableViewHeader.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJMineHomeTableViewHeader.h"

@interface SSJMineHomeTableViewHeader()
@property (nonatomic, strong) SSJMineHeaderView *headPotraitImage;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property(nonatomic, strong) UILabel *checkInLevelLabel;
@property(nonatomic, strong) UIButton *checkInButton;
@property(nonatomic, strong) UIButton *syncButton;
@property(nonatomic, strong) UIView *horizontalSepertorLine;
@property(nonatomic, strong) UIView *verticalSepertorLine;
@end

@implementation SSJMineHomeTableViewHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:@"eb4a64"];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
}

-(SSJMineHeaderView *)headPotraitImage{
    if (!_headPotraitImage) {
        _headPotraitImage = [[SSJMineHeaderView alloc]init];
    }
    return _headPotraitImage;
}

-(UILabel *)nicknameLabel{
    if (!_nicknameLabel) {
        _nicknameLabel = [[UILabel alloc]init];
        _nicknameLabel.textColor = [UIColor whiteColor];
    }
    return _nicknameLabel;
}

-(UILabel *)checkInLevelLabel{
    if (!_checkInLevelLabel) {
        _checkInLevelLabel = [[UILabel alloc]init];
    }
    return _checkInLevelLabel;
}

-(UIButton *)checkInButton{
    if (!_checkInButton) {
        _checkInButton = [[UIButton alloc]init];
        [_checkInButton setTitle:@"签到" forState:UIControlStateNormal];
        [_checkInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _checkInButton;
}

-(UIButton *)syncButton{
    if (!_syncButton) {
        _syncButton = [[UIButton alloc]init];
        [_syncButton setTitle:@"云同步" forState:UIControlStateNormal];
        [_syncButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _syncButton;
}

- (void)loginButtonClicked:(id)sender {
    if (self.HeaderButtonClickedBlock) {
        self.HeaderButtonClickedBlock();
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
