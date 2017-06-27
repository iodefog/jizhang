//
//  SSJMineHomeTableViewHeader.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJMineHomeTableViewHeader.h"
#import "SSJMineSyncButton.h"
#import "SSJUserItem.h"
#import "SSJUserTableManager.h"
#define kTopViewHeight 125
#define kBottomViewHeight 45

@interface SSJMineHomeTableViewHeader()
@property (nonatomic, strong) UIImageView *headPotraitImage;
@property (nonatomic, strong) UILabel *nicknameLabel;
@property(nonatomic, strong) UILabel *checkInLevelLabel;
@property(nonatomic, strong) UIButton *checkInButton;
@property(nonatomic, strong) UILabel *geXingSignLabel;
@property(nonatomic, strong) UIView *verticalSepertorLine;
//@property(nonatomic, strong) UIImageView *backImage;
@property(nonatomic, strong) UIButton *loginButton;
@property(nonatomic, strong) SSJMineSyncButton *syncButton;
@property (nonatomic, strong) UIImageView *dengjiImage;

@end

@implementation SSJMineHomeTableViewHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.headPotraitImage];
        [self addSubview:self.nicknameLabel];
        [self addSubview:self.geXingSignLabel];
        [self addSubview:self.checkInLevelLabel];
        [self addSubview:self.syncButton];
        [self addSubview:self.checkInButton];
        [self addSubview:self.verticalSepertorLine];
        [self addSubview:self.loginButton];
        [self addSubview:self.dengjiImage];
            self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self ssj_setBorderStyle:SSJBorderStyleBottom];
        [self ssj_setBorderWidth:1.f];
        [self ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        
#ifdef PRODUCTION
#else
        UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, 30)];
        testLabel.text = @"当前是测试环境";
        testLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.moreHomeTitleColor];
        testLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:testLabel];
#endif

    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
//    self.backImage.frame = self.bounds;
    self.loginButton.size = CGSizeMake(self.width, self.height - kBottomViewHeight);
    self.loginButton.leftTop = CGPointMake(0, 0);
    self.headPotraitImage.size = CGSizeMake(64, 64);
    self.headPotraitImage.left = 20;
    self.headPotraitImage.centerY = (self.height - kBottomViewHeight) * 0.5;
    self.nicknameLabel.top = self.headPotraitImage.top + 15;
    self.nicknameLabel.left = self.geXingSignLabel.left = CGRectGetMaxX(self.headPotraitImage.frame) + 10;
    self.geXingSignLabel.top = CGRectGetMaxY(self.nicknameLabel.frame);
    self.geXingSignLabel.size = CGSizeMake(self.width - CGRectGetMinX(self.geXingSignLabel.frame), 21);
    self.dengjiImage.left = CGRectGetMaxX(self.nicknameLabel.frame) + 10;
    self.dengjiImage.centerY = self.nicknameLabel.centerY;
    self.syncButton.size = CGSizeMake(self.width / 2 , kBottomViewHeight);
    self.syncButton.leftBottom = CGPointMake(0, self.height);
    self.checkInButton.size = CGSizeMake(self.width / 2 , kBottomViewHeight);
    self.checkInButton.rightBottom = CGPointMake(self.width, self.height);
    self.verticalSepertorLine.centerX = self.width / 2;
    self.verticalSepertorLine.centerY = self.height - 23;
}

- (void)setShouldSyncBlock:(BOOL (^)())shouldSyncBlock {
    self.syncButton.shouldSyncBlock = shouldSyncBlock;
}

-(UIImageView *)headPotraitImage{
    if (!_headPotraitImage) {
        _headPotraitImage = [[UIImageView alloc]init];
        CGRect rect = CGRectMake(0, 0, 64, 64);
        CAShapeLayer *imagLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:rect.size.width * 0.5];
        imagLayer.path = path.CGPath;
        _headPotraitImage.layer.mask = imagLayer;
    }
    return _headPotraitImage;
}

- (UILabel *)nicknameLabel{
    if (!_nicknameLabel) {
        _nicknameLabel = [[UILabel alloc]init];
        _nicknameLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.moreHomeTitleColor];
        _nicknameLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _nicknameLabel;
}

- (UILabel *)geXingSignLabel{
    if (!_geXingSignLabel) {
        _geXingSignLabel = [[UILabel alloc] init];
        _geXingSignLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.moreHomeSubtitleColor];
        _geXingSignLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _geXingSignLabel;
}



-(UILabel *)checkInLevelLabel{
    if (!_checkInLevelLabel) {
        _checkInLevelLabel = [[UILabel alloc]init];
        _checkInLevelLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _checkInLevelLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.moreHomeSubtitleColor];
    }
    return _checkInLevelLabel;
}

