//
//  SSJSearchResultOrderHeader.m
//  SuiShouJi
//
//  Created by ricky on 16/9/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSearchResultOrderHeader.h"
#import "SSJSearchBar.h"
#import "SCYSlidePagingHeaderView.h"

@interface SSJSearchResultOrderHeader()<SCYSlidePagingHeaderViewDelegate>

@property(nonatomic, strong) SCYSlidePagingHeaderView *slidePageView;

@property(nonatomic, strong) UILabel *resultCountLabel;

@end

@implementation SSJSearchResultOrderHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self addSubview:self.slidePageView];
        [self addSubview:self.resultCountLabel];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.slidePageView.leftTop = CGPointMake(0, 0);
    self.slidePageView.size = CGSizeMake(self.width, self.height - 34);
    self.resultCountLabel.centerY = self.slidePageView.bottom + (self.height - self.slidePageView.bottom) / 2;
    self.resultCountLabel.left = 10;
}

- (SCYSlidePagingHeaderView *)slidePageView{
    if (!_slidePageView) {
        _slidePageView = [[SCYSlidePagingHeaderView alloc]init];
        _slidePageView.displayedButtonCount = 2;
        _slidePageView.titleFont = 18;
        _slidePageView.buttonClickAnimated = YES;
        _slidePageView.titles = @[@"时间",@"金额"];
        _slidePageView.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        [_slidePageView setButtonImage:[UIImage imageNamed:@"search_ordernormal"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:0];
        [_slidePageView setButtonImage:[UIImage imageNamed:@"search_ordernormal"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:1];
        _slidePageView.customDelegate = self;
    }
    return _slidePageView;
}

- (UILabel *)resultCountLabel{
    if (!_resultCountLabel) {
        _resultCountLabel = [[UILabel alloc]init];
        _resultCountLabel.font = [UIFont systemFontOfSize:12];
        _resultCountLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _resultCountLabel;
}

- (void)setResultCount:(NSInteger)resultCount{
    _resultCount = resultCount;
    self.resultCountLabel.text = [NSString stringWithFormat:@"搜索到%ld条相关流水记录",_resultCount];
    [self.resultCountLabel sizeToFit];
}

- (void)setOrder:(SSJChargeListOrder)order{
    _order = order;
    switch (order) {
        case SSJChargeListOrderMoneyAscending:
            [self.slidePageView setSelectedIndex:1 animated:YES];
            break;
            
        case SSJChargeListOrderMoneyDescending:
            [self.slidePageView setSelectedIndex:1 animated:YES];

            break;
            
        case SSJChargeListOrderDateAscending:
            [self.slidePageView setSelectedIndex:0 animated:YES];
            break;
            
        case SSJChargeListOrderDateDescending:
            [self.slidePageView setSelectedIndex:0 animated:YES];
            break;
            
        default:
            [self.slidePageView setSelectedIndex:0 animated:YES];
            break;
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
