//
//  SSJRecordMakingBillTypeInputAccessoryView.m
//  SuiShouJi
//
//  Created by old lang on 16/5/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingBillTypeInputAccessoryView.h"

@interface SSJRecordMakingBillTypeInputAccessoryView ()

@property (nonatomic, strong) UITextView *memoView;

@property (nonatomic, strong) UIButton *accountBtn;

@property (nonatomic, strong) UIButton *dateBtn;

@property (nonatomic, strong) UIButton *photoBtn;

@property (nonatomic, strong) UIButton *periodBtn;

@end

@implementation SSJRecordMakingBillTypeInputAccessoryView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)layoutSubviews {
    
}

- (UITextView *)memoView {
    if (!_memoView) {
        _memoView = [UITextView alloc] initWithFrame:<#(CGRect)#>
    }
    return _memoView;
}

- (UIButton *)accountBtn {
    if (!_accountBtn) {
        
    }
    return _accountBtn;
}

- (UIButton *)dateBtn {
    if (!_dateBtn) {
        
    }
    return _dateBtn;
}

- (UIButton *)photoBtn {
    if (!_photoBtn) {
        
    }
    return _photoBtn;
}

- (UIButton *)periodBtn {
    if (!_periodBtn) {
        
    }
    return _periodBtn;
}

@end
