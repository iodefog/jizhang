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

@property(nonatomic, strong) UILabel *contentLabel;

@property(nonatomic, strong) UILabel *headLab;

@property(nonatomic, strong) UIView *contentBackView;

@property(nonatomic, strong) CADisplayLink *displayLink;

@property(nonatomic) NSInteger currentIndex;

@end

@implementation SSJScrollalbleAnnounceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.backView];
        [self addSubview:self.contentBackView];
        [self.contentBackView addSubview:self.contentLabel];
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
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backView.frame = self.bounds;
    self.headLab.left = 10;
    self.headLab.centerY = self.height / 2;
//    self.announceTextLayer.position = CGPointMake(self.headLab.right + 20 + self.announceTextLayer.width, self.height / 2);
    self.contentBackView.left = self.headLab.right + 20;
    self.contentBackView.height = self.height;
    self.contentBackView.width = self.width - self.headLab.right + 20;
    self.contentBackView.centerY = self.height / 2;
    self.contentLabel.left = 0;
    self.contentLabel.centerY = self.contentBackView.centerY;
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

- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateTheTextPostion)];
        _displayLink.paused = YES;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

- (UIView *)contentBackView {
    if (!_contentBackView) {
        _contentBackView = [[UIView alloc] init];
        _contentBackView.clipsToBounds = YES;
        _contentBackView.backgroundColor = [UIColor clearColor];
    }
    return _contentBackView;
}


- (void)setItem:(SSJHeadLineItem *)item{
    _item = item;
    self.contentLabel.text = item.headContent;
    [self.contentLabel sizeToFit];
    if (self.contentLabel.width > self.width - self.headLab.right - 20) {
        self.displayLink.paused = NO;
    }
}

- (void)updateTheTextPostion {
    self.contentLabel.left --;
    if (self.contentLabel.right < 0) {
        self.contentLabel.left = self.contentBackView.width;
    }
}

- (void)updateAppearanceAfterThemeChanged {
    _contentLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _headLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
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
