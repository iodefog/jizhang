//
//  SSJMineHomeTableViewHeader.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJMineHomeTableViewHeader.h"
#import "SSJMineSyncButton.h"



@interface SSJMineHomeTableViewHeader()
@property (nonatomic, strong) SSJMineHeaderView *headPotraitImage;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property(nonatomic, strong) UILabel *checkInLevelLabel;
@property(nonatomic, strong) UIButton *checkInButton;
//@property(nonatomic, strong) UIButton *syncButton;
@property(nonatomic, strong) UIView *verticalSepertorLine;
@property(nonatomic, strong) UIImageView *backImage;
@property(nonatomic, strong) UIButton *loginButton;
@property(nonatomic, strong) SSJMineSyncButton *syncButton;
@end

@implementation SSJMineHomeTableViewHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.backImage];
        [self addSubview:self.headPotraitImage];
        [self addSubview:self.nicknameLabel];
        [self addSubview:self.checkInLevelLabel];
        [self addSubview:self.syncButton];
        [self addSubview:self.checkInButton];
        [self addSubview:self.verticalSepertorLine];
        [self addSubview:self.loginButton];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.backImage.frame = self.bounds;
    self.loginButton.size = CGSizeMake(self.width, self.height - 50);
    self.loginButton.leftTop = CGPointMake(0, 0);
    self.headPotraitImage.size = CGSizeMake(64, 64);
    self.headPotraitImage.centerY = (self.height - 50) / 2;
    self.headPotraitImage.left = 10;
    self.nicknameLabel.bottom = (self.height - 50) / 2 - 2;
    self.nicknameLabel.left = self.headPotraitImage.right + 10;
    self.checkInLevelLabel.top = (self.height - 50) / 2 + 2;
    self.checkInLevelLabel.left = self.headPotraitImage.right + 10;
    self.syncButton.size = CGSizeMake(self.width / 2 , 50);
    self.syncButton.leftBottom = CGPointMake(0, self.height);
    [self.syncButton ssj_relayoutBorder];
    self.checkInButton.size = CGSizeMake(self.width / 2 , 50);
    self.checkInButton.rightBottom = CGPointMake(self.width, self.height);
    [self.checkInButton ssj_relayoutBorder];
    self.verticalSepertorLine.centerX = self.width / 2;
    self.verticalSepertorLine.centerY = self.height - 25;
}

-(SSJMineHeaderView *)headPotraitImage{
    if (!_headPotraitImage) {
        _headPotraitImage = [[SSJMineHeaderView alloc]init];
        _headPotraitImage.layer.cornerRadius = 32;
    }
    return _headPotraitImage;
}

-(UILabel *)nicknameLabel{
    if (!_nicknameLabel) {
        _nicknameLabel = [[UILabel alloc]init];
        _nicknameLabel.textColor = [UIColor whiteColor];
        _nicknameLabel.font = [UIFont systemFontOfSize:18];
    }
    return _nicknameLabel;
}

-(UILabel *)checkInLevelLabel{
    if (!_checkInLevelLabel) {
        _checkInLevelLabel = [[UILabel alloc]init];
        _checkInLevelLabel.font = [UIFont systemFontOfSize:13];
        _checkInLevelLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    }
    return _checkInLevelLabel;
}

