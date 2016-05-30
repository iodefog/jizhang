//
//  SSJGradientMaskView.m
//  SuiShouJi
//
//  Created by ricky on 16/5/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJGradientMaskView.h"

@implementation SSJGradientMaskView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0;

    }
    return self;
}

-(void)setCurrentAplha:(float)currentAplha{
    _currentAplha = currentAplha;
    if (_currentAplha > 0.6f) {
        self.alpha = 0.6;
    }else{
        self.alpha = _currentAplha;
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
