//
//  SSJShareBooksStepView.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/16.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksStepView.h"

@interface SSJShareBooksStepView()

@property(nonatomic, strong) UIView *firstCircle;

@property(nonatomic, strong) UIView *secondCircle;

@property(nonatomic, strong) UIView *thirdCircle;

@property(nonatomic, strong) UIImageView *checkImageView;

@end


@implementation SSJShareBooksStepView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.thirdCircle];
        [self addSubview:self.secondCircle];
        [self addSubview:self.firstCircle];
        [self addSubview:self.checkImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.thirdCircle.layer.cornerRadius = self.thirdCircle.height / 2;
    self.secondCircle.layer.cornerRadius = self.secondCircle.height / 2;
    self.firstCircle.layer.cornerRadius = self.firstCircle.height / 2;

}

- (UIView *)firstCircle {
    if (!_firstCircle) {
        _firstCircle = [[UIView alloc] init];
        _firstCircle.backgroundColor = [UIColor ssj_colorWithHex:@"#D0D0D0"];
    }
    return _firstCircle;
}

- (UIView *)secondCircle {
    if (!_secondCircle) {
        _secondCircle = [[UIView alloc] init];
        _secondCircle.backgroundColor = [UIColor ssj_colorWithHex:@"#DCDCDC"];
    }
    return _secondCircle;
}

- (UIView *)thirdCircle {
    if (!_thirdCircle) {
        _thirdCircle = [[UIView alloc] init];
        _thirdCircle.backgroundColor = [UIColor ssj_colorWithHex:@"#EBEBEB"];
    }
    return _thirdCircle;
}

- (UIImageView *)checkImageView {
    if (!_checkImageView) {
        _checkImageView = [[UIImageView alloc] init];
        _checkImageView.image = [UIImage imageNamed:@"sharebk_check"];
        [_checkImageView sizeToFit];
    }
    return _checkImageView;
}

- (void)updateConstraints {
    [self.firstCircle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(self).multipliedBy(0.3);
        make.center.equalTo(self);
    }];
    
    [self.secondCircle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(self).multipliedBy(0.6);
        make.center.equalTo(self);
    }];
    
    [self.thirdCircle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(self);
        make.center.equalTo(self);
    }];
    
    [self.checkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [super updateConstraints];
}

- (void)setIsLastone:(BOOL)isLastone {
    self.checkImageView.hidden = !isLastone;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
