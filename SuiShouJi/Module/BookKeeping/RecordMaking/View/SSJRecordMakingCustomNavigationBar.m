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

@implementation SSJRecordMakingCustomNavigationBarBookItem

+ (instancetype)itemWithTitle:(NSString *)title iconName:(NSString *)iconName {
    SSJRecordMakingCustomNavigationBarBookItem *item = [[SSJRecordMakingCustomNavigationBarBookItem alloc] init];
    item.title = title;
    item.iconName = iconName;
    return item;
}

@end

@interface SSJRecordMakingCustomNavigationBar ()

@property (nonatomic, strong) UIButton *backOffBtn;

@property (nonatomic, strong) UIButton *managerBtn;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) SSJSegmentedControl *segmentCtrl;

@property (nonatomic, strong) SSJListMenu *booksMenu;

@property (nonatomic, strong) CAShapeLayer *arrow;

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

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
        self.canSelectTitle = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat statusBarHeight = SSJ_STATUSBAR_HEIGHT;
    _backOffBtn.frame = CGRectMake(5, 6 + statusBarHeight, 44, 30);
    _managerBtn.rightTop = CGPointMake(self.width - 20, 6 + statusBarHeight);
    
    _containerView.size = CGSizeMake(100, 26);
    _containerView.centerX = self.width * 0.5;
    _containerView.top = statusBarHeight + 5;
    
    [_titleLab sizeToFit];
    if (_canSelectTitle) {
        CGFloat left = (_containerView.width - _titleLab.width - _arrow.width - 5) * 0.5;
        _titleLab.left = left;
        _titleLab.centerY = _containerView.height * 0.5;
        _arrow.left = _titleLab.right + 5;
        _arrow.position = CGPointMake(_arrow.position.x, _containerView.height * 0.5);
    } else {
        _titleLab.center = CGPointMake(_containerView.width * 0.5, _containerView.height * 0.5);
    }
    
    _segmentCtrl.size = CGSizeMake(200, 24);
    _segmentCtrl.centerX = self.width * 0.5;
    _segmentCtrl.top = 40 + statusBarHeight;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(SSJSCREENWITH, 74 + SSJ_STATUSBAR_HEIGHT);
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
    if (_booksMenu.selectedIndex < _booksMenu.items.count) {
        _selectedTitleIndex = _booksMenu.selectedIndex;
        [self updateTitle];
        
        if (_selectBookHandle) {
            _selectBookHandle(self);
        }
    }/* else if (_booksMenu.selectedIndex == _booksMenu.items.count - 1) {
        if (_addNewBookHandle) {
            _addNewBookHandle(self);
        }
    }*/ else {
        
    }
}

#pragma mark - Private
- (void)updateTitle {
    [self setNeedsLayout];
    
    if (_selectedTitleIndex < 0) {
        _titleLab.text = @"请选择账本";
        return;
    }
    SSJRecordMakingCustomNavigationBarBookItem *item = [_bookItems ssj_safeObjectAtIndex:_selectedTitleIndex];
    _titleLab.text = item.title;
}

- (void)updateRightButtonTitle {
    NSString *title = _managed ? @"完成" : @"管理";
    [_managerBtn setTitle:NSLocalizedString(title, nil) forState:UIControlStateNormal];
    [_managerBtn.titleLabel sizeToFit];
    [_managerBtn sizeToFit];
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
- (void)setBookItems:(NSArray<SSJRecordMakingCustomNavigationBarBookItem *> *)bookItems {
    if (!bookItems && [_bookItems isEqualToArray:bookItems]) {
        return;
    }
    
    _bookItems = bookItems;
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (SSJRecordMakingCustomNavigationBarBookItem *item in _bookItems) {
        [items addObject:[SSJListMenuItem itemWithImageName:item.iconName
                                                      title:item.title
                                           normalTitleColor:SSJ_MAIN_COLOR
                                         selectedTitleColor:SSJ_MARCATO_COLOR
                                           normalImageColor:SSJ_SECONDARY_COLOR
                                         selectedImageColor:SSJ_MARCATO_COLOR
                                            backgroundColor:SSJ_MAIN_BACKGROUND_COLOR
                                             attributedText:nil]];
    }
    
    self.booksMenu.items = items;
    self.booksMenu.maxDisplayRowCount = 6.5;
    _selectedTitleIndex = -1;
    [self updateTitle];
}

- (void)setCanSelectTitle:(BOOL)canSelectTitle {
    _canSelectTitle = canSelectTitle;
    self.arrow.hidden = !canSelectTitle;
    self.tapGesture.enabled = canSelectTitle;
    [self setNeedsLayout];
}

- (void)setSelectedTitleIndex:(NSInteger)selectedTitleIndex {
    if (_selectedTitleIndex == selectedTitleIndex) {
        return;
    }
    
    if (selectedTitleIndex >= (NSInteger)_bookItems.count) {
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
    
    _backOffBtn.tintColor = SSJ_MARCATO_COLOR;
    
    [_managerBtn setTitleColor:SSJ_MARCATO_COLOR forState:UIControlStateNormal];
    [_managerBtn setTitleColor:[SSJ_MARCATO_COLOR colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    
    _titleLab.textColor = SSJ_MARCATO_COLOR;
    
    _arrow.fillColor = SSJ_MARCATO_COLOR.CGColor;
    
    _segmentCtrl.borderColor = SSJ_SECONDARY_COLOR;
    _segmentCtrl.selectedBorderColor = SSJ_MARCATO_COLOR;
    [_segmentCtrl setTitleTextAttributes:@{NSForegroundColorAttributeName:SSJ_SECONDARY_COLOR} forState:UIControlStateNormal];
    [_segmentCtrl setTitleTextAttributes:@{NSForegroundColorAttributeName:SSJ_MARCATO_COLOR} forState:UIControlStateSelected];
    
    for (int i = 0; i < self.booksMenu.items.count; i ++) {
        SSJListMenuItem *item = self.booksMenu.items[i];
        item.normalTitleColor = (i == self.booksMenu.items.count - 1) ? SSJ_SECONDARY_COLOR : SSJ_MAIN_COLOR;
    }
    
    [self.booksMenu updateAppearance];
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
        _managerBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_managerBtn addTarget:self action:@selector(managerBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _managerBtn;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
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
        _booksMenu = [[SSJListMenu alloc] initWithFrame:CGRectMake(0, 0, 154, 0)];
        _booksMenu.maxDisplayRowCount = 5.5;
        _booksMenu.gapBetweenImageAndTitle = 10;
        _booksMenu.contentInsets = UIEdgeInsetsMake(0, 13, 0, 13);
        _booksMenu.contentAlignment = UIControlContentHorizontalAlignmentLeft;
        _booksMenu.titleFont = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_booksMenu addTarget:self action:@selector(selectBookAction) forControlEvents:UIControlEventValueChanged];
    }
    return _booksMenu;
}

- (CAShapeLayer *)arrow {
    if (!_arrow) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointZero];
        [path addLineToPoint:CGPointMake(5, 5)];
        [path addLineToPoint:CGPointMake(10, 0)];
        
        _arrow = [CAShapeLayer layer];
        _arrow.size = CGSizeMake(10, 5);
        _arrow.path = path.CGPath;
        _arrow.lineWidth = 1;
        _arrow.fillColor = SSJ_MARCATO_COLOR.CGColor;
    }
    return _arrow;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor clearColor];
        [_containerView addGestureRecognizer:self.tapGesture];
    }
    return _containerView;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBooksMenuAction)];
    }
    return _tapGesture;
}

@end
