//
//  SSJFundingMergeSelectView.m
//  SuiShouJi
//
//  Created by 赵天立 on 2017/7/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFundingSelectView.h"
#import "SSJFinancingHomeitem.h"
#import "SSJCreditCardItem.h"


static const CGFloat kBooksCornerRadius = 8.f;

@interface SSJFundingSelectView()

@property (nonatomic,strong) UILabel *fundNameLab;

@property (nonatomic,strong) CAGradientLayer *gradientLayer;

@end

@implementation SSJFundingSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer addSublayer:self.gradientLayer];
        [self addSubview:self.fundNameLab];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.fundNameLab.center = CGPointMake(self.width / 2, self.height / 2);
}

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = CGRectMake(0, 0, self.width, self.height);
        _gradientLayer.cornerRadius = kBooksCornerRadius;
    }
    return _gradientLayer;
}

- (UILabel *)fundNameLab {
    if (!_fundNameLab) {
        _fundNameLab = [[UILabel alloc] init];
        _fundNameLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _fundNameLab.textColor = [UIColor whiteColor];
    }
    return _fundNameLab;
}

- (void)setFundingItem:(SSJBaseCellItem *)fundingItem {
    _fundingItem = fundingItem;
    if ([_fundingItem isKindOfClass:[SSJFinancingHomeitem class]]) {
        SSJFinancingHomeitem *fundItem = (SSJFinancingHomeitem *)_fundingItem;
        self.gradientLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:fundItem.startColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:fundItem.endColor].CGColor];
        self.fundNameLab.text = fundItem.fundingName;

    } else if ([_fundingItem isKindOfClass:[SSJCreditCardItem class]]) {
        SSJCreditCardItem *carditem = (SSJCreditCardItem *)_fundingItem;
        self.gradientLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:carditem.startColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:carditem.endColor].CGColor];
        self.fundNameLab.text = carditem.cardName;
    }
    [self.fundNameLab sizeToFit];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