-(UIButton *)checkInButton{
    if (!_checkInButton) {
        _checkInButton = [[UIButton alloc]init];
        [_checkInButton setTitle:@"签到" forState:UIControlStateNormal];
        [_checkInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_checkInButton setImage:[UIImage imageNamed:@"more_qiandao"] forState:UIControlStateNormal];
        _checkInButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_checkInButton ssj_setBorderStyle:SSJBorderStyleTop];
        [_checkInButton ssj_setBorderColor:[UIColor whiteColor]];
        [_checkInButton ssj_setBorderWidth:1.f / [UIScreen mainScreen].scale];
        [_checkInButton addTarget:self action:@selector(checkInButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkInButton;
}

-(SSJMineSyncButton *)syncButton{
    if (!_syncButton) {
        _syncButton = [[SSJMineSyncButton alloc]init];
        [_syncButton ssj_setBorderStyle:SSJBorderStyleTop];
        [_syncButton ssj_setBorderColor:[UIColor whiteColor]];
        [_syncButton ssj_setBorderWidth:1.f / [UIScreen mainScreen].scale];
    }
    return _syncButton;
}

-(UIButton *)loginButton{
    if (!_loginButton) {
        _loginButton = [[UIButton alloc]init];
        [_loginButton addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

-(UIImageView *)backImage{
    if (!_backImage) {
        _backImage = [[UIImageView alloc]init];
        _backImage.image = [UIImage imageNamed:@"more_bg"];
    }
    return _backImage;
}

-(UIView *)verticalSepertorLine{
    if (!_verticalSepertorLine) {
        _verticalSepertorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1.f / [UIScreen mainScreen].scale, 30)];
        _verticalSepertorLine.backgroundColor = SSJ_DEFAULT_SEPARATOR_COLOR;
    }
    return _verticalSepertorLine;
}

-(void)setItem:(SSJUserInfoItem *)item{
    _item = item;
    if (SSJIsUserLogined()) {
        NSString *iconStr;
        if ([item.cicon hasPrefix:@"http"]) {
            iconStr = item.cicon;
        }else{
            iconStr = SSJImageURLWithAPI(item.cicon);
        }
        if (item.realName == nil || [item.realName isEqualToString:@""]) {
            //手机号登陆
            NSString *phoneNum = [item.cmobileno stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
            self.nicknameLabel.text = phoneNum;
        }else{
            //三方登录
            self.nicknameLabel.text = item.realName;
        }
        [self.headPotraitImage.headerImage sd_setImageWithURL:[NSURL URLWithString:iconStr] placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];
        [self.nicknameLabel sizeToFit];
    } else {
        self.headPotraitImage.headerImage.image = [UIImage imageNamed:@"defualt_portrait"];
        self.nicknameLabel.text = @"待君登录";
        [self.nicknameLabel sizeToFit];
    }

}

-(void)setCheckInLevel:(SSJBookkeepingTreeLevel)checkInLevel{
    _checkInLevel = checkInLevel;
    NSString *levelStr;
    switch (_checkInLevel) {
        case SSJBookkeepingTreeLevelSeed:
            levelStr = @"种子";
            break;
        case SSJBookkeepingTreeLevelSapling:
            levelStr = @"树苗";
            break;
        case SSJBookkeepingTreeLevelSmallTree:
            levelStr = @"小树";
            break;
        case SSJBookkeepingTreeLevelStrongTree:
            levelStr = @"壮树";
            break;
        case SSJBookkeepingTreeLevelBigTree:
            levelStr = @"大树";
            break;
        case SSJBookkeepingTreeLevelSilveryTree:
            levelStr = @"银树";
            break;
        case SSJBookkeepingTreeLevelGoldTree:
            levelStr = @"金树";
            break;
        case SSJBookkeepingTreeLevelDiamondTree:
            levelStr = @"钻石树";
            break;
        case SSJBookkeepingTreeLevelCrownTree:
            levelStr = @"皇冠树";
            break;
        default:
            break;
    }
    self.checkInLevelLabel.text = [NSString stringWithFormat:@"等级: %@",levelStr];
    [self.checkInLevelLabel sizeToFit];
}

- (void)loginButtonClicked:(id)sender {
    if (self.HeaderClickedBlock) {
        self.HeaderClickedBlock();
    }
}

- (void)checkInButtonClicked:(id)sender{
    if (self.checkInButtonClickBlock) {
        self.checkInButtonClickBlock();
    }
}

- (void)syncButtonClicked:(id)sender{
    if (self.syncButtonClickBlock) {
        self.syncButtonClickBlock();
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
