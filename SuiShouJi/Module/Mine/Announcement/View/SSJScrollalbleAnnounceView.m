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
        [self addSubview:self.backView];
        [self addSubview:self.headLab];
        [self.layer addSublayer:self.announceTextLayer];
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
    [self.timer invalidate];
    self.timer = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backView.frame = self.bounds;
    self.headLab.left = 10;
    self.headLab.centerY = self.height / 2;
    SSJAnnoucementItem *currentItem = [self.items objectAtIndex:self.currentIndex];
    CGSize textLayerSize = [currentItem.announcementTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
    self.announceTextLayer.size = CGSizeMake(self.width - self.headLab.right - 20 ,textLayerSize.height);
//    self.announceTextLayer.position = CGPointMake(self.headLab.right + 20 + self.announceTextLayer.width, self.height / 2);
    self.announceTextLayer.left = self.headLab.right + 20;
    self.announceTextLayer.top = self.height / 2 - textLayerSize.height / 2;
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

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:4 target:self selector:@selector(updateCurrentAnnouncement) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

- (void)setItems:(NSArray<SSJAnnoucementItem *> *)items{
    _items = items;
    NSString *announcementStr = [items firstObject].announcementTitle;
    if (!items.count) {
        return;
    }
    NSMutableAttributedString *attributeStr;
    if ([_items firstObject].announcementType == SSJAnnouceMentTypeNew) {
        announcementStr = [NSString stringWithFormat:@"【new】%@",announcementStr];
        attributeStr = [[NSMutableAttributedString alloc] initWithString:announcementStr];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, attributeStr.length)];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] range:[announcementStr rangeOfString:@"【new】"]];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:[announcementStr rangeOfString:[items firstObject].announcementTitle]];

    } else if([_items firstObject].announcementType == SSJAnnouceMentTypeHot) {
        announcementStr = [NSString stringWithFormat:@"【hot】%@",announcementStr];
        attributeStr = [[NSMutableAttributedString alloc] initWithString:announcementStr];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, attributeStr.length)];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] range:[announcementStr rangeOfString:@"【hot】"]];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:[announcementStr rangeOfString:[items firstObject].announcementTitle]];
    } else {
        announcementStr = [NSString stringWithFormat:@"%@",announcementStr];
        attributeStr = [[NSMutableAttributedString alloc] initWithString:announcementStr];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, attributeStr.length)];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:[announcementStr rangeOfString:[items firstObject].announcementTitle]];
    }
    self.announceTextLayer.string = attributeStr;
    CGSize textLayerSize = [announcementStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
    self.announceTextLayer.size = CGSizeMake(self.width - self.headLab.right - 20 ,textLayerSize.height);
    [self setNeedsLayout];
    [self.timer fire];
}

- (void)updateCurrentAnnouncement {
    self.currentIndex ++;
    if (self.currentIndex > self.items.count - 1) {
        self.currentIndex = 0;
    }
    SSJAnnoucementItem *currentItem = [self.items objectAtIndex:self.currentIndex];
    NSString *announcementStr = currentItem.announcementTitle;
    NSMutableAttributedString *attributeStr;
    if (currentItem.announcementType == SSJAnnouceMentTypeNew) {
        announcementStr = [NSString stringWithFormat:@"【new】%@",announcementStr];
        attributeStr = [[NSMutableAttributedString alloc] initWithString:announcementStr];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, attributeStr.length)];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] range:[announcementStr rangeOfString:@"【new】"]];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:[announcementStr rangeOfString:currentItem.announcementTitle]];
        
    } else if([_items firstObject].announcementType == SSJAnnouceMentTypeHot) {
        announcementStr = [NSString stringWithFormat:@"【hot】%@",announcementStr];
        attributeStr = [[NSMutableAttributedString alloc] initWithString:announcementStr];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, attributeStr.length)];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] range:[announcementStr rangeOfString:@"【hot】"]];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:[announcementStr rangeOfString:currentItem.announcementTitle]];
    } else {
        announcementStr = [NSString stringWithFormat:@"%@",announcementStr];
        attributeStr = [[NSMutableAttributedString alloc] initWithString:announcementStr];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, attributeStr.length)];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:[announcementStr rangeOfString:currentItem.announcementTitle]];
    }
    self.announceTextLayer.string = attributeStr;
    [self setNeedsLayout];
}

- (void)updateAppearanceAfterThemeChanged {
    _headLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    SSJAnnoucementItem *currentItem = [self.items objectAtIndex:self.currentIndex];
    NSString *announcementStr = currentItem.announcementTitle;
    NSMutableAttributedString *attributeStr;
    if (currentItem.announcementType == SSJAnnouceMentTypeNew) {
        announcementStr = [NSString stringWithFormat:@"【new】%@",announcementStr];
        attributeStr = [[NSMutableAttributedString alloc] initWithString:announcementStr];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, attributeStr.length)];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] range:[announcementStr rangeOfString:@"【new】"]];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:[announcementStr rangeOfString:currentItem.announcementTitle]];
        
    } else if([_items firstObject].announcementType == SSJAnnouceMentTypeNew) {
        announcementStr = [NSString stringWithFormat:@"【hot】%@",announcementStr];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, attributeStr.length)];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] range:[announcementStr rangeOfString:@"【hot】"]];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:[announcementStr rangeOfString:currentItem.announcementTitle]];
    } else {
        announcementStr = [NSString stringWithFormat:@"%@",announcementStr];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, attributeStr.length)];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:[announcementStr rangeOfString:currentItem.announcementTitle]];
    }
    self.announceTextLayer.string = attributeStr;
    
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        self.backView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor alpha:0.1];
        self.backgroundColor = [UIColor whiteColor];
    } else {
        self.backView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor alpha:0.1];
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    SSJAnnoucementItem *item = [self.items ssj_safeObjectAtIndex:self.currentIndex];
    if (self.announceClickedBlock) {
        self.announceClickedBlock(item);
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
