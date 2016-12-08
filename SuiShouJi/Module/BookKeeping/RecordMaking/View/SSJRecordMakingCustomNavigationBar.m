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

@property (nonatomic, strong) CAShapeLayer *arrow;

@property (nonatomic, strong) UIView *containerView;

@end

@implementation SSJRecordMakingCustomNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectZero]) {
        
        _selectedTitleIndex = -1;
        _selectedBillType = SSJBillTypePay;
        _managed = NO;
        
        [self addSubview:self.backOffBtn];
        [self addSubview:self.managerBtn];
        [self addSubview:self.containerView];
        [self addSubview:self.segmentCtrl];
        
        [self.containerView addSubview:self.titleLab];
        [self.containerView.layer addSublayer:self.arrow];
        
        [self updateTitle];
        [self updateRightButtonTitle];
        [self updateSegmentCtrlSelctedIndex];
        [self updateAppearance];
        
        [self sizeToFit];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat statusBarHeight = SSJ_STATUSBAR_HEIGHT;
    
    _backOffBtn.frame = CGRectMake(5, 6 + statusBarHeight, 44, 30);
    _managerBtn.frame = CGRectMake(self.width - 43, 6 + statusBarHeight, 35, 30);
    
    _containerView.size = CGSizeMake(100, 26);
    _containerView.centerX = self.width * 0.5;
    _containerView.top = statusBarHeight + 5;
    
    [_titleLab sizeToFit];
    CGFloat left = (_containerView.width - _titleLab.width - _arrow.width - 5) * 0.5;
    
    _titleLab.left = left;
    _titleLab.centerY = _containerView.height * 0.5;
    
    _arrow.left = _titleLab.right + 5;
    _arrow.position = CGPointMake(_arrow.position.x, _containerView.height * 0.5);
    
    _segmentCtrl.size = CGSizeMake(250, 24);
    _segmentCtrl.centerX = self.width * 0.5;
    _segmentCtrl.top = 34 + statusBarHeight;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(SSJSCREENWITH, 68 + SSJ_STATUSBAR_HEIGHT);
}

#pragma mark - Event
- (void)backOffbtnAction {
    if (_backOffHandle) {
        _backOffHandle(self);
    }
}

- (void)managerBtnAction {
    if (_managementHandle) {
        _managementHandle(self);
    }
}

- (void)showBooksMenuAction {
    __weak typeof(self) wself = self;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [self.booksMenu showInView:window atPoint:CGPointMake(self.width * 0.5, 28 + SSJ_STATUSBAR_HEIGHT) finishHandle:^(SSJListMenu *listMenu) {
        if (_showBookHandle) {
            _showBookHandle(self);
        }
    } dismissHandle:^(SSJListMenu *listMenu) {
        wself.arrow.transform = CATransform3DIdentity;
    }];
    
    _arrow.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
}

- (void)segmentCtrlAction {
    if (_segmentCtrl.selectedSegmentIndex == 0) {
        _selectedBillType = SSJBillTypePay;
    } else if (_segmentCtrl.selectedSegmentIndex == 1) {
        _selectedBillType = SSJBillTypeIncome;
    } else {
        SSJPRINT(@"没有定义选中下标对应的收支类型");
        return;
    }
    
    if (_selectBillTypeHandle) {
        _selectBillTypeHandle(self);
    }
}

- (void)selectBookAction {
    if (_booksMenu.selectedIndex < _booksMenu.items.count - 1) {
        _selectedTitleIndex = _booksMenu.selectedIndex;
        [self updateTitle];
        
        if (_selectBookHandle) {
            _selectBookHandle(self);
        }
    } else if (_booksMenu.selectedIndex == _booksMenu.items.count - 1) {
        if (_addNewBookHandle) {
            _addNewBookHandle(self);
        }
    } else {
        
    }
}

#pragma mark - Private
- (void)updateTitle {
    [self setNeedsLayout];
    
    if (_selectedTitleIndex < 0) {
        _titleLab.text = @"请选择账本";
        return;
    }
    
    _titleLab.text = [_titles ssj_safeObjectAtIndex:_selectedTitleIndex];
}

- (void)updateRightButtonTitle {
    NSString *title = _managed ? @"完成" : @"管理";
    [_managerBtn setTitle:NSLocalizedString(title, nil) forState:UIControlStateNormal];
}

