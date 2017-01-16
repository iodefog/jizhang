//
//  SSJHomeBillStickyNoteView.m
//  SuiShouJi
//
//  Created by yi cai on 2017/1/9.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJHomeBillStickyNoteView.h"
NSString *const SSJShowBillNoteKey = @"SSJShowBillNoteKey";
@interface SSJHomeBillStickyNoteView()

@property (nonatomic, strong) UIButton *noteButton;
@property (nonatomic, strong) CALayer *lineLayer;

@property (nonatomic, strong) UIButton *closeButton;
@end

@implementation SSJHomeBillStickyNoteView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self.layer addSublayer:self.lineLayer];
        [self addSubview:self.noteButton];
        [self addSubview:self.closeButton];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAfterThemeChange) name:SSJThemeDidChangeNotification object:nil] ;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.lineLayer.top = 0;
    self.lineLayer.left = (self.width - self.lineLayer.width) * 0.5;
    self.noteButton.centerX = self.centerX;
    self.noteButton.top = CGRectGetMaxY(self.lineLayer.frame) - 18;
    self.closeButton.top = self.noteButton.top + 20;
    self.closeButton.right = self.noteButton.right - 10;
}

#pragma mark - Lazy
- (UIButton *)noteButton
{
    if (!_noteButton) {
        _noteButton = [[UIButton alloc] init];
        [_noteButton setImage:[UIImage imageNamed:@"home_bill_note"] forState:UIControlStateNormal];
        [_noteButton setImage:[UIImage imageNamed:@"home_bill_note"] forState:UIControlStateHighlighted];
        [_noteButton sizeToFit];
        [_noteButton addTarget:self action:@selector(openBillNote) forControlEvents:UIControlEventTouchUpInside];
    }
    return _noteButton;
}

- (CALayer *)lineLayer
{
    if (!_lineLayer) {
        _lineLayer = [CALayer layer];
        _lineLayer.size = CGSizeMake(1, 40);
        _lineLayer.contentsScale = [UIScreen mainScreen].scale;
        [_lineLayer setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha].CGColor];
    }
    return _lineLayer;
}

- (UIButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setImage:[UIImage imageNamed:@"home_bill_note_close"] forState:UIControlStateNormal];
        [_closeButton sizeToFit];
        [_closeButton addTarget:self action:@selector(closeBillNote) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

#pragma mark - Event
- (void)closeBillNote
{
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:SSJShowBillNoteKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (self.superview && self.closeBillNoteBlock) {
        [self removeFromSuperview];
        self.closeBillNoteBlock();
    }
}

- (void)openBillNote
{
    if (self.openBillNoteBlock) {
        self.openBillNoteBlock();
    }
}

- (void)updateAfterThemeChange
{
    [self.lineLayer setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor].CGColor];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
