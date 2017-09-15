//
//  SSJCircleChargeTypeSelectView.m
//  SuiShouJi
//
//  Created by ricky on 16/6/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCircleChargeTypeSelectView.h"
#import "SSJFundingTypeTableViewCell.h"

static const CGFloat kTitleHeight = 50;
static const CGFloat kRowHeight = 45;

static NSString *const kTitle1 = @"支出";
static NSString *const kTitle2 = @"收入";

static NSString *kCellID = @"cellID";

@interface SSJCircleChargeTypeSelectView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIImageView *accessoryView;

@property (nonatomic, strong) NSArray *titles;

@end

@implementation SSJCircleChargeTypeSelectView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
        self.titles = @[kTitle2,kTitle1];
        [self addSubview:self.titleLab];
        [self addSubview:self.tableView];
        [self sizeToFit];
    }
    return self;
}

- (void)layoutSubviews {
    self.titleLab.frame = CGRectMake(0, 0, self.width, kTitleHeight);
    self.tableView.frame = CGRectMake(0, kTitleHeight, self.width, kRowHeight * self.titles.count);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake([UIApplication sharedApplication].keyWindow.width, kTitleHeight + kRowHeight * self.titles.count);
}

- (void)show {
    if (self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [self.tableView reloadData];    
    
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (!cell) {
        cell = [[SSJBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.backgroundColor = [UIColor clearColor];
    NSString *title = [self.titles ssj_safeObjectAtIndex:indexPath.row];
    cell.textLabel.text = title;
    cell.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    cell.accessoryView = indexPath.row == self.selectIndex ? self.accessoryView : nil;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectIndex = indexPath.row;
    [self.tableView reloadData];
    [self dismiss];
    if (self.chargeTypeSelectBlock) {
        self.chargeTypeSelectBlock(indexPath.row);
    }
}


#pragma mark - Getter
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.text = @"收支类别";
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.rowHeight = 44;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.scrollEnabled = NO;
        
        [_tableView ssj_setBorderWidth:1];
        [_tableView ssj_setBorderStyle:SSJBorderStyleTop];
        [_tableView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    }
    return _tableView;
}

- (UIImageView *)accessoryView {
    if (!_accessoryView) {
        _accessoryView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _accessoryView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    }
    return _accessoryView;
}

@end
