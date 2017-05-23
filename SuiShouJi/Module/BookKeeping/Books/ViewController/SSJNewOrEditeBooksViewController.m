//
//  SSJNewOrEditeBooksViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/5/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJNewOrEditeBooksViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "UIViewController+MMDrawerController.h"
#import "SSJBookTypeViewController.h"

#import "SSJCreditCardEditeCell.h"
#import "SSJBookColorSelectedViewController.h"

#import "SSJBooksTypeItem.h"
#import "SSJShareBookItem.h"

#import "SSJBooksTypeStore.h"
#import "SSJDataSynchronizer.h"

static NSString *SSJNewOrEditeBooksCellIdentifier = @"SSJNewOrEditeBooksCellIdentifier";

@interface SSJNewOrEditeBooksViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property (nonatomic, strong) NSArray <NSString *> *titleArray;

@property (nonatomic, strong) UITextField *bookNameTextField;

/**记账颜色*/
@property (nonatomic, strong) SSJFinancingGradientColorItem *gradientColorItem;

/**当前选择的账本类型indexPath.row*/
@property (nonatomic, assign) NSInteger currentBookType;

/**记账场景*/
@property (nonatomic, copy) NSString *bookParentStr;

/**tip*/
@property (nonatomic, copy) NSString *tipStr;

/**bookName*/
@property (nonatomic, copy) NSString *bookName;
@end

@implementation SSJNewOrEditeBooksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNav];
    [self setUpTableView];
    [self initalizedDataArray];
}

#pragma mark - UI
- (void)setUpNav {
    if ([self.bookItem isKindOfClass:[SSJBooksTypeItem class]]) {//个人账本
        if (((SSJBooksTypeItem *)self.bookItem).booksId.length) {
            self.title = NSLocalizedString(@"编辑个人账本", nil);
        } else {
            self.title = NSLocalizedString(@"新建个人账本", nil);
        }
        self.tipStr = NSLocalizedString(@"Tip：个人记账，账本仅自己可见", nil);
    } else if([self.bookItem isKindOfClass:[SSJShareBookItem class]]) { //共享账本
        if (((SSJShareBookItem *)self.bookItem).booksId.length) {
            self.title = NSLocalizedString(@"编辑共享账本", nil);
        } else {
            self.title = NSLocalizedString(@"新建共享账本", nil);
        }
        self.tipStr = NSLocalizedString(@"Tip：共同记账，账本可共享给ta", nil);
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"完成", nil) style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
}

- (void)setUpTableView {
    [self.view addSubview:self.tableView];
    [self.tableView ssj_clearExtendSeparator];
    [self.tableView registerClass:[SSJCreditCardEditeCell class] forCellReuseIdentifier:SSJNewOrEditeBooksCellIdentifier];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.view.width - 20, 44)];
    tipLabel.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_4];
    tipLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    tipLabel.text = self.tipStr;
    self.tableView.tableFooterView = tipLabel;
}

- (void)initalizedDataArray {
    self.titleArray = @[@"记账场景",@"账本名称",@"账本颜色"];
    if ([self.bookItem isKindOfClass:[SSJBooksTypeItem class]]) {//个人账本
        if (((SSJBooksTypeItem *)self.bookItem).booksId.length) {
            //编辑个人账本
//            [self editeBookData];
            self.currentBookType = ((SSJBooksTypeItem *)self.bookItem).booksParent;
//            self.gradientColorItem = ((SSJBooksTypeItem *)self.bookItem).booksColor;
           self.bookParentStr = [self bookParentStrWithKey:[NSString stringWithFormat:@"%ld",self.currentBookType]];
            self.bookName = ((SSJBooksTypeItem *)self.bookItem).booksName;
        } else {
            //新建个人账本
            [self newBookData];
        }
    } else if([self.bookItem isKindOfClass:[SSJShareBookItem class]]) { //共享账本
        if (((SSJShareBookItem *)self.bookItem).booksId.length) {
            //编辑共享账本
            self.currentBookType = ((SSJShareBookItem *)self.bookItem).booksParent;
//            self.gradientColorItem = ((SSJShareBookItem *)self.bookItem).booksColor;
            self.bookParentStr = [self bookParentStrWithKey:[NSString stringWithFormat:@"%ld",self.currentBookType]];
            self.bookName = ((SSJShareBookItem *)self.bookItem).booksName;
        } else {
            //新建共享账本
            [self newBookData];
        }
    }
}

