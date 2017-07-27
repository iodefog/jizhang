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

static const CGFloat kBooksCornerRadius = 10.f;

@interface SSJBooksView()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) CAShapeLayer *backLayer;

@property (nonatomic, strong) UILabel *nameLab;

@end

@implementation SSJBooksView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer addSublayer:self.gradientLayer];
        [self.layer addSublayer:self.backLayer];
        [self addSubview:self.nameLab];
        [self setNeedsUpdateConstraints];
        self.layer.cornerRadius = kBooksCornerRadius;
        self.layer.masksToBounds = YES;
        [self clipsToBounds];
    }
    return self;
}

- (void)setNeedsUpdateConstraints {
    [super setNeedsUpdateConstraints];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-11);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(20);
    }];
    
}

#pragma mark - Setter
- (void)setBooksTypeItem:(__kindof SSJBaseCellItem *)booksTypeItem {
    _booksTypeItem = booksTypeItem;
    if ([booksTypeItem isKindOfClass:[SSJBooksTypeItem class]]) {//个人账本
        SSJBooksTypeItem *privateBookItem = (SSJBooksTypeItem *)booksTypeItem;
        self.nameLab.text = privateBookItem.booksName;
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.gradientLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:privateBookItem.booksColor.endColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:privateBookItem.booksColor.startColor].CGColor];
        
        if (!privateBookItem.booksId.length && [privateBookItem.booksName isEqualToString:@"添加账本"]) {
            self.gradientLayer.hidden = YES;
            self.backLayer.hidden = NO;
            self.nameLab.textColor = [UIColor ssj_colorWithHex:@"666666"];
        } else {
            self.gradientLayer.hidden = NO;
            self.backLayer.hidden = YES;
            self.nameLab.textColor = [UIColor whiteColor];
        }
        
        [CATransaction commit];
    } else if ([booksTypeItem isKindOfClass:[SSJShareBookItem class]]) {//共享账本
        SSJShareBookItem *shareBookItem = (SSJShareBookItem *)booksTypeItem;
        self.nameLab.text = shareBookItem.booksName;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.gradientLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:shareBookItem.booksColor.endColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:shareBookItem.booksColor.startColor].CGColor];
        if (!shareBookItem.booksId.length && [shareBookItem.booksName isEqualToString:@"添加账本"]) {
            self.gradientLayer.hidden = YES;
            self.backLayer.hidden = NO;
            self.nameLab.textColor = [UIColor ssj_colorWithHex:@"666666"];
        } else {
            self.gradientLayer.hidden = NO;
            self.backLayer.hidden = YES;
            self.nameLab.textColor = [UIColor whiteColor];
        }
        [CATransaction commit];
    }
}



#pragma mark - Lazy
- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        CGRect itemRect = CGRectMake(0, 0, self.width, self.height);
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = itemRect;
        CAShapeLayer *sharpLayer = [CAShapeLayer layer];
        sharpLayer.path = [UIBezierPath bezierPathWithRoundedRect:itemRect cornerRadius:kBooksCornerRadius].CGPath;
        _gradientLayer.mask = sharpLayer;
    }
    return _gradientLayer;
}

- (CAShapeLayer *)backLayer {
    if (!_backLayer) {
        CGRect itemRect = CGRectMake(0, 0, self.width, self.height);
        _backLayer = [CAShapeLayer layer];
        _backLayer.path = [UIBezierPath bezierPathWithRoundedRect:itemRect cornerRadius:kBooksCornerRadius].CGPath;
        _backLayer.strokeColor = [UIColor ssj_colorWithHex:@"666666"].CGColor;
        _backLayer.borderWidth = 1;
        _backLayer.fillColor = [UIColor whiteColor].CGColor;
    }
    return _backLayer;
}

- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.backgroundColor = [UIColor clearColor];
        _nameLab.numberOfLines = 0;
        _nameLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _nameLab.textColor = [UIColor whiteColor];
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
