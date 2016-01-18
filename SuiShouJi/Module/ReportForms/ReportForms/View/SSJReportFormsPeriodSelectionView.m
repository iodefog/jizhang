//
//  SSJReportFormsPeriodSelectionView.m
//  SuiShouJi
//
//  Created by old lang on 16/1/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsPeriodSelectionView.h"
#import "SSJReportFormsIncomeAndPayCell.h"

static NSString *kCellID = @"cellID";

@interface SSJReportFormsPeriodSelectionView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) SSJReportFormsPeriodType periodType;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UIView *leftView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIImageView *accessoryView;

@property (nonatomic, strong) NSIndexPath *selectedIndex;

@property (nonatomic) CGFloat fromTop;

@end

@implementation SSJReportFormsPeriodSelectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.leftView];
        [self addSubview:self.tableView];
        
        self.backgroundColor = [UIColor whiteColor];
        self.selectedIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return self;
}

- (void)layoutSubviews {
    self.leftView.frame = CGRectMake(0, 0, 60, self.height);
    [self.leftView ssj_relayoutBorder];
    
    CGFloat gap = 5;
    CGFloat imageTop = (self.leftView.height - self.imageView.height - self.label.height - gap) * 0.5;
    self.imageView.top = imageTop;
    self.label.top = self.imageView.bottom + gap;
    self.label.centerX = self.imageView.centerX = self.leftView.width * 0.5;
    
    self.tableView.frame = CGRectMake(self.leftView.width, 0, self.width - self.leftView.width, self.height);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (!cell) {
        cell = [[SSJBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"月";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"年";
    }
    cell.accessoryView = [indexPath compare:self.selectedIndex] == NSOrderedSame ? self.accessoryView : nil;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row == 0) {
        self.periodType = SSJReportFormsPeriodTypeMonth;
    } else if (indexPath.row == 1) {
        self.periodType = SSJReportFormsPeriodTypeYear;
    }
    
    if (self.selectionHandler) {
        self.selectionHandler(self, self.periodType);
    }
    
    self.selectedIndex = indexPath;
    [self.tableView reloadData];
}

- (void)showInView:(UIView *)view fromTop:(CGFloat)top animated:(BOOL)animated {
    if (!view) {
        return;
    }
    
    self.bottom = top;
    [view addSubview:self];
    [UIView animateWithDuration:(animated ? 0.25 : 0) delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.top = top;
    } completion:NULL];
    self.fromTop = top;
}

- (void)dismiss:(BOOL)animated {
    if (!self.superview) {
        return;
    }
    
    [UIView animateWithDuration:(animated ? 0.25 : 0) delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.bottom = self.fromTop;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (BOOL)isShowed {
    return self.superview != nil;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reportForms_period"]];
    }
    return _imageView;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:15];
        _label.text = @"周期";
        [_label sizeToFit];
    }
    return _label;
}

- (UIView *)leftView {
    if (!_leftView) {
        _leftView = [[UIView alloc] init];
        [_leftView addSubview:self.imageView];
        [_leftView addSubview:self.label];
        [_leftView ssj_setBorderStyle:SSJBorderStyleRight | SSJBorderStyleBottom];
        [_leftView ssj_setBorderWidth:1];
        [_leftView ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
    }
    return _leftView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.rowHeight = 55;
        _tableView.sectionHeaderHeight = 0;
        _tableView.sectionFooterHeight = 0;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorColor = SSJ_DEFAULT_SEPARATOR_COLOR;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (UIImageView *)accessoryView {
    if (!_accessoryView) {
        _accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
    }
    return _accessoryView;
}

@end
