//
//  SSJBookkeepingTreeRuleDescView.m
//  SuiShouJi
//
//  Created by old lang on 16/4/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookkeepingTreeRuleDescView.h"

static const UIEdgeInsets kOuterInsets = {54, 14, 36, 14};
static const UIEdgeInsets kInnerInsets = {34, 14, 34, 14};

@interface SSJBookkeepingTreeRuleDescView ()

@property (nonatomic, strong) UIImageView *labBackground;

@property (nonatomic, strong) UILabel *ruleTitleLab;

@property (nonatomic, strong) UILabel *ruleContentLab;

@end

@implementation SSJBookkeepingTreeRuleDescView

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (instancetype)initWithWidth:(CGFloat)width {
    if (self = [super initWithFrame:CGRectMake(0, 0, width, 0)]) {
        
        _labBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rule_bg"]];
        [self addSubview:_labBackground];
        
        _ruleTitleLab = [[UILabel alloc] init];
        _ruleTitleLab.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
        _ruleTitleLab.textColor = [UIColor whiteColor];
        _ruleTitleLab.backgroundColor = [UIColor clearColor];
        _ruleTitleLab.textAlignment = NSTextAlignmentCenter;
        _ruleTitleLab.text = @"规则说明";
        [_ruleTitleLab sizeToFit];
        [self addSubview:_ruleTitleLab];
        
        _ruleContentLab = [[UILabel alloc] init];
        _ruleContentLab.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
        _ruleContentLab.textColor = [UIColor blackColor];
        _ruleContentLab.backgroundColor = [UIColor clearColor];
        _ruleContentLab.numberOfLines = 0;
        _ruleContentLab.text = [self ruleContent];
        _ruleContentLab.width = self.width - kOuterInsets.left - kOuterInsets.right - kInnerInsets.left - kInnerInsets.right;
        [_ruleContentLab sizeToFit];
        [self addSubview:_ruleContentLab];
        
        [self sizeToFit];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithWidth:CGRectGetWidth(frame)];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.width, _ruleContentLab.height + kOuterInsets.top + kOuterInsets.bottom + kInnerInsets.top + kInnerInsets.bottom);
}

- (void)layoutSubviews {
    _labBackground.center = _ruleTitleLab.center = CGPointMake(self.width * 0.5, kOuterInsets.top);
    _ruleContentLab.top = kOuterInsets.top + kInnerInsets.top;
    _ruleContentLab.centerX = self.width * 0.5;
    [self drawDashed];
}

- (void)drawDashed {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:UIEdgeInsetsInsetRect(self.bounds, kOuterInsets) cornerRadius:3];
    
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    layer.lineDashPattern = @[@1, @1];
    layer.lineWidth = 1;
    layer.fillColor = self.backgroundColor.CGColor;
    layer.strokeColor = [UIColor grayColor].CGColor;
    layer.path = path.CGPath;
}

- (NSString *)ruleContent {
    return @"1、每天摇一摇签到，就能给树浇水，每天限浇水1次，坚持助种子成功升级吧。\n\n2、记账树的成长依据您累计登录客户端的天数而定，系统会自动为您累计，天数越多，树的等级越高。\n\n3、时间累计以您实际打开客户端的天数为准；如第1天和第3天登录了客户端，第2天中断，则合计登录天数为2天。\n\n4、若您已累计登录达600天以上,即可获得一棵皇冠树。\n\n5、温馨提示：仅需您当天登录客户端，即可自动累计天数升级。本活动限APP版本号为1.2.0以上用户方可参与。\n\n6、活动最终解释归9188记账所有，如有任何疑问请致电400-7676－108 （工作日：9:00-18:00）。";
}

@end
