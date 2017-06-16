//
//  SSJAnimationLuanchView.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/16.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJAnimationLuanchView.h"

@interface SSJAnimationLuanchView()

@property (nonatomic, strong) YYAnimatedImageView *defaultView;

@end

@implementation SSJAnimationLuanchView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            UIImage *image;
            if (CGSizeEqualToSize(screenSize, CGSizeMake(320.0, 480.0))) {
                image = [YYImage imageNamed:@"ani@960.webp"];
            } else {
                image = [YYImage imageNamed:@"ani.webp"];
            }
            _defaultView = [[YYAnimatedImageView alloc] initWithImage:image];
            _defaultView.frame = self.bounds;
            [self addSubview:_defaultView];
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
