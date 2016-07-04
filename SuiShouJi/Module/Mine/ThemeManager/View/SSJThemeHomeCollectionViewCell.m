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

@interface SSJThemeHomeCollectionViewCell()
@property(nonatomic, strong) UIImageView *themeImage;
@property(nonatomic, strong) UILabel *themeTitleLabel;
@property(nonatomic, strong) UILabel *themeSizeLabel;
@property(nonatomic, strong) UILabel *themeStatusLabel;
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
        
        __weak typeof(self) weakSelf = self;
        _downloadHandler = ^(float progress) {
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
    if (self.item.themeStatus != 2) {
        self.themeStatusButton.hidden = NO;
        self.themeStatusLabel.hidden = YES;
    }else{
        self.themeStatusButton.hidden = YES;
        self.themeStatusLabel.hidden = NO;
    }
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
        _themeTitleLabel.font = [UIFont systemFontOfSize:16];
        _themeTitleLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
    }
    return _themeTitleLabel;
}

-(UILabel *)themeSizeLabel{
    if (!_themeSizeLabel) {
        _themeSizeLabel = [[UILabel alloc]init];
        _themeSizeLabel.font = [UIFont systemFontOfSize:13];
        _themeSizeLabel.textColor = [UIColor ssj_colorWithHex:@"929292"];
    }
    return _themeSizeLabel;
}

-(UILabel *)themeStatusLabel{
    if (!_themeStatusLabel) {
        _themeStatusLabel = [[UILabel alloc]init];
        _themeStatusLabel.font = [UIFont systemFontOfSize:13];
        _themeStatusLabel.textColor = [UIColor ssj_colorWithHex:@"929292"];
        _themeStatusLabel.text = @"使用中";
        [_themeStatusLabel sizeToFit];
    }
    return _themeStatusLabel;
}

-(SSJDownLoadProgressButton *)themeStatusButton{
    if (!_themeStatusButton) {
        _themeStatusButton = [[SSJDownLoadProgressButton alloc]initWithFrame:CGRectMake(0, 0, 57, 21)];
        _themeStatusButton.maskColor = @"#eb4a64";
        _themeStatusButton.layer.cornerRadius = 4.f;
        _themeStatusButton.layer.masksToBounds = YES;
        _themeStatusButton.layer.borderColor = [UIColor colorWithRed:235.f / 255 green:74.f / 255 blue:100.f / 255 alpha:0.5].CGColor;
        [_themeStatusButton.button setTitleColor:[UIColor ssj_colorWithHex:@"eb4a64"] forState:UIControlStateNormal];
        _themeStatusButton.button.titleLabel.font = [UIFont systemFontOfSize:13];
        _themeStatusButton.layer.borderWidth = 1.f;
        [_themeStatusButton.button addTarget:self action:@selector(statusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _themeStatusButton;
}

-(void)statusButtonClicked:(id)sender{
//    __weak typeof(self) weakSelf = self;
//    if([((UIButton *)sender).titleLabel.text isEqualToString:@"下载"]) {
        [((UIButton *)sender) setTitle:@"" forState:UIControlStateNormal];
        [[SSJThemeDownLoaderManger sharedInstance] downloadThemeWithID:self.item.themeId url:self.item.downLoadUrl success:^{
            
        } failure:^(NSError *error) {
            
        }];
        self.themeStatusButton.downloadMaskView.hidden = NO;
        [[SSJThemeDownLoaderManger sharedInstance] addProgressHandler:_downloadHandler forID:self.item.themeId];
//    }
}

-(void)setItem:(SSJThemeItem *)item{
    [[SSJThemeDownLoaderManger sharedInstance] removeProgressHandler:_downloadHandler forID:self.item.themeId];
    _item = item;
    if (![_item.themeId isEqualToString:@"0"]) {
        self.themeTitleLabel.text = _item.themeTitle;
        [self.themeTitleLabel sizeToFit];
        self.themeSizeLabel.hidden = NO;
        self.themeSizeLabel.text = _item.themeSize;
        [self.themeSizeLabel sizeToFit];
        if (_item.themeStatus == 0) {
            [self.themeStatusButton.button setTitle:@"下载" forState:UIControlStateNormal];
        }else if (_item.themeStatus == 1) {
            [self.themeStatusButton.button setTitle:@"启用" forState:UIControlStateNormal];
        }else if (_item.themeStatus == 2) {
            self.themeStatusLabel.text = @"使用中";
        }
        [self.themeImage sd_setImageWithURL:[NSURL URLWithString:_item.themeImageUrl] placeholderImage:[UIImage imageNamed:@"noneImage"]];
//        __weak typeof(self) weakSelf = self;
        if (self.item.isDownLoading) {
            self.themeStatusButton.downloadMaskView.hidden = NO;
            [[SSJThemeDownLoaderManger sharedInstance] addProgressHandler:_downloadHandler forID:self.item.themeId];
        }else{
//            self.themeStatusButton.downloadMaskView.hidden = YES;
        }
    }else{
        self.themeSizeLabel.hidden = YES;
        self.themeTitleLabel.text = _item.themeTitle;
        [self.themeTitleLabel sizeToFit];
        if (_item.themeStatus == 0) {
            [self.themeStatusButton.button setTitle:@"下载" forState:UIControlStateNormal];
        }else if (_item.themeStatus == 1) {
            [self.themeStatusButton.button setTitle:@"启用" forState:UIControlStateNormal];
        }else if (_item.themeStatus == 2) {
            self.themeStatusLabel.text = @"使用中";
        }
        self.themeImage.image = [UIImage imageNamed:@"defualtImage"];
    }
    [self setNeedsLayout];
}

@end
