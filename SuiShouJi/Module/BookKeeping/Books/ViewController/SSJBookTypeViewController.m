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

@property (nonatomic, strong) NSArray<NSNumber *> *booksTypes;

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

/**上一次选择的cell*/
@property (nonatomic, strong) SSJBooksParentSelectCell *lastSelectedCell;

@end

@implementation SSJBookTypeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.booksTypes = @[@(SSJBooksTypeDaily),
                            @(SSJBooksTypeBaby),
                            @(SSJBooksTypeBusiness),
                            @(SSJBooksTypeTravel),
                            @(SSJBooksTypeDecoration),
                            @(SSJBooksTypeMarriage)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNav];
    
    [self setUpTableView];
    [self updateAppearanceAfterThemeChanged];
}

//- (void)setLastSelectedIndex:(NSInteger)lastSelectedIndex
//{
//    _lastSelectedIndex = lastSelectedIndex;
//    static dispatch_once_t onceToken;
//    __weak __typeof(self)weakSelf = self;
//    dispatch_once(&onceToken, ^{
//        [weakSelf.tableView reloadData];
//    });
//}

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
    SSJBooksType selectedType = [[self.booksTypes ssj_safeObjectAtIndex:indexPath.row] integerValue];
    if (self.booksType != selectedType) {
        SSJBooksParentSelectCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
        self.lastSelectedCell.arrowImageView.hidden = YES;
        currentCell.arrowImageView.hidden = NO;
        self.booksType = selectedType;
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

    if (self.booksType == [[self.booksTypes ssj_safeObjectAtIndex:indexPath.row] integerValue]) {
        self.lastSelectedCell = cell;
        cell.arrowImageView.hidden = NO;
    } else {
        cell.arrowImageView.hidden = YES;
    }
    SSJBooksType type = [[self.booksTypes ssj_safeObjectAtIndex:indexPath.row] integerValue];
    [cell setImage:[self imageNameForBooksType:type] title:[self titleForBooksType:type]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.booksTypes.count;
}

#pragma mark - Event
- (void)rightButtonClicked:(UIButton *)btn {
    if (self.saveBooksBlock) {
        self.saveBooksBlock(self.booksType, [self titleForBooksType:self.booksType]);
    }
    [self eventStatistics];
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
- (NSString *)titleForBooksType:(SSJBooksType)type {
    switch (type) {
        case SSJBooksTypeDaily:
            return @"日常";
            break;
            
        case SSJBooksTypeBusiness:
            return @"生意";
            break;
            
        case SSJBooksTypeMarriage:
            return @"结婚";
            break;
            
        case SSJBooksTypeDecoration:
            return @"装修";
            break;
            
        case SSJBooksTypeTravel:
            return @"旅行";
            break;
            
        case SSJBooksTypeBaby:
            return @"宝宝";
            break;
    }
}

- (NSString *)imageNameForBooksType:(SSJBooksType)type {
    switch (type) {
        case SSJBooksTypeDaily:
            return @"bk_moren";
            break;
            
        case SSJBooksTypeBusiness:
            return @"bk_shengyi";
            break;
            
        case SSJBooksTypeMarriage:
            return @"bk_jiehun";
            break;
            
        case SSJBooksTypeDecoration:
            return @"bk_zhuangxiu";
            break;
            
        case SSJBooksTypeTravel:
            return @"bk_lvxing";
            break;
            
        case SSJBooksTypeBaby:
#warning TODO
            return @"";
            break;
    }
}

- (void)eventStatistics {
    switch (self.booksType) {
        case SSJBooksTypeDaily:
            [SSJAnaliyticsManager event:self.isShareBook ? @"sb_book_category_richang" : @"book_type_richang"];
            break;
            
        case SSJBooksTypeBusiness:
            [SSJAnaliyticsManager event:self.isShareBook ? @"sb_book_category_shengyi" : @"book_type_shengyi"];
            break;
            
        case SSJBooksTypeMarriage:
            [SSJAnaliyticsManager event:self.isShareBook ? @" sb_book_category_jiehun" : @"book_type_jiehun"];
            break;
            
        case SSJBooksTypeDecoration:
            [SSJAnaliyticsManager event:self.isShareBook ? @" sb_book_category_zhuangxiu" : @"book_type_zhuangxiu"];
            break;
            
        case SSJBooksTypeTravel:
            [SSJAnaliyticsManager event:self.isShareBook ? @"sb_book_category_lvxing" : @"book_type_lvxing"];
            break;
            
        case SSJBooksTypeBaby:
#warning TODO
            
            break;
    }
}

@end
