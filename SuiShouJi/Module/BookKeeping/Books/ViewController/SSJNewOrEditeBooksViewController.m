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

#import "SSJCreateOrDeleteBooksService.h"

static NSString *SSJNewOrEditeBooksCellIdentifier = @"SSJNewOrEditeBooksCellIdentifier";

@interface SSJNewOrEditeBooksViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property (nonatomic, strong) NSArray <NSString *> *titleArray;

@property (nonatomic, strong) UITextField *bookNameTextField;

/**记账颜色*/
@property (nonatomic, strong) SSJFinancingGradientColorItem *gradientColorItem;

/**当前选择的账本类型indexPath.row*/
@property (nonatomic, assign) SSJBooksType currentBookType;

/**记账场景*/
@property (nonatomic, copy) NSString *bookParentStr;

/**tip*/
@property (nonatomic, copy) NSString *tipStr;

/**bookName*/
@property (nonatomic, copy) NSString *bookName;

@property (nonatomic, strong) SSJCreateOrDeleteBooksService *createBookService;

/**编辑还是添新建为yes*/
@property (nonatomic, assign) BOOL editOrNew;
@end

@implementation SSJNewOrEditeBooksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNav];
    [self setUpTableView];
    [self initalizedDataArray];
    [self updateAppearanceAfterThemeChanged];//颜色
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.createBookService cancel];
}

#pragma mark - UI
- (void)setUpNav {
    if ([self.bookItem isKindOfClass:[SSJBooksTypeItem class]]) {//个人账本
        if (((SSJBooksTypeItem *)self.bookItem).booksId.length) {
            self.title = NSLocalizedString(@"编辑个人账本", nil);
            [SSJAnaliyticsManager event:@"accountbook_edit"];
            self.editOrNew = NO;
        } else {
            self.title = NSLocalizedString(@"新建个人账本", nil);
            self.editOrNew = YES;
        }
        self.tipStr = NSLocalizedString(@"  个人记账，账本仅自己可见", nil);
    } else if([self.bookItem isKindOfClass:[SSJShareBookItem class]]) { //共享账本
        if (((SSJShareBookItem *)self.bookItem).booksId.length) {
            self.title = NSLocalizedString(@"编辑共享账本", nil);
            self.editOrNew = NO;
            [SSJAnaliyticsManager event:@"sb_edit_share_books"];
        } else {
            self.title = NSLocalizedString(@"新建共享账本", nil);
            self.editOrNew = YES;
        }
        self.tipStr = NSLocalizedString(@"  共同记账，账本可共享给ta", nil);
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"完成", nil) style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
}

- (void)setUpTableView {
    [self.view addSubview:self.tableView];
    [self.tableView ssj_clearExtendSeparator];
    [self.tableView registerClass:[SSJCreditCardEditeCell class] forCellReuseIdentifier:SSJNewOrEditeBooksCellIdentifier];
    //分割线补齐
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)initalizedDataArray {
    self.titleArray = @[@"账本名称",@"记账场景",@"账本颜色"];
    if ([self.bookItem isKindOfClass:[SSJBooksTypeItem class]]) {//个人账本
        if (((SSJBooksTypeItem *)self.bookItem).booksId.length) {
            //编辑个人账本
//            [self editeBookData];
            self.currentBookType = ((SSJBooksTypeItem *)self.bookItem).booksParent;
            self.gradientColorItem = ((SSJBooksTypeItem *)self.bookItem).booksColor;
           self.bookParentStr = [self bookParentStrWithKey:self.currentBookType];
            self.bookName = ((SSJBooksTypeItem *)self.bookItem).booksName;
        } else {
            //新建个人账本
            [self newBookData];
            [self.bookNameTextField becomeFirstResponder];
        }
    } else if([self.bookItem isKindOfClass:[SSJShareBookItem class]]) { //共享账本
        if (((SSJShareBookItem *)self.bookItem).booksId.length) {
            //编辑共享账本
            self.currentBookType = ((SSJShareBookItem *)self.bookItem).booksParent;//;
            self.gradientColorItem = ((SSJShareBookItem *)self.bookItem).booksColor;
            self.bookParentStr = [self bookParentStrWithKey:self.currentBookType];
            self.bookName = ((SSJShareBookItem *)self.bookItem).booksName;
        } else {
            //新建共享账本
            [self newBookData];
            [self.bookNameTextField becomeFirstResponder];
        }
    }
}