-(UIButton *)checkInButton{
    if (!_checkInButton) {
        _checkInButton = [[UIButton alloc]init];
        [_checkInButton setTitle:@"签到" forState:UIControlStateNormal];
        [_checkInButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.moreHomeTitleColor] forState:UIControlStateNormal];
        [_checkInButton setImage:[[UIImage imageNamed:@"more_qiandao"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _checkInButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.moreHomeTitleColor];
        _checkInButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [_checkInButton ssj_setBorderStyle:SSJBorderStyleTop];
        [_checkInButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        [_checkInButton ssj_setBorderWidth:1.f / [UIScreen mainScreen].scale];
        [_checkInButton setSpaceBetweenImageAndTitle:12];
        [_checkInButton addTarget:self action:@selector(checkInButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkInButton;
}

-(SSJMineSyncButton *)syncButton{
    if (!_syncButton) {
        _syncButton = [[SSJMineSyncButton alloc]init];
        [_syncButton ssj_setBorderStyle:SSJBorderStyleTop];
        [_syncButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
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

//-(UIImageView *)backImage{
//    if (!_backImage) {
//        _backImage = [[UIImageView alloc]init];
//        _backImage.image = [UIImage imageNamed:@"more_bg"];
//    }
//    return _backImage;
//}

-(UIView *)verticalSepertorLine{
    if (!_verticalSepertorLine) {
        _verticalSepertorLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1.f / [UIScreen mainScreen].scale, 30)];
        _verticalSepertorLine.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    }
    return _verticalSepertorLine;
}

- (UIImageView *)dengjiImage
{
    if (!_dengjiImage) {
        _dengjiImage = [[UIImageView alloc] init];
    }
    return _dengjiImage;
}


#pragma mark Setter
-(void)setItem:(SSJUserItem *)item{
    _item = item;
    if (SSJIsUserLogined()) {
        NSString *iconStr;
        if ([item.icon hasPrefix:@"http"]) {
            iconStr = item.icon;
        }else{
            iconStr = SSJImageURLWithAPI(item.icon);
        }
        if (item.nickName == nil || [item.nickName isEqualToString:@""]) {
            //手机号登陆
            if (item.mobileNo.length == 11) {
                NSString *phoneNum = [item.mobileNo stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                self.nicknameLabel.text = phoneNum;
            }
        }else{
            //三方登录
            self.nicknameLabel.text = item.nickName;
        }
        [self.headPotraitImage sd_setImageWithURL:[NSURL URLWithString:iconStr] placeholderImage:[UIImage imageNamed:@"defualt_portrait"]];

        [self.nicknameLabel sizeToFit];
    } else {
        self.headPotraitImage.image = [UIImage imageNamed:@"defualt_portrait"];
        self.nicknameLabel.text = @"待君登录";
        [self.nicknameLabel sizeToFit];
    }

}

- (void)setSignStr
{
    [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
        if (userItem.signature.length < 1 || userItem.signature == nil) {
            _geXingSignLabel.text = @"";
            self.nicknameLabel.centerY = self.headPotraitImage.centerY;
        }else{
            _geXingSignLabel.text = userItem.signature;
            self.nicknameLabel.top = self.headPotraitImage.top + 15;
        }
        self.dengjiImage.centerY = self.nicknameLabel.centerY;
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

-(void)setCheckInLevel:(SSJBookkeepingTreeLevel)checkInLevel{
    _checkInLevel = checkInLevel;
    
    UIImage *levelImage;
    switch (_checkInLevel) {
        case SSJBookkeepingTreeLevelSeed:
//            levelStr = @"种子";
            
            levelImage = [UIImage ssj_themeImageWithName:@"more_zhognzi"];
            break;
        case SSJBookkeepingTreeLevelSapling:
//            levelStr = @"树苗";
            levelImage = [UIImage ssj_themeImageWithName:@"more_shumiao"];
            break;
        case SSJBookkeepingTreeLevelSmallTree:
//            levelStr = @"小树";
            levelImage = [UIImage ssj_themeImageWithName:@"more_xiaoshu"];
            break;
        case SSJBookkeepingTreeLevelStrongTree:
//            levelStr = @"壮树";
            levelImage = [UIImage ssj_themeImageWithName:@"more_zhuangshu"];
            break;
        case SSJBookkeepingTreeLevelBigTree:
//            levelStr = @"大树";
            levelImage = [UIImage ssj_themeImageWithName:@"more_dashu"];
            break;
        case SSJBookkeepingTreeLevelSilveryTree:
//            levelStr = @"银树";
            levelImage = [UIImage ssj_themeImageWithName:@"more_yinshu"];
            break;
        case SSJBookkeepingTreeLevelGoldTree:
//            levelStr = @"金树";
            levelImage = [UIImage ssj_themeImageWithName:@"more_jinshu"];
            break;
        case SSJBookkeepingTreeLevelDiamondTree:
//            levelStr = @"钻石树";
            levelImage = [UIImage ssj_themeImageWithName:@"more_zuanshizhu"];
            break;
        case SSJBookkeepingTreeLevelCrownTree:
//            levelStr = @"皇冠树";
            levelImage = [UIImage ssj_themeImageWithName:@"more_huangguanshu"];
            break;
        default:
            break;
    }
//    self.checkInLevelLabel.text = [NSString stringWithFormat:@"等级: %@",levelStr];
    self.dengjiImage.image = levelImage;
    [self.dengjiImage sizeToFit];
}

- (void)loginButtonClicked:(id)sender {
    if (self.HeaderClickedBlock) {
        self.HeaderClickedBlock();
    }
}

- (void)checkInButtonClicked:(id)sender{
    [SSJAnaliyticsManager event:@"account_tree"];
    if (self.checkInButtonClickBlock) {
        self.checkInButtonClickBlock();
    }
}

- (void)syncButtonClicked:(id)sender{
    [SSJAnaliyticsManager event:@"account_sync"];
}

- (void)updateAfterThemeChange{
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    [self ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    [self.checkInButton ssj_setBorderWidth:1.f / [UIScreen mainScreen].scale];
    [self.syncButton ssj_setBorderWidth:1.f / [UIScreen mainScreen].scale];
    self.geXingSignLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.moreHomeSubtitleColor];
    self.nicknameLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.moreHomeTitleColor];
    self.checkInLevelLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.moreHomeSubtitleColor];  
    self.verticalSepertorLine.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    [self.checkInButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.moreHomeTitleColor] forState:UIControlStateNormal];
    self.checkInButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.moreHomeTitleColor];
    [self.checkInButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    [self.syncButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    [self.syncButton updateAfterThemeChange];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
