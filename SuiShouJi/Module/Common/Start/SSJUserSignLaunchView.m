//
//  SSJUserSignLaunchView.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserSignLaunchView.h"

#import "SSJStartLunchItem.h"

@interface SSJUserSignLaunchView ()

/**背景图片*/
@property (nonatomic, strong) UIImageView *bgImageView;
/**语录*/
@property (nonatomic, strong) UILabel *signL;

/**author*/
@property (nonatomic, strong) UILabel *authorL;

@property (nonatomic, strong) UIImageView *leftImgView;

@property (nonatomic, strong) UIImageView *rightImgView;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIImageView *iconImgView;

@property (nonatomic, strong) UILabel *appNameL;

@property (nonatomic, strong) UILabel *appSubDetailL;

@property (nonatomic) BOOL isCompleted;

@end

@implementation SSJUserSignLaunchView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.bgImageView];
        [self addSubview:self.leftImgView];
        [self addSubview:self.signL];
        [self addSubview:self.rightImgView];
        [self addSubview:self.authorL];
        
        [self addSubview:self.bottomView];
        [self.bottomView addSubview:self.iconImgView];
        [self.bottomView addSubview:self.appNameL];
        [self.bottomView addSubview:self.appSubDetailL];
        
        self.backgroundColor = [UIColor whiteColor];
        self.signL.textColor = self.appNameL.textColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].mainColor];
        self.authorL.textColor = self.appSubDetailL.textColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].secondaryColor];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)showWith:(SSJStartLunchItem *)item timeout:(NSTimeInterval)timeout completion:(void (^)())completion {
    
    [self downloadTextBgImgWithUrl:item.textImgItem.imgUrl timeout:timeout completion:completion];
    //随机显示内容文字
    NSArray <SSJStartTextItem *> *arr = item.textImgItem.texts;
    if (arr.count == 0) return;
    NSUInteger index = arc4random() % arr.count;
    SSJStartTextItem *textItem = [arr ssj_safeObjectAtIndex:index];
    self.authorL.text = [NSString stringWithFormat:@"—%@",textItem.textAuthor];
    
    NSMutableParagraphStyle  *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    // 行间距设置为20
    [paragraphStyle  setLineSpacing:10];
    
    NSMutableAttributedString  *setString = [[NSMutableAttributedString alloc] initWithString:textItem.textContent];
    [setString  addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [textItem.textContent length])];
    
    // 设置Label要显示的text
    [self.signL  setAttributedText:setString];
    self.signL.font = [UIFont ssj_pingFangRegularFontOfSize:[textItem.fontSize integerValue]];
    self.signL.textColor = [UIColor ssj_colorWithHex:textItem.color];
}

//背景图片
- (void)downloadTextBgImgWithUrl:(NSString *)imgUrl timeout:(NSTimeInterval)timeout completion:(void (^)())completion {
    if (imgUrl.length) {
#ifdef DEBUG
        [CDAutoHideMessageHUD showMessage:@"开始下载服务端下发图文图文启动页"];
#endif
        SDWebImageManager *manager = [[SDWebImageManager alloc] init];
        //    manager.imageDownloader.downloadTimeout = timeout;
        NSURL *url = [NSURL URLWithString:SSJImageURLWithAPI(imgUrl)];
        [manager.imageDownloader downloadImageWithURL:url options:(SDWebImageContinueInBackground | SDWebImageAllowInvalidSSLCertificates) progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            if (!image || error) {
#ifdef DEBUG
                [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"下载服务端下发启动页失败，error:%@", [error localizedDescription]]];
#endif
            }
            self.bgImageView.image = image;
#ifdef DEBUG
            [CDAutoHideMessageHUD showMessage:@"下载服务端下发图文启动页成功"];
#endif
        }];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!_isCompleted) {
            _isCompleted = YES;
            if (completion) {
                completion();
            }
        }
    });
}


#pragma mark - Layout
- (void)updateConstraints {
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
    [self.leftImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.signL);
        make.left.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(14, 12));
    }];
    
    [self.rightImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.signL);
        make.right.mas_equalTo(-20);
        make.size.mas_equalTo(CGSizeMake(14, 12));
    }];
    
    [self.signL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(SSJSCREENHEIGHT * 0.25);
        make.left.mas_equalTo(self.leftImgView.mas_right).offset(22);
        make.right.mas_equalTo(self.rightImgView.mas_left).offset(-22);
        make.height.greaterThanOrEqualTo(0);
    }];
    
    [self.authorL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.rightImgView);
        make.top.mas_equalTo(self.signL.mas_bottom).offset(10);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(0);
        make.height.mas_equalTo(80);
    }];
    
    [self.appSubDetailL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(SSJSCREENWITH * 0.5 -30);
        make.top.mas_equalTo(42);
        make.height.width.greaterThanOrEqualTo(0);
    }];
    
    [self.appNameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.appSubDetailL);
        make.bottom.mas_equalTo(self.appSubDetailL.mas_top).offset(-4);
        make.height.width.greaterThanOrEqualTo(0);
    }];
    
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.right.mas_equalTo(self.appNameL.mas_left).offset(-14);
        make.top.mas_equalTo(15);
    }];
    
    [super updateConstraints];
}


#pragma mark - Lazy

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
    }
    return _bgImageView;
}
- (UILabel *)signL {
    if (!_signL) {
        _signL = [[UILabel alloc] init];
        // 设置为多行显示
        _signL.numberOfLines = 0;
    }
    return _signL;
}

- (UILabel *)authorL {
    if (!_authorL) {
        _authorL = [[UILabel alloc] init];
    }
    return _authorL;
}

- (UIImageView *)leftImgView {
    if (!_leftImgView) {
        _leftImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lunch_left_img"]];
    }
    return _leftImgView;
}

- (UIImageView *)rightImgView {
    if (!_rightImgView) {
        _rightImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lunch_right_img"]];
    }
    return _rightImgView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        [_bottomView ssj_setBorderColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].cellSeparatorColor alpha:[SSJThemeSetting defaultThemeModel].cellSeparatorAlpha]];
        [_bottomView ssj_setBorderWidth:1];
        [_bottomView ssj_setBorderStyle:SSJBorderStyleTop];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}

- (UILabel *)appNameL {
    if (!_appNameL) {
        _appNameL = [[UILabel alloc] init];
        _appNameL.text = SSJAppName();
        _appNameL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _appNameL;
}

- (UILabel *)appSubDetailL {
    if (!_appSubDetailL) {
        _appSubDetailL = [[UILabel alloc] init];
        _appSubDetailL.text = @"帮我打理好我的小家";
        _appSubDetailL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
    }
    return _appSubDetailL;
}

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SSJAppIcon()]];
    }
    return _iconImgView;
}

@end
