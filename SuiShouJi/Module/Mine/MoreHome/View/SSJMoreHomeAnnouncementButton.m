//
//  SSJMoreHomeAnnouncementButton.m
//  SuiShouJi
//
//  Created by ricky on 2017/2/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJMoreHomeAnnouncementButton.h"

@interface SSJMoreHomeAnnouncementButton()

@property(nonatomic, strong) UIButton *button;

@property(nonatomic, strong) UIView *dotView;

@end

@implementation SSJMoreHomeAnnouncementButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc] initWithFrame:self.bounds];
        [_button setImage:[UIImage imageNamed:@"more_gonggao"] forState:UIControlStateNormal];
    }
    return _button;
}

- (UIView *)dotView
{
    if (!_dotView) {
        _dotView = [[UIView alloc] init];
        _dotView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        _dotView.size = CGSizeMake(5, 5);
        _dotView.layer.cornerRadius = 2.5;
        _dotView.hidden = YES;
        [_dotView clipsToBounds];
    }
    return _dotView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
