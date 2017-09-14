//
//  SSJNewUserGifGuideView.m
//  SuiShouJi
//
//  Created by ricky on 2017/9/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJNewUserGifGuideView.h"

@interface SSJNewUserGifGuideView()

@property (nonatomic, strong) YYAnimatedImageView *gifImageView;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UILabel *subTitleLab;

@property (nonatomic, strong) YYImage *animatedImage;

@end

@implementation SSJNewUserGifGuideView

- (instancetype)initWithFrame:(CGRect)frame
                WithImageName:(NSString *)imageName
                        title:(NSString *)title
                     subTitle:(NSString *)subTitle
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleLab];
        [self addSubview:self.subTitleLab];
        [self addSubview:self.gifImageView];
        self.animatedImage = [YYImage imageNamed:imageName];
        self.gifImageView.image = self.animatedImage;
        self.titleLab.text = title;
        self.subTitleLab.text = subTitle;
    }
    return self;
}

- (void)updateConstraints {
    [self.gifImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self);
        if (self.animatedImage.size.height > self.height) {
            make.height.mas_equalTo(self);
            make.center.mas_equalTo(self);
        } else {
            make.top.mas_equalTo(self.subTitleLab.bottom).offset(10);
            make.height.mas_equalTo(self.animatedImage.size.height);
        }
    }];
    
    [self.subTitleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(85);
        make.centerX.mas_equalTo(self);
    }];
    
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.subTitleLab.mas_bottom).offset(50);
        make.centerX.mas_equalTo(self);
    }];
    
    [super updateConstraints];
}

- (YYAnimatedImageView *)gifImageView {
    if (!_gifImageView) {
        _gifImageView = [[YYAnimatedImageView alloc] init];
        _gifImageView.autoPlayAnimatedImage = NO;
    }
    return _gifImageView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _titleLab.font = [UIFont ssj_compatibleBoldSystemFontOfSize:SSJ_FONT_SIZE_2];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.numberOfLines = 0;
    }
    return _titleLab;
}

- (UILabel *)subTitleLab {
    if (!_subTitleLab) {
        _subTitleLab = [[UILabel alloc] init];
        _subTitleLab.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _subTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _subTitleLab.textAlignment = NSTextAlignmentCenter;
        _subTitleLab.numberOfLines = 0;
    }
    return _subTitleLab;
}

- (void)startAnimating {
    [self.gifImageView startAnimating];
    self.subTitleLab.alpha = 0;
    self.titleLab.alpha = 0;
    [UIView animateWithDuration:2.f animations:^(void){
        self.subTitleLab.alpha = 1.f;
        self.titleLab.alpha = 1.f;
    } completion:NULL];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
