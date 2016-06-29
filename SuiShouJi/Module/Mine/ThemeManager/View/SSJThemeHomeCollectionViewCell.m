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
@end

@implementation SSJThemeHomeCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
<<<<<<< HEAD
=======
//        NSMutableDictionary *progressDic = [SSJThemeDownLoaderManger sharedInstance].blockerMapping;
//        SSJThemeDownLoaderProgressBlocker *progressBlocker = progressDic[self.item.themeId];
>>>>>>> 0d611efb9c2357b7d30dd7f11a9ee47efa241c5f
        [self.contentView addSubview:self.themeImage];
        [self.contentView addSubview:self.themeTitleLabel];
        [self.contentView addSubview:self.themeSizeLabel];
        [self.contentView addSubview:self.themeStatusLabel];
        [self.contentView addSubview:self.themeStatusButton];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.themeImage.image = [UIImage ssj_imageWithColor:[UIColor redColor] size:CGSizeMake(self.width, 179)];
    self.themeImage.size = CGSizeMake(self.width, 179);
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
        _themeStatusButton.layer.borderColor = [UIColor colorWithRed:235.f / 255 green:74.f / 255 blue:100.f / 255 alpha:0.5].CGColor;
        [_themeStatusButton setTitleColor:[UIColor ssj_colorWithHex:@"eb4a64"] forState:UIControlStateNormal];
        _themeStatusButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _themeStatusButton.layer.borderWidth = 1.f;
        [_themeStatusButton addTarget:self action:@selector(statusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _themeStatusButton;
}

-(void)statusButtonClicked:(id)sender{
    if([((UIButton *)sender).titleLabel.text isEqualToString:@"下载"]) {
        [((UIButton *)sender) setTitle:@"" forState:UIControlStateNormal];
        [[SSJThemeDownLoaderManger sharedInstance] downloadThemeWithID:self.item.themeId url:self.item.downLoadUrl success:^{
            
        } failure:^(NSError *error) {
            
        }];
    }
}

-(void)setItem:(SSJThemeItem *)item{
    _item = item;
    self.themeTitleLabel.text = _item.themeTitle;
    [self.themeTitleLabel sizeToFit];
    self.themeSizeLabel.text = _item.themeSize;
    [self.themeSizeLabel sizeToFit];
    if (_item.themeStatus == 0) {
        [self.themeStatusButton setTitle:@"下载" forState:UIControlStateNormal];
    }else if (_item.themeStatus == 1) {
        [self.themeStatusButton setTitle:@"启用" forState:UIControlStateNormal];
    }else if (_item.themeStatus == 2) {
        self.themeStatusLabel.text = @"使用中";
    }
    [self.themeImage sd_setImageWithURL:[NSURL URLWithString:_item.themeImageUrl]];
    [self addProgressObserver];
    [self setNeedsLayout];
}

-(void)addProgressObserver{
    NSMutableDictionary *progressDic = [SSJThemeDownLoaderManger sharedInstance].blockerMapping;
    SSJThemeDownLoaderProgressBlocker *progressBlocker = progressDic[self.item.themeId];
    [@(progressBlocker.progress) addObserver:self forKeyPath:@"downloadProgress" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSNumber class]]) {
        NSNumber *progress = (NSNumber *)object;
        
        NSLog(@"Progress is %@", progress);
        //        [self.delegate downLoadThemeWithProgress:progress];
    }
}
@end
