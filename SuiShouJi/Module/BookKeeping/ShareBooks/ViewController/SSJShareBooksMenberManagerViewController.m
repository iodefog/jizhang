//
//  SSJShareBooksMenberManagerViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/15.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksMenberManagerViewController.h"
#import "SSJSharebooksInviteViewController.h"
#import "SSJSharebooksMemberDetailViewController.h"

#import "SSJSharebooksMemberCollectionViewCell.h"
#import "SSJBooksTypeDeletionAuthCodeAlertView.h"

#import "SSJShareBooksStore.h"
#import "SSJCreateOrDeleteBooksService.h"
#import "SSJBooksTypeStore.h"

static NSString * SSJSharebooksMemberCellIdentifier = @"SSJSharebooksMemberCellIdentifier";

#define ITEM_SPACE 25
#define ITEM_SIZE_HEIGHT 90

#define ITEM_SIZE_WIDTH (self.view.width - 28 * 3 - 30) / 4

#define BOTTOM_MARGIN 18.f

#define TOP_MARGIN 14.f


@interface SSJShareBooksMenberManagerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic, strong) UICollectionView *collectionView;

@property(nonatomic, strong) UIButton *deleteButton;

@property(nonatomic, strong) NSArray <SSJShareBookMemberItem *> *items;

@property(nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property(nonatomic, strong) SSJBooksTypeDeletionAuthCodeAlertView *deleteComfirmAlert;

@property(nonatomic, strong) SSJCreateOrDeleteBooksService *deleteService;

@end

@implementation SSJShareBooksMenberManagerViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"账本成员";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.deleteButton];
    [self.view updateConstraintsIfNeeded];
//    [self.view setNeedsUpdateConstraints];
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
    [SSJShareBooksStore queryTheMemberListForTheShareBooks:self.item Success:^(NSArray<SSJShareBookMemberItem *> *result) {
        weakSelf.items = result;
        [weakSelf.view setNeedsUpdateConstraints];
//        [weakSelf.view updateConstraintsIfNeeded];
        [weakSelf.collectionView reloadData];
    } failure:NULL];
}

- (void)updateViewConstraints {
//    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(self.view);
//        make.top.mas_equalTo(SSJ_NAVIBAR_BOTTOM);
//        make.width.mas_equalTo(self.view);
//    }];
    
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(self.view);
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
    
    [self updateHeightForCollectionView];
    
    [super updateViewConstraints];

}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    if ([service.returnCode isEqualToString:@"1"]) {
        @weakify(self);
        [SSJBooksTypeStore deleteShareBooksWithShareCharge:self.deleteService.shareChargeArray shareMember:self.deleteService.shareMemberArray bookId:self.item.booksId sucess:^(BOOL bookstypeHasChange){
            @strongify(self);
            [CDAutoHideMessageHUD showMessage:@"退出成功"];
            [SSJAnaliyticsManager event:@"sb_delete_share_books"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } failure:NULL];
    }
}


#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.items.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJShareBookMemberItem *item = [self.items objectAtIndex:indexPath.item];
    SSJSharebooksMemberCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SSJSharebooksMemberCellIdentifier forIndexPath:indexPath];
    cell.memberItem = item;
    return cell;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJShareBookMemberItem *item = [self.items objectAtIndex:indexPath.item];
    if ([item.memberId isEqualToString:@"-1"]) {
        SSJSharebooksInviteViewController *inviteVc = [[SSJSharebooksInviteViewController alloc] init];
        [SSJAnaliyticsManager event:@"sb_add_share_books_member"];
        inviteVc.item = self.item;
        [self.navigationController pushViewController:inviteVc animated:YES];
    } else {
        SSJSharebooksMemberDetailViewController *memberDetailVc = [[SSJSharebooksMemberDetailViewController alloc] init];
        memberDetailVc.memberId = item.memberId;
        memberDetailVc.booksId = item.booksId;
        memberDetailVc.adminId = item.adminId;
        [self.navigationController pushViewController:memberDetailVc animated:YES];
    }
}


