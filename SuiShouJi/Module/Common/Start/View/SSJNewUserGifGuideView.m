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

@synthesize isNormalState = _isNormalState;


- (instancetype)initWithFrame:(CGRect)frame
                WithImageName:(NSString *)imageName
                        title:(NSString *)title
                     subTitle:(NSString *)subTitle
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor]; 
        [self addSubview:self.titleLab];
        [self addSubview:self.subTitleLab];
        [self addSubview:self.gifImageView];
        _isNormalState = NO;
        self.animatedImage = [YYImage imageNamed:imageName];
        self.gifImageView.image = self.animatedImage;
        self.titleLab.text = title;
        self.subTitleLab.text = subTitle;
        [self.gifImageView addObserver:self forKeyPath:@"currentIsPlayingAnimation" options:NSKeyValueObservingOptionNew context:nil];
        [self updateFocusIfNeeded];
    }
    return self;
}

- (void)dealloc {
    [self.gifImageView removeObserver:self forKeyPath:@"currentIsPlayingAnimation"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    _isNormalState = NO;
    if (self.animationCompletBlock) {
        self.animationCompletBlock();
    }
}

- (void)updateConstraints {
    [self.gifImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self);
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self.subTitleLab.mas_bottom).offset(10);
        make.height.mas_equalTo(self.animatedImage.size.height * self.width / self.animatedImage.size.width);
    }];
    
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(85);
        make.centerX.mas_equalTo(self);
    }];
    
    [self.subTitleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLab.mas_bottom).offset(50);
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
        _subTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _subTitleLab.textAlignment = NSTextAlignmentCenter;
        _subTitleLab.numberOfLines = 0;
    }
    return _subTitleLab;
}

- (void)startAnimating {
    _isNormalState = NO;
    self.gifImageView.currentAnimatedImageIndex = 0;
    [self.gifImageView startAnimating];
    self.titleLab.hidden = NO;
    self.subTitleLab.hidden = NO;
    self.titleLab.alpha = 0;
    self.subTitleLab.alpha = 0;
    [UIView animateWithDuration:2.f animations:^(void){
        self.subTitleLab.alpha = 1.f;
        self.titleLab.alpha = 1.f;
    } completion:^(BOOL finished) {

    }];
}

- (void)setIsNormalState:(BOOL)isNormalState {
    if (!self.isNormalState && isNormalState) {
        self.titleLab.hidden = YES;
        self.subTitleLab.hidden = YES;
        self.gifImageView.currentAnimatedImageIndex = 0;
        self.titleLab.alpha = 0;
        self.subTitleLab.alpha = 0;
    }
    _isNormalState = isNormalState;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
