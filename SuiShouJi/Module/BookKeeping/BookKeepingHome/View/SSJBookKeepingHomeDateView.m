//
//  SSJBookKeepingHomeDateView.m
//  SuiShouJi
//
//  Created by ricky on 16/10/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookKeepingHomeDateView.h"

@interface SSJBookKeepingHomeDateView()

@property(nonatomic, strong) UILabel *dateLab;

@property(nonatomic, strong) UIImageView *backImage;

@end


@implementation SSJBookKeepingHomeDateView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sizeToFit];
        [self addSubview:self.backImage];
        [self addSubview:self.dateLab];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.backImage.frame = self.bounds;
    self.dateLab.center = CGPointMake(self.width / 2, self.height / 2);
}

-(CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake(92, 36);
}

- (void)showOnView:(UIView *)view {
    if (self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [keyWindow addSubview:self];
    self.right = keyWindow.width;
    self.centerY = keyWindow.height / 2;
    self.alpha = 0;
    [UIView animateWithDuration:0.5
                   animations:^{
                       self.alpha = 1;
                   }
                     completion:^(BOOL complation) {
                         if (_showBlock) {
                             _showBlock();
                         }
                     }];
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.alpha = 0;
                     }
                     completion:^(BOOL complation) {
                         [self removeFromSuperview];
                         if (_dismissBlock) {
                             _dismissBlock();
                         }
                     }];
}

- (UIImageView *)backImage{
    if (!_backImage) {
        _backImage = [[UIImageView alloc]init];
        _backImage.image = [UIImage ssj_themeImageWithName:@"home_riqi"];
    }
    return _backImage;
}

- (UILabel *)dateLab{
    if (!_dateLab) {
        _dateLab = [[UILabel alloc]init];
        _dateLab.textColor = [UIColor ssj_colorWithHex:@"#FFFFFF"];
        _dateLab.font = [UIFont systemFontOfSize:13];
    }
    return _dateLab;
}

- (void)setCurrentDate:(NSString *)currentDate{
    _currentDate = currentDate;
    self.dateLab.text = [NSString stringWithFormat:@"%@",_currentDate];
    [self.dateLab sizeToFit];
}

- (void)updateAfterThemeChange{
    self.backImage.image = [UIImage ssj_themeImageWithName:@"home_riqi"];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
