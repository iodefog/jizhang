//
//  SSJRecordMakingMoveCategoryAlertView.m
//  SuiShouJi
//
//  Created by old lang on 16/9/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingMoveCategoryAlertView.h"
#import "UIView+SSJViewAnimatioin.h"

@interface SSJRecordMakingMoveCategoryAlertView ()

@property (nonatomic, strong) UILabel *lab1;

@property (nonatomic, strong) UILabel *lab2;

@property (nonatomic, strong) UIImageView *arrow;

@end

@implementation SSJRecordMakingMoveCategoryAlertView

+ (void)show {
    SSJRecordMakingMoveCategoryAlertView *alert = [[SSJRecordMakingMoveCategoryAlertView alloc] initWithFrame:CGRectMake(0, 0, 284, 180)];
    [alert show];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        _lab1 = [[UILabel alloc] init];
        _lab1.text = @"";
    }
    return self;
}

- (void)layoutSubviews {
    
}

- (void)show {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [self ssj_popupInView:window completion:^(BOOL finished) {
        
    }];
}


@end
