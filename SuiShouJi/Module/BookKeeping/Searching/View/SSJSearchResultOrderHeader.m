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

@property(nonatomic, strong) UILabel *singleLineLabel;

@property(nonatomic, strong) UILabel *doubleLineIncomeLabel;

@property(nonatomic, strong) UILabel *doubleLineExpentureLabel;

@property(nonatomic, strong) UIView *bottomView;

@end

@implementation SSJSearchResultOrderHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
            self.backgroundColor = [UIColor whiteColor];
        } else {
            self.backgroundColor = [UIColor clearColor];
        }
        [self addSubview:self.slidePageView];
        [self addSubview:self.bottomView];
        [self addSubview:self.resultCountLabel];
        [self addSubview:self.singleLineLabel];
        [self addSubview:self.doubleLineIncomeLabel];
        [self addSubview:self.doubleLineExpentureLabel];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.slidePageView.leftTop = CGPointMake(0, 0);
    self.slidePageView.size = CGSizeMake(self.width, 44);
    self.bottomView.leftTop = CGPointMake(0, self.slidePageView.bottom);
    self.bottomView.size = CGSizeMake(self.width, self.height - self.slidePageView.height);
    if (self.sumItem.resultExpenture && self.sumItem.resultIncome) {
        self.resultCountLabel.bottom = self.slidePageView.bottom + (self.height - self.slidePageView.bottom) / 2 - 9;
        self.resultCountLabel.left = 10;
        self.doubleLineIncomeLabel.top = self.doubleLineExpentureLabel.top = self.slidePageView.bottom + (self.height - self.slidePageView.bottom) / 2 + 9;
        self.doubleLineIncomeLabel.left = 10;
        self.doubleLineExpentureLabel.right = self.width - 10;
    } else {
        self.resultCountLabel.centerY = self.slidePageView.bottom + (self.height - self.slidePageView.bottom) / 2;
        self.resultCountLabel.left = 10;
        self.singleLineLabel.centerY = self.resultCountLabel.centerY;
        self.singleLineLabel.right = self.width - 10;
    }
}