- (void)newBookData {
    self.currentBookType = SSJBooksTypeDaily;
    self.bookParentStr = [self bookParentStrWithKey:self.currentBookType];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak __typeof(self)weakSelf = self;
    if (indexPath.row == 1 && self.editOrNew == YES) {
        //记账场景
        SSJBookTypeViewController *bookTypeVC = [[SSJBookTypeViewController alloc] init];
        bookTypeVC.booksType = self.currentBookType;
        bookTypeVC.isShareBook = [self.bookItem isKindOfClass:[SSJShareBookItem class]];
        bookTypeVC.saveBooksBlock = ^(SSJBooksType booksType, NSString *bookName) {
            weakSelf.currentBookType = booksType;
            weakSelf.bookParentStr = bookName;
            //更新选中账本场景
            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        };
        [self.navigationController pushViewController:bookTypeVC animated:YES];
    } else if (indexPath.row == 2) {
        //账本颜色
        SSJBookColorSelectedViewController *bookColorVC = [[SSJBookColorSelectedViewController alloc] init];
        [SSJAnaliyticsManager event:@"sb_create_share_book_bookcolor"];
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

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.view.width - 20, 44)];
//    tipLabel.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_4];
//    tipLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
//    
//    tipLabel.text = self.tipStr;
//    tipLabel.backgroundColor = [UIColor clearColor];
//    return tipLabel;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 44;
//}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJCreditCardEditeCell *cell = [tableView dequeueReusableCellWithIdentifier:SSJNewOrEditeBooksCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.cellTitle = [self.titleArray ssj_safeObjectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        cell.type = SSJCreditCardCellTypeTextField;
        cell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入5字以内名称" attributes:@{NSForegroundColorAttributeName : [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        cell.customAccessoryType = UITableViewCellAccessoryNone;
        cell.textInput.text = self.bookName;
        cell.textInput.clearButtonMode = UITextFieldViewModeAlways;
        cell.textInput.returnKeyType = UIReturnKeyDone;
        self.bookNameTextField = cell.textInput;
    } else if (indexPath.row == 1) {
        cell.type = SSJCreditCardCellTypeDetail;
        cell.cellDetail = self.bookParentStr;
        if (self.editOrNew == YES) {
            cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.customAccessoryType = UITableViewCellAccessoryNone;
        }
        
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


#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service
{
    if ([service.returnCode isEqualToString:@"1"]) {
        __weak __typeof(self)weakSelf = self;
        SSJShareBookItem *shareItem = [SSJShareBookItem mj_objectWithKeyValues:self.createBookService.shareBookDic];
        SSJFinancingGradientColorItem *gradientColor = [[SSJFinancingGradientColorItem alloc] init];
       NSArray *gradientArr = [self.createBookService.shareBookDic [@"cbookscolor"] componentsSeparatedByString:@","];
        if (gradientArr.count >1) {
            gradientColor.startColor = [gradientArr ssj_safeObjectAtIndex:0];
            gradientColor.endColor = [gradientArr ssj_safeObjectAtIndex:1];
        } else if (gradientArr.count == 1) {
            gradientColor.startColor = gradientColor.endColor = [gradientArr ssj_safeObjectAtIndex:0];
        }
        
        shareItem.booksColor = gradientColor;
        shareItem.booksName = weakSelf.bookName;
        weakSelf.bookItem = shareItem;
        [SSJBooksTypeStore saveShareBooksTypeItem:shareItem WithshareMember:self.createBookService.shareMemberArray shareFriendsMarks:self.createBookService.shareFriendsMarkArray ShareBookOperate:ShareBookOperateCreate sucess:^{
            if (_saveBooksBlock) {
                _saveBooksBlock(((SSJShareBookItem *)self.bookItem).booksId);
            }
            SSJSaveBooksCategory(SSJBooksCategoryPublic);
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
        }];
    }
}

#pragma mark - Event
- (void)rightButtonClicked:(id)sender{
    self.bookName = self.bookNameTextField.text;
    if (!self.bookName.length) {
        [CDAutoHideMessageHUD showMessage:@"请输入账本名称"];
        return;
    }
    if (self.bookName.length > 5) {
        [CDAutoHideMessageHUD showMessage:@"账本名称不能超过5个字"];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    self.bookItem.booksName = self.bookName;
    self.bookItem.booksParent = self.currentBookType;
    self.bookItem.booksColor = self.gradientColorItem;
    if ([self.bookItem isKindOfClass:[SSJBooksTypeItem class]]) {//个人账本
        [SSJBooksTypeStore saveBooksTypeItem:(SSJBooksTypeItem *)self.bookItem sucess:^{
            if (_saveBooksBlock) {
                _saveBooksBlock(((SSJBooksTypeItem *)self.bookItem).booksId);
            }
            SSJSaveBooksCategory(SSJBooksCategoryPersional);
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
        }];
        
    } else if([self.bookItem isKindOfClass:[SSJShareBookItem class]]) { //共享账本
        //编辑
        if (self.bookItem.booksId.length) {
            [SSJBooksTypeStore saveShareBooksTypeItem:self.bookItem WithshareMember:nil shareFriendsMarks:nil ShareBookOperate:ShareBookOperateEdite sucess:^{
                [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } failure:^(NSError *error) {
                [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
            }];
        } else {
            //新建
            [self.createBookService createShareBookWithBookItem:(SSJShareBookItem<SSJBooksItemProtocol> *)self.bookItem];
        }
    }
}

#pragma mark - Lazy
- (TPKeyboardAvoidingTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 55;
        
        UIButton *tipBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 0, self.view.width - 20, 44)];;
        tipBtn.enabled = NO;
        tipBtn.titleLabel.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_4];
        [tipBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] forState:UIControlStateDisabled];
        [tipBtn setImage:[UIImage imageNamed:@"warning"] forState:UIControlStateDisabled];
        [tipBtn setTitle:self.tipStr forState:UIControlStateDisabled];
        tipBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        tipBtn.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = tipBtn;
    }
    return _tableView;
}

- (SSJCreateOrDeleteBooksService *)createBookService {
    if (!_createBookService) {
        _createBookService = [[SSJCreateOrDeleteBooksService alloc] initWithDelegate:self];
    }
    return _createBookService;
}

- (NSString *)bookParentStrWithKey:(SSJBooksType)key {
    switch (key) {
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
            
        default:
            return @"日常";
            break;
    }
}

#pragma mark - Notice
- (void)updateAppearanceAfterThemeChanged {
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}

@end
