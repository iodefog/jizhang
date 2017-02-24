//
//  SSJScrollalbleAnnounceView.m
//  SuiShouJi
//
//  Created by ricky on 2017/2/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJScrollalbleAnnounceView.h"

@interface SSJScrollalbleAnnounceView()

@property(nonatomic, strong) CATextLayer *announceTextLayer;

@property(nonatomic, strong) UILabel *headLab;

@property(nonatomic, strong) NSTimer *timer;

@property(nonatomic) NSInteger currentIndex;

@end

@implementation SSJScrollalbleAnnounceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer addSublayer:self.announceTextLayer];
        [self addSubview:self.headLab];
        self.currentIndex = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (CATextLayer *)announceTextLayer{
    if (!_announceTextLayer) {
        _announceTextLayer = [CATextLayer layer];
        _announceTextLayer.foregroundColor = [UIColor blackColor].CGColor;
        _announceTextLayer.contentsScale = [UIScreen mainScreen].scale;
        CATransition *transition = [[CATransition alloc]init];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromTop;
        _announceTextLayer.actions = @{@"string":transition};
    }
    return _announceTextLayer;
}

- (UILabel *)headLab{
    if (!_headLab) {
        _headLab = [[UILabel alloc] init];
        _headLab.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
        _headLab.text = @"有鱼头条";
        _headLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        
    }
    return _headLab;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(updateCurrentAnnouncement) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

- (void)setItems:(NSArray<SSJAnnouceMentItem *> *)items{
    _items = items;
    NSString *announcementStr = [items firstObject].announcementTitle;
    NSMutableAttributedString *attributeStr;
    if ([_items firstObject].announcementType == SSJAnnouceMentTypeNew) {
        announcementStr = [NSString stringWithFormat:@"【new】%@",announcementStr];
        attributeStr = [[NSMutableAttributedString alloc] initWithString:announcementStr];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, attributeStr.length)];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] range:[announcementStr rangeOfString:@"【new】"]];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:[announcementStr rangeOfString:[items firstObject].announcementTitle]];

    } else if([_items firstObject].announcementType == SSJAnnouceMentTypeNew) {
        announcementStr = [NSString stringWithFormat:@"【hot】%@",announcementStr];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, attributeStr.length)];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] range:[announcementStr rangeOfString:@"【hot】"]];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:[announcementStr rangeOfString:[items firstObject].announcementTitle]];
    } else {
        announcementStr = [NSString stringWithFormat:@"%@",announcementStr];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, attributeStr.length)];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:[announcementStr rangeOfString:[items firstObject].announcementTitle]];
    }
    self.announceTextLayer.string = attributeStr;
    [self.timer fire];
}

- (void)updateCurrentAnnouncement {
    self.currentIndex ++;
}

- (void)updateCellAppearanceAfterThemeChanged {
    _headLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
