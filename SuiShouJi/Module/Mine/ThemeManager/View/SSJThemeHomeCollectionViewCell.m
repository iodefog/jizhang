//
//  SSJThemeHomeCollectionViewCell.m
//  SuiShouJi
//
//  Created by ricky on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeHomeCollectionViewCell.h"
#import "SSJDownLoadProgressButton.h"
#import "SSJThemeDownLoaderManger.h"
#import "SSJThemeDownLoaderManger.h"
#import "SSJThemeDownLoadCompleteService.h"
#import "SSJNetworkReachabilityManager.h"

@interface SSJThemeHomeCollectionViewCell()
@property(nonatomic, strong) UIImageView *themeImage;
@property(nonatomic, strong) UILabel *themeTitleLabel;
@property(nonatomic, strong) UILabel *themeSizeLabel;
@property(nonatomic, strong) UILabel *themeStatusLabel;
@property(nonatomic, strong) UIImageView *addImageView;
@property(nonatomic, strong) SSJDownLoadProgressButton *themeStatusButton;

@property (nonatomic, copy) void (^downloadHandler)(float progress);

@end

@implementation SSJThemeHomeCollectionViewCell{
    float _cellHeight;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        NSMutableDictionary *progressDic = [SSJThemeDownLoaderManger sharedInstance].blockerMapping;
//        SSJThemeDownLoaderProgressBlocker *progressBlocker = progressDic[self.item.themeId];
//        if ([[SSJThemeDownLoaderManger sharedInstance].downLoadingArr containsObject:self.item.themeId]) {
//            __weak typeof(self) weakSelf = self;
//            [[SSJThemeDownLoaderManger sharedInstance] addProgressHandler:^(float progress) {
//                weakSelf.themeStatusButton.downloadProgress = progress;
//            } forID:self.item.themeId];
//        }
        [self.contentView addSubview:self.themeImage];
        [self.contentView addSubview:self.themeTitleLabel];
        [self.contentView addSubview:self.themeSizeLabel];
        [self.contentView addSubview:self.themeStatusLabel];
        [self.contentView addSubview:self.themeStatusButton];
        [self.contentView addSubview:self.addImageView];
        __weak typeof(self) weakSelf = self;
        _downloadHandler = ^(float progress) {
            if (progress == 1) {
                [weakSelf.themeStatusButton.button setTitle:@"启用" forState:UIControlStateNormal];
            }else{
                [weakSelf.themeStatusButton.button setTitle:@"" forState:UIControlStateNormal];
            }
            weakSelf.themeStatusButton.downloadProgress = progress;
        };
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    float imageRatio = 220.f / 358;
    self.themeImage.size = CGSizeMake(self.width, self.width / imageRatio);
    self.themeImage.leftTop = CGPointMake(0, 0);
    self.themeTitleLabel.leftTop = CGPointMake(5, self.themeImage.bottom + 15);
    self.themeSizeLabel.leftBottom = CGPointMake(self.themeTitleLabel.right + 10, self.themeTitleLabel.bottom);
    self.themeStatusLabel.leftTop = CGPointMake(self.themeTitleLabel.left, self.themeTitleLabel.bottom + 10);
    self.themeStatusButton.leftTop = self.themeStatusLabel.leftTop;
    if (![self.item.themeId isEqualToString:@"-1"]) {
        if (self.item.themeStatus != themeStatusInuse) {
            self.themeStatusButton.hidden = NO;
            self.themeStatusLabel.hidden = YES;
        }else{
            self.themeStatusButton.hidden = YES;
            self.themeStatusLabel.hidden = NO;
        }
    }
    self.addImageView.center = self.themeImage.center;
}

-(UIImageView *)themeImage{
    if (!_themeImage) {
        _themeImage = [[UIImageView alloc]init];
        _themeImage.layer.cornerRadius = 4.f;
        _themeImage.layer.masksToBounds = YES;
    }
    return _themeImage;
}

