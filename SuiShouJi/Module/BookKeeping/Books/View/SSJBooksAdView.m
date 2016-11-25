//
//  SSJBooksAdView.m
//  SuiShouJi
//
//  Created by ricky on 16/11/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBooksAdView.h"

@interface SSJBooksAdView()

@property(nonatomic, strong) UIButton *closeButton;

@end

@implementation SSJBooksAdView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.adImageView];
        [self addSubview:self.closeButton];
        UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
        singleRecognizer.numberOfTapsRequired = 1;
        [self.adImageView addGestureRecognizer:singleRecognizer];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.adImageView.frame = self.bounds;
    self.closeButton.rightTop = CGPointMake(self.width - 10, 10);
}

- (UIImageView *)adImageView{
    if (!_adImageView) {
        _adImageView = [[UIImageView alloc]init];
        _adImageView.userInteractionEnabled = YES;
    }
    return _adImageView;
}

- (UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 19, 19)];
        [_closeButton setImage:[UIImage imageNamed:@"banner_cha"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

-(void)closeButtonClick:(id)sender{
    if (self.closeButtonClickBlock) {
        self.closeButtonClickBlock();
    }
}

- (void)singleTap{
    if (self.imageClickBlock) {
        self.imageClickBlock();
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
