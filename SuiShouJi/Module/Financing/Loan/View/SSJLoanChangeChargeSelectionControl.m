//
//  SSJLoanChangeChargeSelectionControl.m
//  SuiShouJi
//
//  Created by old lang on 16/11/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanChangeChargeSelectionControl.h"
#import "SSJBaseTableViewCell.h"

static CGFloat kRowHeight = 50;
static CGFloat kGap = 4;

static NSString *const kCellId = @"cellId";

@interface SSJLoanChangeChargeSelectionControl () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *titles;

@end

@implementation SSJLoanChangeChargeSelectionControl

- (instancetype)initWithTitles:(NSArray *)titles{
    if (self = [super initWithFrame:CGRectZero]) {
        self.backgroundColor = [UIColor clearColor];
        self.titles = titles;
        [self addSubview:self.tableView];
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    self.tableView.frame = self.bounds;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake([UIApplication sharedApplication].keyWindow.width, kRowHeight * 3 + kGap + 1);
}

//- (void)setLoanType:(SSJLoanType)loanType {
//    _loanType = loanType;
//    switch (_loanType) {
//        case SSJLoanTypeLend:
//            self.titles = @[@[@"收款", @"追加借出"], @[@"取消"]];
//            break;
//            
//        case SSJLoanTypeBorrow:
//            self.titles = @[@[@"还款", @"追加欠款"], @[@"取消"]];
//            break;
//    }
//}

- (void)show {
    if (self.superview) {
        return;
    }
    
    [self sizeToFit];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.top = keyWindow.height;
    
    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.3 target:self touchAction:@selector(dismiss) animation:^{
        self.bottom = keyWindow.height;
    } timeInterval:0.25 fininshed:NULL];
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [self.superview ssj_hideBackViewForView:self animation:^{
        self.top = keyWindow.bottom;
    } timeInterval:0.25 fininshed:NULL];
}

- (void)updateAppearance {
    self.tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _titles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_titles ssj_safeObjectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = [_titles ssj_objectAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
    cell.textLabel.numberOfLines = 0;
    
    if (indexPath.section == 0) {
        cell.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    } else if (indexPath.section == 1) {
        cell.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return kGap;
    }
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (_selectionHandle) {
            _selectionHandle(title);
        }
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        if (_selectionHandle) {
            _selectionHandle(title);
        }
    }
    [self dismiss];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = kRowHeight;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.scrollEnabled = NO;
        _tableView.sectionFooterHeight = 0;
        [_tableView registerClass:[SSJBaseTableViewCell class] forCellReuseIdentifier:kCellId];
    }
    return _tableView;
}

@end