- (void)updateSegmentCtrlSelctedIndex {
    switch (_selectedBillType) {
        case SSJBillTypeIncome:
            _segmentCtrl.selectedSegmentIndex = 1;
            break;
            
        case SSJBillTypePay:
            _segmentCtrl.selectedSegmentIndex = 0;
            break;
            
        case SSJBillTypeSurplus:
        case SSJBillTypeUnknown:
            SSJPRINT(@"");
            break;
    }
}

#pragma mark - Public
- (void)setTitles:(NSArray *)titles {
    if (!titles && [_titles isEqualToArray:titles]) {
        return;
    }
    
    _titles = titles;
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSString *title in _titles) {
        [items addObject:[SSJListMenuItem itemWithImageName:nil title:title]];
    }
    [items addObject:[SSJListMenuItem itemWithImageName:nil title:@"添加账本"]];
    self.booksMenu.items = items;
    self.booksMenu.displayRowCount = MIN(6, _titles.count);
    self.booksMenu.height = 34 * self.booksMenu.displayRowCount;
    _selectedTitleIndex = -1;
    [self updateTitle];
}

- (void)setSelectedTitleIndex:(NSInteger)selectedTitleIndex {
    if (_selectedTitleIndex == selectedTitleIndex) {
        return;
    }
    
    if (selectedTitleIndex >= _titles.count) {
        SSJPRINT(@"下标超过标题数组范围");
        return;
    }
    
    _selectedTitleIndex = selectedTitleIndex;
    _booksMenu.selectedIndex = _selectedTitleIndex;
    [self updateTitle];
}

- (void)setSelectedBillType:(SSJBillType)selectedBillType {
    if (_selectedBillType == selectedBillType) {
        return;
    }
    
    _selectedBillType = selectedBillType;
    [self updateSegmentCtrlSelctedIndex];
}

- (void)setManaged:(BOOL)managed {
    if (_managed != managed) {
        _managed = managed;
        [self updateRightButtonTitle];
    }
}

- (void)updateAppearance {
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarBackgroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    
    UIColor *mainColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    UIColor *marcatoColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    UIColor *secondaryColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    
    _backOffBtn.tintColor = marcatoColor;
    
    [_managerBtn setTitleColor:marcatoColor forState:UIControlStateNormal];
    [_managerBtn setTitleColor:[marcatoColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    
    _titleLab.textColor = marcatoColor;
    
    _arrow.strokeColor = secondaryColor.CGColor;
    
    _segmentCtrl.borderColor = secondaryColor;
    _segmentCtrl.selectedBorderColor = marcatoColor;
    [_segmentCtrl setTitleTextAttributes:@{NSForegroundColorAttributeName:secondaryColor} forState:UIControlStateNormal];
    [_segmentCtrl setTitleTextAttributes:@{NSForegroundColorAttributeName:marcatoColor} forState:UIControlStateSelected];
    
    self.booksMenu.normalTitleColor = mainColor;
    self.booksMenu.selectedTitleColor = mainColor;
    self.booksMenu.fillColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
    self.booksMenu.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    self.booksMenu.imageColor = secondaryColor;
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
        [_segmentCtrl addTarget:self action:@selector(segmentCtrlAction) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentCtrl;
}

- (SSJListMenu *)booksMenu {
    if (!_booksMenu) {
        _booksMenu = [[SSJListMenu alloc] initWithFrame:CGRectMake(0, 0, 104, 0)];
        [_booksMenu addTarget:self action:@selector(selectBookAction) forControlEvents:UIControlEventValueChanged];
    }
    return _booksMenu;
}

- (CAShapeLayer *)arrow {
    if (!_arrow) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointZero];
        [path addLineToPoint:CGPointMake(7, 8)];
        [path addLineToPoint:CGPointMake(14, 0)];
        
        _arrow = [CAShapeLayer layer];
        _arrow.size = CGSizeMake(14, 8);
        _arrow.path = path.CGPath;
        _arrow.lineWidth = 1;
        _arrow.fillColor = [UIColor clearColor].CGColor;
    }
    return _arrow;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBooksMenuAction)];
        [_containerView addGestureRecognizer:tap];
    }
    return _containerView;
}

@end
