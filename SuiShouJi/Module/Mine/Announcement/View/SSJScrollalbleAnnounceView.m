//
//  SSJScrollalbleAnnounceView.m
//  SuiShouJi
//
//  Created by ricky on 2017/2/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJScrollalbleAnnounceView.h"

@interface SSJScrollalbleAnnounceView()

@property(nonatomic, strong) UIView *backView;

@property(nonatomic, strong) UIView *contentBgView;

@property(nonatomic, strong) UILabel *contentLabel;

@property(nonatomic, strong) UILabel *headLab;

@property(nonatomic, strong) CADisplayLink *displayLink;

@property(nonatomic) NSInteger currentIndex;

@property (nonatomic, strong) UIButton *closeBtn;

@end

@implementation SSJScrollalbleAnnounceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.backView];
        [self.backView addSubview:self.contentBgView];
        [self.contentBgView addSubview:self.contentLabel];
        [self addSubview:self.closeBtn];
        [self addSubview:self.headLab];
        self.currentIndex = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];
        if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
            self.backView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor alpha:0.1];
            self.backgroundColor = [UIColor whiteColor];
        } else {
            self.backView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor alpha:0.1];
            self.backgroundColor = [UIColor clearColor];
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeDisplayLink];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backView.frame = self.bounds;
    self.headLab.left = 15;
    self.headLab.centerY = self.height / 2;
    self.contentLabel.left = 0;
    self.contentBgView.left = self.headLab.right + 15;
    self.closeBtn.right = self.right - 15;
    self.contentBgView.height = self.height;
    self.contentBgView.top = 0;
    self.contentBgView.width = self.width - self.headLab.right - 50;
    self.closeBtn.centerY = self.height / 2;
    self.contentLabel.centerY = self.height * 0.5;
}

- (UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_4];
        _contentLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _contentLabel;
}

- (UILabel *)headLab{
    if (!_headLab) {
        _headLab = [[UILabel alloc] init];
        _headLab.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_4];
        _headLab.text = @"有鱼头条";
        _headLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [_headLab sizeToFit];
    }
    return _headLab;
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:self.bounds];
    }
    return _backView;
}

- (UIView *)contentBgView {
    if (!_contentBgView) {
        _contentBgView = [[UIView alloc] init];
        _contentBgView.backgroundColor = [UIColor clearColor];
        _contentBgView.layer.masksToBounds = YES;
    }
    return _contentBgView;
}


- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateTheTextPostion)];
        _displayLink.paused = YES;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        [_closeBtn setImage:[UIImage imageNamed:@"home_tankuang_close"] forState:UIControlStateNormal];
        _closeBtn.size = CGSizeMake(20, 20);
        @weakify(self);
        [[_closeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.headLineCloseBtnClickedBlock) {
                self.headLineCloseBtnClickedBlock(self.item);
            }
        }];
    }
    return _closeBtn;
}

- (void)setItem:(SSJHeadLineItem *)item{
    _item = item;
    self.contentLabel.text = item.headContent;
    [self.contentLabel sizeToFit];
    if (self.contentLabel.width > self.width - self.headLab.right - 50) {
        [self startAnimation];
        _isDisplayRun = YES;
    }
}

- (void)updateTheTextPostion {
    self.contentLabel.centerX --;
    if (self.contentLabel.right <= 0) {
        self.contentLabel.centerX = self.contentLabel.width * 0.8;
    }
}

//移除
- (void)removeDisplayLink {
    self.displayLink.paused = YES;
    [self.displayLink invalidate];
    self.displayLink = nil;
}

//开始
- (void)startAnimation {
    self.displayLink.paused = NO;
}

//暂停
- (void)stopAnimation {
    self.displayLink.paused = YES;
}

- (void)updateAppearanceAfterThemeChanged {
    self.contentLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.headLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        self.backView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor alpha:0.1];
        self.backgroundColor = [UIColor whiteColor];
    } else {
        self.backView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor alpha:0.1];
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[NSUserDefaults standardUserDefaults] setObject:self.item.headId forKey:SSJLastReadHeadLineIdKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (self.headLineClickedBlock) {
        self.headLineClickedBlock(self.item);
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
