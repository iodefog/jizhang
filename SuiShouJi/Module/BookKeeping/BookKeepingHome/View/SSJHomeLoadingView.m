//
//  SSJHomeLoadingView.m
//  SuiShouJi
//
//  Created by ricky on 2016/12/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJHomeLoadingView.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"

@interface SSJHomeLoadingView()

@property(nonatomic, strong) FLAnimatedImageView *loadingView;

@property(nonatomic, strong) UILabel *statusLab;

@property(nonatomic, strong) NSTimer *timer;

@end

@implementation SSJHomeLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.loadingView];
    }
    return self;
}

- (void)show {
    
    if (self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [keyWindow addSubview:self];
    
    self.size = CGSizeMake(keyWindow.width, keyWindow.height);
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    
    [self removeFromSuperview];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.loadingView.center = CGPointMake(self.width / 2, self.height / 2);
    self.statusLab.centerX = self.width / 2;
    self.statusLab.top = self.loadingView.height + 10;
}

- (FLAnimatedImageView *)loadingView{
    if (!_loadingView) {
        _loadingView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, 180, 180)];
        NSData *gifData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"xiaomao" ofType:@"gif"]];
        _loadingView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:gifData];
    }
    return _loadingView;
}

- (UILabel *)statusLab{
    if (!_statusLab) {
        _statusLab = [[UILabel alloc] init];
        _statusLab.text = @"正在加载数据,请稍后...";
        _statusLab.font = [UIFont systemFontOfSize:16];
        _statusLab.textColor  = [UIColor ssj_colorWithHex:@"#333333"];
    }
    return _statusLab;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