- (void)newBookData {
    self.currentBookType = 0;
    self.bookParentStr = [self bookParentStrWithKey:[NSString stringWithFormat:@"%ld",self.currentBookType]];
    self.gradientColorItem = [[SSJFinancingGradientColorItem defualtColors] firstObject];
    self.bookName = @"";
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.frame = CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.mm_drawerController setMaximumLeftDrawerWidth:SSJSCREENWITH];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak __typeof(self)weakSelf = self;
    if (indexPath.row == 0) {
        //记账场景
        SSJBookTypeViewController *bookTypeVC = [[SSJBookTypeViewController alloc] init];
        if (!self.currentBookType) {
            self.currentBookType = 0;
        }
        bookTypeVC.lastSelectedIndex = self.currentBookType;
        
        bookTypeVC.saveBooksBlock = ^(NSInteger bookTypeIndex,NSString *bookName) {
            weakSelf.currentBookType = bookTypeIndex;
            weakSelf.bookParentStr = bookName;
            //更新选中账本场景
            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        };
        [self.navigationController pushViewController:bookTypeVC animated:YES];
    } else if (indexPath.row == 2) {
        //账本颜色
        SSJBookColorSelectedViewController *bookColorVC = [[SSJBookColorSelectedViewController alloc] init];
        //账本名称
        if (self.bookNameTextField.text.length) {
            bookColorVC.bookName = self.bookNameTextField.text;
        }
        bookColorVC.colorSelectedBlock = ^(SSJFinancingGradientColorItem *selectColor) {
            //更新选择账本颜色
            weakSelf.gradientColorItem = selectColor;
            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        };
        bookColorVC.bookColorItem = self.gradientColorItem;
        [self.navigationController pushViewController:bookColorVC animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJCreditCardEditeCell *cell = [tableView dequeueReusableCellWithIdentifier:SSJNewOrEditeBooksCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.cellTitle = [self.titleArray ssj_safeObjectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        cell.type = SSJCreditCardCellTypeDetail;
        cell.cellDetail = self.bookParentStr;
        cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.row == 1) {
        cell.type = SSJCreditCardCellTypeTextField;
        cell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入5字以内名称" attributes:@{NSForegroundColorAttributeName : [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        cell.customAccessoryType = UITableViewCellAccessoryNone;
        cell.textInput.text = self.bookName;
        self.bookNameTextField = cell.textInput;
    } else if (indexPath.row == 2) {
        cell.type = SSJCreditCardCellColorSelect;
        cell.colorItem = self.gradientColorItem;
        cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

#pragma mark - Event
- (void)rightButtonClicked:(id)sender{
    NSString *booksName = self.bookNameTextField.text;
    if (!booksName.length) {
        [CDAutoHideMessageHUD showMessage:@"请输入账本名称"];
        return;
    }
    if (booksName.length > 5) {
        [CDAutoHideMessageHUD showMessage:@"账本名称不能超过5个字"];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    if ([self.bookItem isKindOfClass:[SSJBooksTypeItem class]]) {//个人账本
        ((SSJBooksTypeItem *)self.bookItem).booksName = booksName;
        ((SSJBooksTypeItem *)self.bookItem).booksParent = self.currentBookType;
        ((SSJBooksTypeItem *)self.bookItem).booksColor =  self.gradientColorItem;
        [SSJBooksTypeStore saveBooksTypeItem:(SSJBooksTypeItem *)self.bookItem sucess:^{
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
            [[NSNotificationCenter defaultCenter] postNotificationName:SSJBooksTypeDidChangeNotification object:nil];
            
            if (_saveBooksBlock) {
                _saveBooksBlock(((SSJBooksTypeItem *)self.bookItem).booksId);
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
        }];


    } else if([self.bookItem isKindOfClass:[SSJShareBookItem class]]) { //共享账本
        ((SSJShareBookItem *)self.bookItem).booksName = booksName;
        ((SSJShareBookItem *)self.bookItem).booksParent = self.currentBookType;
        ((SSJShareBookItem *)self.bookItem).booksColor =  self.gradientColorItem;
        
        [SSJBooksTypeStore saveShareBooksTypeItem:(SSJShareBookItem *)self.bookItem sucess:^{
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
            [[NSNotificationCenter defaultCenter] postNotificationName:SSJBooksTypeDidChangeNotification object:nil];
            if (_saveBooksBlock) {
                _saveBooksBlock(((SSJShareBookItem *)self.bookItem).booksId);
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
            
        } failure:^(NSError *error) {
            [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
        }];
    }
}

#pragma mark - Lazy
- (TPKeyboardAvoidingTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    }
    return _tableView;
}

- (NSString *)bookParentStrWithKey:(NSString *)key {
    NSDictionary *dic = @{
                          @"0":@"日常",
                          @"1":@"育儿",
                          @"2":@"生意",
                          @"3":@"旅行",
                          @"4":@"装修",
                          @"5":@"结婚",
                          };
    if ([[dic allKeys] containsObject:key]) {
        return [dic objectForKey:key];
    } else {
        return @"日常";
    }
}

@end
