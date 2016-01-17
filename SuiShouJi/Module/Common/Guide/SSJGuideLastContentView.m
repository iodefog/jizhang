//
//  SSJGuideLastContentView.m
//  YYDB
//
//  Created by old lang on 15/11/18.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJGuideLastContentView.h"

@interface SSJGuideLastContentView ()

@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) UIImageView *textView;
@property (nonatomic, strong) UIImageView *backgroundView;

@end

@implementation SSJGuideLastContentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.backgroundView];
        [self addSubview:self.logoView];
        [self addSubview:self.textView];
    }
    return self;
}

- (void)layoutSubviews {
    self.logoView.center = CGPointMake(self.width * 0.5, self.height * 0.28);
    self.textView.centerX = self.width * 0.5;
    self.textView.top = self.logoView.bottom + 32;
    self.backgroundView.frame = self.bounds;
}

- (UIImageView *)logoView {
    if (!_logoView) {
        _logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"guide_lastLogo"]];
    }
    return _logoView;
}

- (UIImageView *)textView {
    if (!_textView) {
        _textView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"guide_lastText"]];
    }
    return _textView;
}

- (UIImageView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"guide_background"]];
    }
    return _backgroundView;
}

@end