#pragma mark - Getter
- (UICollectionView *)collectionView{
    if (_collectionView==nil) {
        _collectionView =[[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        _collectionView.dataSource=self;
        _collectionView.delegate=self;
        [_collectionView registerClass:[SSJSharebooksMemberCollectionViewCell class] forCellWithReuseIdentifier:SSJSharebooksMemberCellIdentifier];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.minimumInteritemSpacing = 28;
    flowLayout.minimumLineSpacing = ITEM_SPACE;
    flowLayout.itemSize = CGSizeMake(ITEM_SIZE_WIDTH, ITEM_SIZE_HEIGHT);
    flowLayout.sectionInset = UIEdgeInsetsMake(TOP_MARGIN, 15, BOTTOM_MARGIN, 15);
    return flowLayout;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setTitle:@"退出账本" forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
        if (SSJ_CURRENT_THEME.throughScreenButtonBackGroudColor.length) {
            [_deleteButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.throughScreenButtonBackGroudColor alpha:SSJ_CURRENT_THEME.throughScreenButtonAlpha] forState:UIControlStateNormal];
        } else {
            [_deleteButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor alpha:0.8] forState:UIControlStateNormal];
        }
        _deleteButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_deleteButton ssj_setBorderWidth:1];
        [_deleteButton ssj_setBorderStyle:SSJBorderStyleTop];
        [_deleteButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        [_deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (SSJBooksTypeDeletionAuthCodeAlertView *)deleteComfirmAlert {
    if (!_deleteComfirmAlert) {
        _deleteComfirmAlert = [[SSJBooksTypeDeletionAuthCodeAlertView alloc] init];
        NSMutableAttributedString *atrrStr = [[NSMutableAttributedString alloc] initWithString:@"确认退出此共享账本,\n请输入下列验证码"];
        [atrrStr addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4] range:NSMakeRange(0, atrrStr.length)];
        [atrrStr addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:NSMakeRange(0, atrrStr.length)];
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.alignment = NSTextAlignmentCenter;
        paragraph.lineSpacing = 10;
        [atrrStr addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, atrrStr.length)];
        _deleteComfirmAlert.message = atrrStr;
        @weakify(self);
        _deleteComfirmAlert.finishVerification = ^{
            @strongify(self);
            [self.deleteService deleteShareBookWithBookId:self.item.booksId memberId:SSJUSERID() memberState:SSJShareBooksMemberStateQuitted];
        };
    }
    return _deleteComfirmAlert;
}

- (SSJCreateOrDeleteBooksService *)deleteService {
    if (!_deleteService) {
        _deleteService = [[SSJCreateOrDeleteBooksService alloc] initWithDelegate:self];
    }
    return _deleteService;
}

#pragma mark - Event
- (void)deleteButtonClicked:(id)sender {
    [self.deleteComfirmAlert show];
    [SSJAnaliyticsManager event:@"sb_quit_share_books"];
}

#pragma mark - Private
- (void)updateHeightForCollectionView {
    if (!self.items || !self.items.count) {
        return;
    }
    
    
    NSInteger rowCount = ceil((double)self.items.count / 4.f);
    
    float height = BOTTOM_MARGIN + TOP_MARGIN + rowCount * ITEM_SIZE_HEIGHT + (rowCount - 1) * ITEM_SPACE;
    
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view);
        make.top.mas_equalTo(SSJ_NAVIBAR_BOTTOM);
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(height);
    }];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    self.collectionView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    if (SSJ_CURRENT_THEME.throughScreenButtonBackGroudColor.length) {
        [self.deleteButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.throughScreenButtonBackGroudColor alpha:SSJ_CURRENT_THEME.throughScreenButtonAlpha] forState:UIControlStateNormal];
    } else {
        [self.deleteButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor alpha:0.8] forState:UIControlStateNormal];
    }
    [self.deleteButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    [self.deleteButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