-(UILabel *)themeTitleLabel{
    if (!_themeTitleLabel) {
        _themeTitleLabel = [[UILabel alloc]init];
        _themeTitleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _themeTitleLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
    }
    return _themeTitleLabel;
}

-(UILabel *)themeSizeLabel{
    if (!_themeSizeLabel) {
        _themeSizeLabel = [[UILabel alloc]init];
        _themeSizeLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _themeSizeLabel.textColor = [UIColor ssj_colorWithHex:@"929292"];
    }
    return _themeSizeLabel;
}

-(UILabel *)themeStatusLabel{
    if (!_themeStatusLabel) {
        _themeStatusLabel = [[UILabel alloc]init];
        _themeStatusLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _themeStatusLabel.textColor = [UIColor ssj_colorWithHex:@"929292"];
        _themeStatusLabel.text = @"使用中";
        [_themeStatusLabel sizeToFit];
    }
    return _themeStatusLabel;
}

-(SSJDownLoadProgressButton *)themeStatusButton{
    if (!_themeStatusButton) {
        _themeStatusButton = [[SSJDownLoadProgressButton alloc]initWithFrame:CGRectMake(0, 0, 57, 21)];
        _themeStatusButton.maskColor = @"#EE4F4F";
        _themeStatusButton.layer.cornerRadius = 4.f;
        _themeStatusButton.layer.masksToBounds = YES;
        _themeStatusButton.layer.borderColor = [UIColor colorWithRed:235.f / 255 green:74.f / 255 blue:100.f / 255 alpha:0.5].CGColor;
        [_themeStatusButton.button setTitleColor:[UIColor ssj_colorWithHex:@"EE4F4F"] forState:UIControlStateNormal];
        _themeStatusButton.button.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _themeStatusButton.layer.borderWidth = 1.f;
        [_themeStatusButton.button addTarget:self action:@selector(statusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _themeStatusButton;
}

- (UIImageView *)addImageView {
    if (!_addImageView) {
        _addImageView = [[UIImageView alloc] init];
        _addImageView.image = [UIImage imageNamed:@"theme_customadd"];
        [_addImageView sizeToFit];
    }
    return _addImageView;
}

-(void)statusButtonClicked:(id)sender{
//    __weak typeof(self) weakSelf = self;
    if(([((UIButton *)sender).titleLabel.text isEqualToString:@"下载"] || [((UIButton *)sender).titleLabel.text isEqualToString:@"升级"]) && ![[SSJThemeDownLoaderManger sharedInstance].downLoadingArr containsObject:self.item.themeId]) {
        if ([SSJNetworkReachabilityManager networkReachabilityStatus] == SSJNetworkReachabilityStatusReachableViaWiFi) {
            [self downloadTheme];
        } else {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
            UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [((UIButton *)sender) setTitle:@"" forState:UIControlStateNormal];
                [self downloadTheme];
            }];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NULL message:[NSString stringWithFormat:@"您现在处于非WIFI网络状态，该皮肤将耗费%@流量，是否下载？",self.item.themeSize] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:cancelAction];
            [alert addAction:comfirmAction];
            [SSJVisibalController().navigationController presentViewController:alert animated:YES completion:NULL];
        }

    }else if ([((UIButton *)sender).titleLabel.text isEqualToString:@"启用"]){
        [SSJThemeSetting switchToThemeID:self.item.themeId];
        [SSJAnaliyticsManager event:@"open_skin" extra:self.item.themeTitle];
        if (self.themeChangeBlock) {
            self.themeChangeBlock();
        }
    }
}

