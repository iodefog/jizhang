//
//  SSJBookTypeViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/5/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBookTypeViewController.h"
#import "TPKeyboardAvoidingTableView.h"

#import "SSJBooksParentSelectCell.h"
#import "SSJFinancingGradientColorItem.h"

@interface SSJBookTypeViewController ()<UITableViewDelegate,UITableViewDataSource>
/**imageArray*/
@property (nonatomic, strong) NSArray *imageArray;

/**titleArray*/
@property (nonatomic, strong) NSArray *titleArray;

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

/**上一次选择的cell*/
@property (nonatomic, strong) SSJBooksParentSelectCell *lastSelectedCell;

@end

@implementation SSJBookTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNav];
    
    [self setUpTableView];
    [self setUpDataArray];
    [self updateAppearanceAfterThemeChanged];
}

- (void)setLastSelectedIndex:(NSInteger)lastSelectedIndex
{
    _lastSelectedIndex = lastSelectedIndex;
    static dispatch_once_t onceToken;
    __weak __typeof(self)weakSelf = self;
    dispatch_once(&onceToken, ^{
        [weakSelf.tableView reloadData];
    });
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.frame = CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM);
}

#pragma mark - UI
- (void)setUpNav {
    self.title = NSLocalizedString(@"记账场景", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"完成", nil) style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
}

- (void)setUpTableView {
    [self.view addSubview:self.tableView];
    [self.tableView ssj_clearExtendSeparator];
    //默认选择第一个
//    self.lastSelectedIndex = lastIndexPath.row;
//    self.shouldSelected = YES;
//    [self tableView:self.tableView didSelectRowAtIndexPath:lastIndexPath];
}

#pragma mark - dataArray
- (void)setUpDataArray {
    self.titleArray = @[@"日常",@"生意",@"旅行",@"装修",@"结婚"];//,@"育儿"
    self.imageArray = @[@"bk_moren",@"bk_shengyi",@"bk_lvxing",@"bk_zhuangxiu",@"bk_jiehun"];//,@"bk_yinger"
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.lastSelectedIndex != indexPath.row) {
        SSJBooksParentSelectCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
        self.lastSelectedCell.arrowImageView.hidden = YES;
        currentCell.arrowImageView.hidden = NO;
        self.lastSelectedIndex = indexPath.row;
        self.lastSelectedCell = currentCell;
        //更新选择的账本类型就是lastSelectedIndex
    }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kBookTypeChooseID = @"SSJBookTypeViewControllerId";
    SSJBooksParentSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:kBookTypeChooseID];
    if (!cell) {
        cell = [[SSJBooksParentSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kBookTypeChooseID];
    }

    if (self.lastSelectedIndex == indexPath.row) {
        self.lastSelectedCell = cell;
        cell.arrowImageView.hidden = NO;
    } else {
        cell.arrowImageView.hidden = YES;
    }
    [cell setImage:[self.imageArray ssj_safeObjectAtIndex:indexPath.row] title:[self.titleArray ssj_safeObjectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

#pragma mark - Event
- (void)rightButtonClicked:(UIButton *)btn {
    if (self.saveBooksBlock) {
        self.saveBooksBlock(self.lastSelectedIndex,[self.titleArray ssj_safeObjectAtIndex:self.lastSelectedIndex]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Lazy
- (TPKeyboardAvoidingTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] init];
        _tableView.rowHeight = 55;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
    }
    return _tableView;
}

- (void)updateAppearanceAfterThemeChanged {
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}
@end
