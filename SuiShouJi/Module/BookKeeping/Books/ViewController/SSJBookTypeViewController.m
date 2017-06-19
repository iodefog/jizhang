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

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

/**上一次选择的cell*/
@property (nonatomic, strong) SSJBooksParentSelectCell *lastSelectedCell;

@end

@implementation SSJBookTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNav];
    
    [self setUpTableView];
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
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
    {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
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
    [cell setImage:[[self images] ssj_safeObjectAtIndex:indexPath.row] title:[[self titles] ssj_safeObjectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self titles].count;
}

#pragma mark - Event
- (void)rightButtonClicked:(UIButton *)btn {
    if (self.saveBooksBlock) {
        self.saveBooksBlock(self.lastSelectedIndex,[[self titles] ssj_safeObjectAtIndex:self.lastSelectedIndex]);
    }
        switch (self.lastSelectedIndex) {
            case 0:
                [SSJAnaliyticsManager event:self.isShareBook ? @"sb_book_category_richang" : @"book_type_richang"];
                break;
    
            case 1:
                [SSJAnaliyticsManager event:self.isShareBook ? @"sb_book_category_shengyi" : @"book_type_shengyi"];
                break;
    
            case 2:
                [SSJAnaliyticsManager event:self.isShareBook ? @" sb_book_category_jiehun" : @"book_type_jiehun"];
                break;
    
            case 3:
                [SSJAnaliyticsManager event:self.isShareBook ? @" sb_book_category_zhuangxiu" : @"book_type_zhuangxiu"];
                break;
    
            case 4:
                [SSJAnaliyticsManager event:self.isShareBook ? @"sb_book_category_lvxing" : @"book_type_lvxing"];
                break;
                
            default:
                break;
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

#pragma mark - Private
- (NSArray *)titles {
    return @[@"日常",@"生意",@"旅行",@"装修",@"结婚"];//,@"育儿"
}

- (NSArray *)images {
    return @[@"bk_moren",@"bk_shengyi",@"bk_lvxing",@"bk_zhuangxiu",@"bk_jiehun"];//,@"bk_yinger"
}

@end