-(void)setItem:(SSJThemeItem *)item{
    [[SSJThemeDownLoaderManger sharedInstance] removeProgressHandler:_downloadHandler forID:self.item.themeId];
    _item = item;
    if ([_item.themeId isEqualToString:@"0"]) {
        self.addImageView.hidden = YES;
        self.themeSizeLabel.hidden = YES;
        self.themeTitleLabel.text = _item.themeTitle;
        [self.themeTitleLabel sizeToFit];
        if (_item.themeStatus == themeStatusInuse) {
            self.themeStatusLabel.text = @"使用中";
        }else {
            [self.themeStatusButton.button setTitle:@"启用" forState:UIControlStateNormal];
        }
        self.themeImage.image = [UIImage imageNamed:@"theme_defualt"];
        self.themeStatusLabel.hidden = NO;
        self.themeStatusButton.hidden = NO;

    } else if ([_item.themeId isEqualToString:@"-1"]) {
        self.addImageView.hidden = NO;
        self.themeImage.image = [UIImage imageNamed:@"theme_custom"];
        self.themeTitleLabel.text = _item.themeTitle;
        [self.themeTitleLabel sizeToFit];
        self.themeSizeLabel.hidden = YES;
        self.themeStatusLabel.hidden = YES;
        self.themeStatusButton.hidden = YES;
    } else {
        self.addImageView.hidden = YES;
        self.themeTitleLabel.text = _item.themeTitle;
        [self.themeTitleLabel sizeToFit];
        self.themeSizeLabel.hidden = NO;
        self.themeSizeLabel.text = _item.themeSize;
        [self.themeSizeLabel sizeToFit];
        if (_item.themeStatus == themeStatusNotDownloaded) {
            [self.themeStatusButton.button setTitle:@"下载" forState:UIControlStateNormal];
        }else if (_item.themeStatus == themeStatusHaveDownloaded) {
            [self.themeStatusButton.button setTitle:@"启用" forState:UIControlStateNormal];
        }else if (_item.themeStatus == themeStatusInuse) {
            self.themeStatusLabel.text = @"使用中";
            self.themeStatusButton.hidden = YES;
        }else if (_item.themeStatus == themeStatusNeedToUpdate) {
            [self.themeStatusButton.button setTitle:@"升级" forState:UIControlStateNormal];
        }
        [self.themeImage sd_setImageWithURL:[NSURL URLWithString:_item.themeImageUrl] placeholderImage:[UIImage imageNamed:@"noneImage"]];
        //        __weak typeof(self) weakSelf = self;
        if (self.item.isDownLoading) {
            [self.themeStatusButton.button setTitle:@"" forState:UIControlStateNormal];
            self.themeStatusButton.downloadMaskView.hidden = NO;
            [[SSJThemeDownLoaderManger sharedInstance] addProgressHandler:_downloadHandler forID:self.item.themeId];
        }else{
            self.themeStatusButton.downloadMaskView.hidden = YES;
        }
        self.themeStatusLabel.hidden = NO;
        self.themeStatusButton.hidden = NO;
    }
    [self setNeedsLayout];
}

- (void)downloadTheme {
    __weak typeof(self) weakSelf = self;
    [[SSJThemeDownLoaderManger sharedInstance] downloadThemeWithItem:self.item success:^(SSJThemeItem *item){
        [SSJThemeSetting switchToThemeID:item.themeId];
        [SSJAnaliyticsManager event:@"download_skin" extra:item.themeTitle];
        [SSJAnaliyticsManager event:@"open_skin" extra:item.themeTitle];
        SSJThemeDownLoadCompleteService *downloadCompleteService = [[SSJThemeDownLoadCompleteService alloc]initWithDelegate:nil];
        [downloadCompleteService downloadCompleteThemeWithThemeId:item.themeId];
        if (weakSelf.themeChangeBlock) {
            weakSelf.themeChangeBlock();
        }
    } failure:^(NSError *error) {
        [CDAutoHideMessageHUD showMessage:@"下载失败"];
        [weakSelf.themeStatusButton.button setTitle:@"下载" forState:UIControlStateNormal];
    }];
    self.themeStatusButton.downloadMaskView.hidden = NO;
    [[SSJThemeDownLoaderManger sharedInstance] addProgressHandler:_downloadHandler forID:self.item.themeId];
}

@end
