//
//  SSJBooksHeaderView.m
//  SuiShouJi
//
//  Created by ricky on 16/11/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//


#import "SSJBooksHeaderView.h"

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - _SSJBooksHeaderSummaryControl
#pragma mark -
@interface _SSJBooksHeaderSummaryControl : UIControl

@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation _SSJBooksHeaderSummaryControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLab];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    if (!CGRectIsEmpty(bounds)) {
        [self setNeedsDisplay];
    }
}

- (void)updateConstraints {
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsMake(1, 6, 6, 6));
    }];
    [super updateConstraints];
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(self.width * 0.5, self.width * 0.5)];
    UIColor *fillColor = SSJ_MARCATO_COLOR;
    [fillColor setFill];
    [path fill];
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        _titleLab.numberOfLines = 0;
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.paragraphSpacing = -4;
        style.alignment = NSTextAlignmentCenter;
        
        _titleLab.attributedText = [[NSAttributedString alloc] initWithString:@"总\n账\n本" attributes:@{NSParagraphStyleAttributeName:style}];
    }
    return _titleLab;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - _SSJBooksHeaderViewCell
#pragma mark -
@interface _SSJBooksHeaderViewCell : UIView

@property (nonatomic, strong) UILabel *topLab;

@property (nonatomic, strong) UILabel *bottomLab;

@end

@implementation _SSJBooksHeaderViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.topLab];
        [self addSubview:self.bottomLab];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)updateConstraints {
    [self.topLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(28);
        make.centerX.mas_equalTo(self);
        make.width.mas_lessThanOrEqualTo(self);
    }];
    [self.bottomLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topLab.mas_bottom).offset(14);
        make.centerX.mas_equalTo(self);
        make.width.mas_lessThanOrEqualTo(self);
    }];
    [super updateConstraints];
}

- (void)updateAppearance {
    _topLab.textColor = SSJ_SECONDARY_COLOR;
    _bottomLab.textColor = SSJ_MAIN_COLOR;
}

- (UILabel *)topLab {
    if (!_topLab) {
        _topLab = [[UILabel alloc] init];
        _topLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_6];
    }
    return _topLab;
}

- (UILabel *)bottomLab {
    if (!_bottomLab) {
        _bottomLab = [[UILabel alloc] init];
        _bottomLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
    }
    return _bottomLab;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJBooksHeaderView
#pragma mark -
@interface SSJBooksHeaderView()

@property(nonatomic, strong) UIView *contentView;

@property(nonatomic, strong) _SSJBooksHeaderViewCell *leftCell;

@property(nonatomic, strong) _SSJBooksHeaderViewCell *rightCell;

@property(nonatomic, strong) _SSJBooksHeaderSummaryControl *summaryButton;

@end

@implementation SSJBooksHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.contentView];
        [self addSubview:self.leftCell];
        [self addSubview:self.rightCell];
        [self addSubview:self.summaryButton];
        
        self.backgroundColor = [UIColor clearColor];
        [self setNeedsUpdateConstraints];
        [self updateAfterThemeChange];
    }
    return self;
}

- (void)updateConstraints {
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsMake(0, 15, 10, 15));
    }];
    [self.leftCell mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(self.contentView);
        make.width.mas_equalTo(self.contentView).multipliedBy(0.5);
    }];
    [self.rightCell mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(self.contentView);
        make.width.mas_equalTo(self.contentView).multipliedBy(0.5);
    }];
    [self.summaryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView);
        make.centerX.mas_equalTo(self);
    }];
    [super updateConstraints];
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.cornerRadius = 8;
        _contentView.clipsToBounds = YES;
    }
    return _contentView;
}

- (_SSJBooksHeaderViewCell *)leftCell {
    if (!_leftCell) {
        _leftCell = [[_SSJBooksHeaderViewCell alloc] init];
        _leftCell.topLab.text = @"累计收入";
    }
    return _leftCell;
}

- (_SSJBooksHeaderViewCell *)rightCell {
    if (!_rightCell) {
        _rightCell = [[_SSJBooksHeaderViewCell alloc] init];
        _rightCell.topLab.text = @"累计支出";
    }
    return _rightCell;
}

- (_SSJBooksHeaderSummaryControl *)summaryButton {
    if (!_summaryButton) {
        _summaryButton = [[_SSJBooksHeaderSummaryControl alloc] init];
        @weakify(self);
        [[_summaryButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.buttonClickBlock) {
                self.buttonClickBlock();
            }
        }];
    }
    return _summaryButton;
}

- (void)setIncome:(double)income{
    _income = income;
    self.leftCell.bottomLab.text = [NSString stringWithFormat:@"%.2f",_income];
    [self.leftCell setNeedsLayout];
}

- (void)setExpenture:(double)expenture{
    _expenture = expenture;
    self.rightCell.bottomLab.text = [NSString stringWithFormat:@"%.2f",_expenture];
    [self.rightCell setNeedsLayout];
}

- (void)updateAfterThemeChange {
    [self.leftCell updateAppearance];
    [self.rightCell updateAppearance];
    [self.summaryButton setNeedsDisplay];
    
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
    } else {
        self.contentView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.financingDetailHeaderColor alpha:SSJ_CURRENT_THEME.financingDetailHeaderAlpha];
    }
}

@end
