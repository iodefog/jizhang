//
//  SSJStartChoiceView.m
//  SuiShouJi
//
//  Created by 赵天立 on 2017/9/10.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJStartChoiceView.h"
#import "SSJStartViewHelper.h"

@interface SSJStartChoiceView()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIButton *olderButton;

@property (nonatomic, strong) UIButton *newerButton;

@property (nonatomic, strong) UILabel *newerLab;

@property (nonatomic, strong) UILabel *olderLab;

@end

@implementation SSJStartChoiceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleLab];
        [self addSubview:self.olderButton];
        [self addSubview:self.newerButton];
        [self addSubview:self.olderLab];
        [self addSubview:self.newerLab];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"%@",self.titleLab);
}

- (void)updateConstraints {
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self).offset(160);
    }];
    
    [self.newerButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLab).offset(85);
        make.right.mas_equalTo(self.mas_centerX).offset(-12.5);
        make.size.mas_equalTo(CGSizeMake(130, 130));
    }];
    
    [self.olderButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLab).offset(85);
        make.left.mas_equalTo(self.mas_centerX).offset(12.5);
        make.size.mas_equalTo(CGSizeMake(130, 130));
    }];
    
    [self.newerLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.newerButton.mas_bottom).offset(25);
        make.centerX.mas_equalTo(self.newerButton.mas_centerX);
    }];
    
    [self.olderLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.olderButton.mas_bottom).offset(25);
        make.centerX.mas_equalTo(self.olderButton.mas_centerX);
    }];
    
    [super updateConstraints];
}

#pragma mark - Getter
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _titleLab.text = @"小鱼儿询问下,你属于哪类记账者?";
    }
    return _titleLab;
}

- (UILabel *)newerLab {
    if (!_newerLab) {
        _newerLab = [[UILabel alloc] init];
        _newerLab.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _newerLab.text = @"新手小白";
    }
    return _newerLab;
}

- (UILabel *)olderLab {
    if (!_olderLab) {
        _olderLab = [[UILabel alloc] init];
        _olderLab.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _olderLab.text = @"记账老司机";
    }
    return _olderLab;
}

- (UIButton *)newerButton {
    if (!_newerButton) {
        _newerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_newerButton setImage:[UIImage imageNamed:@"neweruserimage"] forState:UIControlStateNormal];
        [_newerButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _newerButton;
}

- (UIButton *)olderButton {
    if (!_olderButton) {
        _olderButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_olderButton setImage:[UIImage imageNamed:@"olderuserimage"] forState:UIControlStateNormal];
        [_olderButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _olderButton;
}

#pragma mark - Event
- (void)buttonClicked:(id)sender {
    if (sender == self.newerButton) {

    } else {

    }
}

- (void)jumpOutButtonClicked:(id)sender {
    if (self) {
        self.jumpOutButtonClickBlock();
    }
}

#pragma mark - Private
- (void)startAnimating {
    self.newerLab.alpha = 0;
    self.olderLab.alpha = 0;
    self.newerButton.enabled = NO;
    self.olderButton.enabled = NO;
    [UIView animateWithDuration:2.f animations:^(void){
        self.newerLab.alpha = 1.f;
        self.olderLab.alpha = 1.f;
    } completion:NULL];
    
    [UIView animateWithDuration:1.5f animations:^(void){
        self.newerButton.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        self.olderButton.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:1.5f animations:^(void){
            self.newerButton.transform = CGAffineTransformMakeScale(1.f, 1.f);
            self.olderButton.transform = CGAffineTransformMakeScale(1.f, 1.f);
        } completion:^(BOOL finished){
            self.newerButton.enabled = YES;
            self.olderButton.enabled = YES;
        }];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
