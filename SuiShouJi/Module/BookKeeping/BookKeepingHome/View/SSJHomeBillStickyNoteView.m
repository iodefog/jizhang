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
@property (nonatomic, strong) UIImageView *noteImageView;

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
        [self.layer addSublayer:self.layer];
        [self addSubview:self.noteButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}


- (void)showBillNote
{
    
}

#pragma mark - Lazy
- (UIButton *)noteButton
{
    if (!_noteButton) {
        _noteButton = [[UIButton alloc] init];
        [_noteButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    return _noteButton;
}

- (CALayer *)lineLayer
{
    if (!_lineLayer) {
        _lineLayer = [CALayer layer];
    }
    return _lineLayer;
}

- (UIButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    return _closeButton;
}
@end
