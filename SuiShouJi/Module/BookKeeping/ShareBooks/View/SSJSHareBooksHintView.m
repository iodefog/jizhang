//
//  SSJSHareBooksHintView.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/16.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJSHareBooksHintView.h"
#import "SSJShareBooksStepView.h"

@interface SSJSHareBooksHintView()

@property(nonatomic, strong) UILabel *titleLab;

@property(nonatomic, strong) SSJShareBooksStepView *dotView;

@property(nonatomic, strong) UIView *topLine;

@property(nonatomic, strong) UIView *bottomLine;

@end

@implementation SSJSHareBooksHintView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleLab];
        [self addSubview:self.topLine];
        [self addSubview:self.bottomLine];
        [self addSubview:self.dotView];
    }
    return self;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor ssj_colorWithHex:@"#999999"];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _titleLab;
}

- (SSJShareBooksStepView *)dotView {
    if (!_dotView) {
        _dotView = [[SSJShareBooksStepView alloc] init];
    }
    return _dotView;
}

- (UIView *)topLine {
    if (!_topLine) {
        _topLine = [[UIView alloc] init];
        _topLine.backgroundColor = [UIColor ssj_colorWithHex:@"#D8D8D8"];
    }
    return _topLine;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor ssj_colorWithHex:@"#D8D8D8"];
    }
    return _bottomLine;
}

- (void)updateConstraints {
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dotView).offset(15);
        make.centerY.mas_equalTo(self);
    }];
    
    [self.dotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(50);
    }];
    
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(10);
        make.centerX.bottom.mas_equalTo(self.dotView);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(10);
        make.centerX.top.mas_equalTo(self.dotView);
    }];
    
    [super updateConstraints];
}

- (void)setIsLastRow:(BOOL)isLastRow {
    self.bottomLine.hidden = !isLastRow;
}

- (void)setIsFirstRow:(BOOL)isFirstRow {
    self.topLine.hidden = !isFirstRow;
}

- (void)setTitle:(NSString *)title {
    self.titleLab.text = title;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
