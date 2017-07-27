//
//  SSJBooksView.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBooksView.h"
#import "SSJBooksTypeItem.h"
#import "SSJShareBookItem.h"
#import <YYText/YYText.h>

static const CGFloat kBooksCornerRadius = 10.f;

@interface SSJBooksView()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) YYLabel *nameLab;

@end

@implementation SSJBooksView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.nameLab];
        [self setNeedsUpdateConstraints];
        self.layer.cornerRadius = kBooksCornerRadius;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha].CGColor;
        [self clipsToBounds];
    }
    return self;
}

- (void)setNeedsUpdateConstraints {
    [super setNeedsUpdateConstraints];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-16);
        make.centerY.mas_equalTo(self);
    }];
    
}

#pragma mark - Setter
- (void)setBooksTypeItem:(__kindof SSJBaseCellItem <SSJBooksItemProtocol> *)booksTypeItem {
    _booksTypeItem = booksTypeItem;
    self.nameLab.text = _booksTypeItem.booksName;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (!_booksTypeItem.booksId.length) {
        self.gradientLayer.hidden = YES;
        self.nameLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        self.layer.borderWidth = 1;
    } else {
        self.gradientLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:_booksTypeItem.booksColor.endColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:_booksTypeItem.booksColor.startColor].CGColor];
        self.gradientLayer.hidden = NO;
        self.nameLab.textColor = [UIColor whiteColor];
        self.layer.borderWidth = 0;
    }
    
    [CATransaction commit];
}



#pragma mark - Lazy
- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = CGRectMake(0, 0, self.width, self.height);
        _gradientLayer.cornerRadius = kBooksCornerRadius;
    }
    return _gradientLayer;
}


- (YYLabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[YYLabel alloc] init];
        _nameLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _nameLab.textColor = [UIColor whiteColor];
        _nameLab.verticalForm = YES;
    }
    return _nameLab;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
