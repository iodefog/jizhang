//
//  SSJRecordMakingCustomNavigationBar.m
//  SuiShouJi
//
//  Created by old lang on 16/12/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingCustomNavigationBar.h"
#import "SSJSegmentedControl.h"
#import "SSJListMenu.h"

@interface SSJRecordMakingCustomNavigationBar ()

@property (nonatomic, strong) UIButton *backOffBtn;

@property (nonatomic, strong) UIButton *managerBtn;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) SSJSegmentedControl *segmentCtrl;

@property (nonatomic, strong) SSJListMenu *booksMenu;

@property (nonatomic, strong) UIImageView *arrow;


@end

@implementation SSJRecordMakingCustomNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.backOffBtn];
        [self addSubview:self.managerBtn];
        [self addSubview:self.titleLab];
        [self addSubview:self.segmentCtrl];
        [self addSubview:self.booksMenu];
        [self addSubview:self.arrow];
    }
    return self;
}

- (void)layoutSubviews {
    
}

#pragma mark - Event

#pragma mark - Getter
- (UIButton *)backOffBtn {
    if (!_backOffBtn) {
        _backOffBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
    }
    return _backOffBtn;
}

- (UIButton *)managerBtn {
    if (!_managerBtn) {
        
    }
    return _managerBtn;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        
    }
    return _titleLab;
}

- (SSJSegmentedControl *)segmentCtrl {
    if (!_segmentCtrl) {
        
    }
    return _segmentCtrl;
}

- (SSJListMenu *)booksMenu {
    if (!_booksMenu) {
        
    }
    return _booksMenu;
}

- (UIImageView *)arrow {
    if (!_arrow) {
        
    }
    return _arrow;
}

@end
