//
//  SSJRecordMakingMoveCategoryAlertView.m
//  SuiShouJi
//
//  Created by old lang on 16/9/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingMoveCategoryAlertView.h"
#import "UIView+SSJViewAnimatioin.h"

static NSString *const kIsAlertViewShowedKey = @"kIsAlertViewShowedKey";

@interface SSJRecordMakingMoveCategoryAlertView ()

@property (nonatomic, strong) UILabel *lab1;

@property (nonatomic, strong) UILabel *lab2;

@property (nonatomic, strong) UILabel *lab3;

@property (nonatomic, strong) UIImageView *arrow;

@property (nonatomic, strong) UIButton *sureBtn;

@property (nonatomic, copy) void (^sureButtonHandle)();

@end

@implementation SSJRecordMakingMoveCategoryAlertView

+ (void)showWithSureHandle:(void(^)())handle {
    SSJRecordMakingMoveCategoryAlertView *alert = [[SSJRecordMakingMoveCategoryAlertView alloc] initWithFrame:CGRectMake(0, 0, 284, 180)];
    alert.sureButtonHandle = handle;
    [alert show];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 3;
        
        _lab1 = [[UILabel alloc] init];
        _lab1.text = @"点击";
        _lab1.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _lab1.textColor = [UIColor ssj_colorWithHex:@"#393939"];
        [_lab1 sizeToFit];
        [self addSubview:_lab1];
        
        _lab2 = [[UILabel alloc] init];
        _lab2.text = @"键，爱类别将被移动";
        _lab2.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _lab2.textColor = [UIColor ssj_colorWithHex:@"#393939"];
        [_lab2 sizeToFit];
        [self addSubview:_lab2];
        
        _lab3 = [[UILabel alloc] init];
        _lab3.text = @"到添加类别页的底部哦！";
        _lab3.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _lab3.textColor = [UIColor ssj_colorWithHex:@"#393939"];
        [_lab3 sizeToFit];
        [self addSubview:_lab3];
        
        _arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"record_making_remove"]];
        [self addSubview:_arrow];
        
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
        [_sureBtn setTitle:@"知道了" forState:UIControlStateNormal];
        [_sureBtn setTitleColor:[UIColor ssj_colorWithHex:@"#eb4a64"] forState:UIControlStateNormal];
        [_sureBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [_sureBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:@"#e8e8e8"]];
        [_sureBtn ssj_setBorderStyle:SSJBorderStyleTop];
        [_sureBtn ssj_setBorderWidth:1];
        [self addSubview:_sureBtn];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat gap = 8;
    CGFloat left = (self.width - _lab1.width - _lab2.width - _arrow.width - gap * 2) * 0.5;
    _lab1.leftTop = CGPointMake(left, 40);
    _arrow.left = _lab1.right + gap;
    _arrow.centerY = _lab1.centerY;
    _lab2.leftTop = CGPointMake(_arrow.right + gap, 40);
    _lab3.leftTop = CGPointMake(left, _lab1.bottom + 5);
    _sureBtn.frame = CGRectMake(0, 120, self.width, self.height - 120);
}

- (void)dismiss {
    [self ssj_dismiss:^(BOOL finished) {
        if (_sureButtonHandle) {
            _sureButtonHandle();
            _sureButtonHandle = nil;
        }
    }];
}

- (void)show {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [self ssj_popupInView:window completion:NULL];
}


@end
