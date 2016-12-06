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
    self.backOffBtn.frame = CGRectMake(5, 26, 44, 30);
    self.managerBtn.frame = CGRectMake(self.width - 43, 26, 35, 30);
    
    [self.titleLab sizeToFit];
    CGFloat left = (self.width - self.titleLab.width - self.arrow.width - 5) * 0.5;
}

#pragma mark - Event
- (void)backOffbtnAction {
    
}

- (void)managerBtnAction {
    
}

- (void)showBooksMenuAction {
    
}

- (void)segmentCtrlAction {
    
}

- (void)selectBookAction {
    
}

#pragma mark - Public
- (void)setTitles:(NSArray *)titles {
    
}

- (void)setSelectedTitleIndex:(NSInteger)selectedTitleIndex {
    
}

- (void)setSelectedBillType:(SSJBillType)selectedBillType {
    
}

- (void)updateAppearance {
    self.segmentCtrl.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.segmentCtrl.selectedBorderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    [self.segmentCtrl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]} forState:UIControlStateNormal];
    [self.segmentCtrl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]} forState:UIControlStateSelected];
}

#pragma mark - Getter
- (UIButton *)backOffBtn {
    if (!_backOffBtn) {
        _backOffBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backOffBtn setImage:[[UIImage imageNamed:@"navigation_backOff"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_backOffBtn addTarget:self action:@selector(backOffbtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backOffBtn;
}

- (UIButton *)managerBtn {
    if (!_managerBtn) {
        _managerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _managerBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_managerBtn setTitle:NSLocalizedString(@"管理", nil) forState:UIControlStateNormal];
        [_managerBtn addTarget:self action:@selector(managerBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _managerBtn;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:16];
    }
    return _titleLab;
}

- (SSJSegmentedControl *)segmentCtrl {
    if (!_segmentCtrl) {
        _segmentCtrl = [[SSJSegmentedControl alloc] initWithItems:@[NSLocalizedString(@"支出", nil), NSLocalizedString(@"收入", nil)]];
        _segmentCtrl.size = CGSizeMake(250, 24);
        [_segmentCtrl addTarget:self action:@selector(segmentCtrlAction) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentCtrl;
}

- (SSJListMenu *)booksMenu {
    if (!_booksMenu) {
        _booksMenu = [[SSJListMenu alloc] initWithFrame:CGRectMake(0, 0, 104, 214)];
        [_booksMenu addTarget:self action:@selector(selectBookAction) forControlEvents:UIControlEventValueChanged];
    }
    return _booksMenu;
}

- (UIImageView *)arrow {
    if (!_arrow) {
        _arrow = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"record_making_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    }
    return _arrow;
}

@end