- (SCYSlidePagingHeaderView *)slidePageView{
    if (!_slidePageView) {
        _slidePageView = [[SCYSlidePagingHeaderView alloc]init];
        _slidePageView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        _slidePageView.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _slidePageView.displayedButtonCount = 2;
        _slidePageView.titleFont = 18;
        _slidePageView.buttonClickAnimated = YES;
        _slidePageView.titles = @[@"时间",@"金额"];
        _slidePageView.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        [_slidePageView setButtonImage:[UIImage ssj_themeImageWithName:@"search_ordernormal"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:0];
        [_slidePageView setButtonImage:[UIImage ssj_themeImageWithName:@"search_ordernormal"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:1];
        _slidePageView.customDelegate = self;
    }
    return _slidePageView;
}

- (UILabel *)resultCountLabel{
    if (!_resultCountLabel) {
        _resultCountLabel = [[UILabel alloc]init];
        _resultCountLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        _resultCountLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _resultCountLabel;
}

- (UILabel *)singleLineLabel{
    if (!_singleLineLabel) {
        _singleLineLabel = [[UILabel alloc]init];
        _singleLineLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        _singleLineLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _singleLineLabel;
}

- (UILabel *)doubleLineIncomeLabel{
    if (!_doubleLineIncomeLabel) {
        _doubleLineIncomeLabel = [[UILabel alloc]init];
        _doubleLineIncomeLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        _doubleLineIncomeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _doubleLineIncomeLabel;
}

- (UILabel *)doubleLineExpentureLabel{
    if (!_doubleLineExpentureLabel) {
        _doubleLineExpentureLabel = [[UILabel alloc]init];
        _doubleLineExpentureLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        _doubleLineExpentureLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _doubleLineExpentureLabel;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor alpha:0.1];
    }
    return _bottomView;
}

- (void)setSumItem:(SSJSearchResultSummaryItem *)sumItem{
    _sumItem = sumItem;
    self.resultCountLabel.text = [NSString stringWithFormat:@"搜索到%ld条相关流水记录",(long)sumItem.resultCount];
    [self.resultCountLabel sizeToFit];
    if (!sumItem.resultIncome) {
        self.singleLineLabel.hidden = NO;
        self.singleLineLabel.text = [NSString stringWithFormat:@"支出: -%.2f",sumItem.resultExpenture];
        [self.singleLineLabel sizeToFit];
        self.doubleLineIncomeLabel.hidden = YES;
        self.doubleLineExpentureLabel.hidden = YES;
    }else if (!sumItem.resultExpenture){
        self.singleLineLabel.hidden = NO;
        self.singleLineLabel.text = [NSString stringWithFormat:@"收入: +%.2f",sumItem.resultIncome];
        [self.singleLineLabel sizeToFit];
        self.doubleLineIncomeLabel.hidden = YES;
        self.doubleLineExpentureLabel.hidden = YES;
    }else{
        self.doubleLineIncomeLabel.hidden = NO;
        self.doubleLineExpentureLabel.hidden = NO;
        self.doubleLineIncomeLabel.text = [NSString stringWithFormat:@"收入: +%.2f",sumItem.resultIncome];
        self.doubleLineExpentureLabel.text = [NSString stringWithFormat:@"支出: -%.2f",sumItem.resultExpenture];
        [self.doubleLineIncomeLabel sizeToFit];
        [self.doubleLineExpentureLabel sizeToFit];
        self.singleLineLabel.hidden = YES;
    }
    [self setNeedsLayout];
}

- (void)setOrder:(SSJChargeListOrder)order{
    _order = order;
    switch (order) {
        case SSJChargeListOrderMoneyAscending:{
            [_slidePageView setButtonImage:[UIImage ssj_themeImageWithName:@"search_ordernormal"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:0];
            [_slidePageView setButtonImage:[UIImage imageNamed:@"search_orderasc"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:1];
            [self.slidePageView setSelectedIndex:1 animated:YES];
            [SSJAnaliyticsManager event:@"search_order_money"];
            break;
        }
            
        case SSJChargeListOrderMoneyDescending:{
            [_slidePageView setButtonImage:[UIImage ssj_themeImageWithName:@"search_ordernormal"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:0];
            [_slidePageView setButtonImage:[UIImage ssj_themeImageWithName:@"search_orderdesc"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:1];
            [self.slidePageView setSelectedIndex:1 animated:YES];
            [SSJAnaliyticsManager event:@"search_order_money"];
            break;
        }
            
        case SSJChargeListOrderDateAscending:{
            [_slidePageView setButtonImage:[UIImage ssj_themeImageWithName:@"search_orderasc"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:0];
            [_slidePageView setButtonImage:[UIImage ssj_themeImageWithName:@"search_ordernormal"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:1];
            [self.slidePageView setSelectedIndex:0 animated:YES];
            [SSJAnaliyticsManager event:@"search_order_time"];
            break;
        }
            
        case SSJChargeListOrderDateDescending:{
            [_slidePageView setButtonImage:[UIImage ssj_themeImageWithName:@"search_orderdesc"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:0];
            [_slidePageView setButtonImage:[UIImage ssj_themeImageWithName:@"search_ordernormal"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:1];
            [self.slidePageView setSelectedIndex:0 animated:YES];
            [SSJAnaliyticsManager event:@"search_order_time"];
            break;
        }
            
        default:{
            [_slidePageView setButtonImage:[UIImage ssj_themeImageWithName:@"search_ordernormal"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:0];
            [_slidePageView setButtonImage:[UIImage ssj_themeImageWithName:@"search_ordernormal"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:1];
            [self.slidePageView setSelectedIndex:0 animated:YES];
            break;
        }
    }
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index{
    if (index == 0) {
        switch (self.order) {
            case SSJChargeListOrderMoneyAscending:
                self.order = SSJChargeListOrderDateDescending;
                break;
                
            case SSJChargeListOrderMoneyDescending:
                self.order = SSJChargeListOrderDateDescending;
                break;
                
            case SSJChargeListOrderDateAscending:
                self.order = SSJChargeListOrderDateDescending;
                break;
                
            case SSJChargeListOrderDateDescending:
                self.order = SSJChargeListOrderDateAscending;
                break;
                
            default:
                break;
        }
    }else if(index == 1){
        switch (self.order) {
            case SSJChargeListOrderMoneyAscending:
                self.order = SSJChargeListOrderMoneyDescending;
                break;
                
            case SSJChargeListOrderMoneyDescending:
                self.order = SSJChargeListOrderMoneyAscending;
                break;
                
            case SSJChargeListOrderDateAscending:
                self.order = SSJChargeListOrderMoneyDescending;
                break;
                
            case SSJChargeListOrderDateDescending:
                self.order = SSJChargeListOrderMoneyDescending;
                break;
                
            default:
                break;
        }
    }
    if (self.orderSelectBlock) {
        self.orderSelectBlock(self.order);
    }
}

- (void)updateCellAppearanceAfterThemeChanged {
    if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
        self.backgroundColor = [UIColor whiteColor];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
    self.bottomView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor alpha:0.1];
    self.slidePageView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    self.slidePageView.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.resultCountLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.singleLineLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.doubleLineExpentureLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.doubleLineIncomeLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    switch (self.order) {
        case SSJChargeListOrderMoneyAscending:{
            [_slidePageView setButtonImage:[UIImage ssj_themeImageWithName:@"search_ordernormal"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:0];
            [_slidePageView setButtonImage:[UIImage imageNamed:@"search_orderasc"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:1];
            [self.slidePageView setSelectedIndex:1 animated:YES];
            break;
        }
            
        case SSJChargeListOrderMoneyDescending:{
            [_slidePageView setButtonImage:[UIImage ssj_themeImageWithName:@"search_ordernormal"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:0];
            [_slidePageView setButtonImage:[UIImage ssj_themeImageWithName:@"search_orderdesc"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:1];
            [self.slidePageView setSelectedIndex:1 animated:YES];
            break;
        }
            
        case SSJChargeListOrderDateAscending:{
            [_slidePageView setButtonImage:[UIImage ssj_themeImageWithName:@"search_orderasc"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:0];
            [_slidePageView setButtonImage:[UIImage ssj_themeImageWithName:@"search_ordernormal"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:1];
            [self.slidePageView setSelectedIndex:0 animated:YES];
            break;
        }
            
        case SSJChargeListOrderDateDescending:{
            [_slidePageView setButtonImage:[UIImage ssj_themeImageWithName:@"search_orderdesc"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:0];
            [_slidePageView setButtonImage:[UIImage ssj_themeImageWithName:@"search_ordernormal"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:1];
            [self.slidePageView setSelectedIndex:0 animated:YES];
            break;
        }
            
        default:{
            [_slidePageView setButtonImage:[UIImage ssj_themeImageWithName:@"search_ordernormal"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:0];
            [_slidePageView setButtonImage:[UIImage ssj_themeImageWithName:@"search_ordernormal"] layoutType:SSJButtonLayoutTypeImageRightTitleLeft spaceBetweenImageAndTitle:13 forControlState:UIControlStateNormal atIndex:1];
            [self.slidePageView setSelectedIndex:0 animated:YES];
            break;
        }
    }
    self.slidePageView.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
