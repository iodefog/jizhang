//
//  SSJSHareBooksHintView.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/16.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksHintView.h"
#import "SSJShareBooksStepView.h"

@interface SSJShareBooksHintView()

@property(nonatomic, strong) UILabel *titleLab;

@property(nonatomic, strong) SSJShareBooksStepView *dotView;

@property(nonatomic, strong) UIView *topLine;

@property(nonatomic, strong) UIView *bottomLine;

@end

@implementation SSJShareBooksHintView

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
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
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
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dotView.mas_right).offset(15);
        make.centerY.mas_equalTo(self);
    }];
    
    [self.dotView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(12);
        make.width.mas_equalTo(12);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(50);
    }];
    
    [self.topLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(8);
        make.width.mas_equalTo(1);
        make.centerX.mas_equalTo(self.dotView);
        make.bottom.mas_equalTo(self.dotView.mas_top);
    }];
    
    [self.bottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(8);
        make.width.mas_equalTo(1);
        make.centerX.mas_equalTo(self.dotView);
        make.top.mas_equalTo(self.dotView.mas_bottom);
    }];
    
    [super updateConstraints];
}

- (void)setIsLastRow:(BOOL)isLastRow {
    self.bottomLine.hidden = isLastRow;
    self.dotView.isLastone = isLastRow;
}

- (void)setIsFirstRow:(BOOL)isFirstRow {
    self.topLine.hidden = isFirstRow;
}

- (void)setTitle:(NSString *)title {
    self.titleLab.text = title;
    [self setNeedsUpdateConstraints];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
