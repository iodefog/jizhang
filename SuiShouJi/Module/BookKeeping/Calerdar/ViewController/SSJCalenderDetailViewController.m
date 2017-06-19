
//
//  SSJCalenderDetailViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCalenderDetailViewController.h"
#import "SSJRecordMakingViewController.h"
#import "SSJImaageBrowseViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "SSJReportFormsViewController.h"

#import "SSJCalenderTableViewCell.h"
#import "SSJCalenderDetailInfoCell.h"
#import "SSJCalenderDetailPhotoCell.h"
#import "SSJChargeImageBrowseView.h"

#import "SSJBooksTypeItem.h"
#import "SSJChargeMemBerItem.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "SSJBooksTypeStore.h"
#import "SSJCalenderHelper.h"

static NSString *const kSSJCalenderTableViewCellId = @"kSSJCalenderTableViewCellId";
static NSString *const kSSJCalenderDetailInfoCellId = @"kSSJCalenderDetailInfoCellId";
static NSString *const kSSJCalenderDetailPhotoCellId = @"kSSJCalenderDetailPhotoCellId";

@interface SSJCalenderDetailViewController ()

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, strong) UIButton *editBtn;

@property (nonatomic, strong) UILabel *tipLab;

@end

@implementation SSJCalenderDetailViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.statisticsTitle = @"流水详情";
        self.title = @"详情";
        self.items = [NSMutableArray array];
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom = self.editBtn.height;
    self.tableView.contentInset = insets;
    self.tableView.tableFooterView = self.tipLab;
    [self registerCellClass];
    
    [self.view addSubview:self.editBtn];
    self.editBtn.hidden = YES;
    
    [self updateAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseCellItem *item = [self.items ssj_objectAtIndexPath:indexPath];
    SSJBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellReuseIdForItemClass:[item class]] forIndexPath:indexPath];
    cell.cellItem = item;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SSJBaseCellItem *item = [self.items ssj_objectAtIndexPath:indexPath];
    if ([item isKindOfClass:[SSJCalenderTableViewCellItem class]]
        || [item isKindOfClass:[SSJCalenderDetailInfoCellItem class]]) {
        return 54;
    } else if ([item isKindOfClass:[SSJCalenderDetailPhotoCellItem class]]) {
        return 180;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 12;
    } else {
        return 0.1;
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseCellItem *item = [self.items ssj_objectAtIndexPath:indexPath];
    if ([item isKindOfClass:[SSJCalenderDetailPhotoCellItem class]]) {
        SSJCalenderDetailPhotoCellItem *photoItem = (SSJCalenderDetailPhotoCellItem *)item;
        [UIImage ssj_loadUrl:photoItem.photoPath compeltion:^(NSError *error, UIImage *image) {
            if (image) {
                [SSJChargeImageBrowseView showWithImage:image];
            }
        }];
    }
}

#pragma mark - LazyLoading
- (UIButton *)editBtn {
    if (!_editBtn) {
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editBtn.frame = CGRectMake(0, self.view.height - 54, self.view.width, 54);
        [_editBtn ssj_setBorderStyle:SSJBorderStyleTop];
        _editBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_editBtn setTitle:NSLocalizedString(@"修改", nil) forState:UIControlStateNormal];
        @weakify(self);
        [[_editBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            SSJRecordMakingViewController *recordMakingVc = [[SSJRecordMakingViewController alloc]init];
            recordMakingVc.item = self.item;
            [self.navigationController pushViewController:recordMakingVc animated:YES];
        }];
    }
    return _editBtn;
}

- (UILabel *)tipLab {
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
        _tipLab.backgroundColor = [UIColor clearColor];
        _tipLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _tipLab;
}

#pragma mark - Private
- (NSString *)cellReuseIdForItemClass:(Class)itemClass {
    if (itemClass == [SSJCalenderTableViewCellItem class]) {
        return kSSJCalenderTableViewCellId;
    } else if (itemClass == [SSJCalenderDetailInfoCellItem class]) {
        return kSSJCalenderDetailInfoCellId;
    } else if (itemClass == [SSJCalenderDetailPhotoCellItem class]) {
        return kSSJCalenderDetailPhotoCellId;
    } else {
        return nil;
    }
}

- (void)registerCellClass {
    [self.tableView registerClass:[SSJCalenderTableViewCell class] forCellReuseIdentifier:kSSJCalenderTableViewCellId];
    [self.tableView registerClass:[SSJCalenderDetailInfoCell class] forCellReuseIdentifier:kSSJCalenderDetailInfoCellId];
    [self.tableView registerClass:[SSJCalenderDetailPhotoCell class] forCellReuseIdentifier:kSSJCalenderDetailPhotoCellId];
}

- (RACSignal *)loadChargeDetailSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJCalenderHelper queryChargeDetailWithId:self.item.ID success:^(SSJBillingChargeCellItem * _Nonnull chargeItem) {
            [self.view ssj_hideLoadingIndicator];
            self.item = chargeItem;
            [self organiseData];
            [self.tableView reloadData];
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (RACSignal *)loadShareBookStateSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (self.item.idType == SSJChargeIdTypeShareBooks
            && [self.item.userId isEqualToString:SSJUSERID()]) {
            [SSJCalenderHelper queryShareBookStateWithBooksId:self.item.booksId memberId:self.item.userId success:^(SSJShareBooksMemberState state) {
                if (state != SSJShareBooksMemberStateNormal) {
                    [self updateTipWithText:@"Tip：已退出账本，无法修改流水"];
                } else {
                    self.editBtn.hidden = NO;
                }
                [subscriber sendNext:@(state == SSJShareBooksMemberStateNormal)];
                [subscriber sendCompleted];
            } failure:^(NSError * _Nonnull error) {
                [subscriber sendError:error];
            }];
        } else if (self.item.idType == SSJChargeIdTypeShareBooks
                   && ![self.item.userId isEqualToString:SSJUSERID()]) {
            [self updateTipWithText:@"Tip：无法修改他人的流水"];
            [subscriber sendNext:@(NO)];
            [subscriber sendCompleted];
        } else {
            self.editBtn.hidden = NO;
            [subscriber sendNext:@(YES)];
            [subscriber sendCompleted];
        }
        return nil;
    }];
}

- (void)updateTipWithText:(NSString *)text {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.firstLineHeadIndent = 10;
    NSAttributedString *tip = [[NSAttributedString alloc] initWithString:NSLocalizedString(text, nil) attributes:@{NSParagraphStyleAttributeName:style}];
    self.tipLab.attributedText = tip;
}

- (void)loadData {
    if (self.items.count == 0) {
        [self.view ssj_showLoadingIndicator];
    }
    
    [[[self loadChargeDetailSignal] then:^RACSignal *{
        return [self loadShareBookStateSignal];
    }] subscribeNext:^(NSNumber *canEditValue) {
        if ([canEditValue boolValue]) {
            self.editBtn.hidden = NO;
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClicked:)];
        } else {
            self.editBtn.hidden = YES;
            self.navigationItem.rightBarButtonItem = nil;
        }
    } error:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showError:error];
    } completed:^{
        [self.view ssj_hideLoadingIndicator];
    }];
}

/**
 *  数据库中删除流水
 */
- (void)deleteCharge {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [SSJCalenderHelper deleteChargeWithItem:self.item success:^{
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if (self.deleteHandler) {
            self.deleteHandler();
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError * _Nonnull error) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [SSJAlertViewAdapter showError:error];
    }];
}

- (void)organiseData {
    [self.items removeAllObjects];
    
    NSMutableArray *section_1 = [NSMutableArray array];
    [self.items addObject:section_1];
    
    SSJCalenderTableViewCellItem *moneyItem = [[SSJCalenderTableViewCellItem alloc] init];
    moneyItem.billImage = [[UIImage imageNamed:self.item.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    moneyItem.billColor = [UIColor ssj_colorWithHex:self.item.colorValue];
    moneyItem.billName = self.item.typeName;
    moneyItem.money = self.item.money;
    [section_1 addObject:moneyItem];
    
    if (self.item.chargeImage.length) {
        SSJCalenderDetailPhotoCellItem *photoItem = [[SSJCalenderDetailPhotoCellItem alloc] init];
        if ([[NSFileManager defaultManager] fileExistsAtPath:SSJImagePath(self.item.chargeImage)]) {
            photoItem.photoPath = [NSURL fileURLWithPath:SSJImagePath(self.item.chargeImage)];
        } else {
            photoItem.photoPath = [NSURL URLWithString:SSJGetChargeImageUrl(self.item.chargeImage)];
        }
        [section_1 addObject:photoItem];
    }
    
    if (self.item.chargeMemo.length) {
        SSJCalenderDetailInfoCellItem *memoItem = [[SSJCalenderDetailInfoCellItem alloc] init];
        memoItem.leftText = @"备注";
        memoItem.rightText = self.item.chargeMemo;
        [section_1 addObject:memoItem];
    }
    
    NSMutableArray *section_2 = [NSMutableArray array];
    [self.items addObject:section_2];
    
    SSJCalenderDetailInfoCellItem *memberItem = [[SSJCalenderDetailInfoCellItem alloc] init];
    memberItem.leftText = @"成员";
    if (self.item.idType == SSJChargeIdTypeShareBooks) {
        memberItem.rightText = [self.item.userId isEqualToString:SSJUSERID()] ? @"我" : self.item.memberNickname;
    } else {
        memberItem.rightText = [[self.item.membersItem valueForKeyPath:@"memberName"] componentsJoinedByString:@"，"];
    }
    memberItem.separatorInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    [section_2 addObject:memberItem];
    
    SSJCalenderDetailInfoCellItem *dateItem = [[SSJCalenderDetailInfoCellItem alloc] init];
    dateItem.leftText = @"时间";
    dateItem.rightText = [NSString stringWithFormat:@"%@ %@", self.item.billDate, self.item.billDetailDate];
    dateItem.separatorInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    [section_2 addObject:dateItem];
    
    if (self.item.fundName) {
        SSJCalenderDetailInfoCellItem *fundItem = [[SSJCalenderDetailInfoCellItem alloc] init];
        fundItem.leftText = @"资金";
        fundItem.rightText = self.item.fundName;
        fundItem.separatorInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        [section_2 addObject:fundItem];
    }
    
    SSJCalenderDetailInfoCellItem *bookItem = [[SSJCalenderDetailInfoCellItem alloc] init];
    bookItem.leftText = @"账本";
    bookItem.rightText = self.item.booksName;
    bookItem.separatorInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    [section_2 addObject:bookItem];
}

-(void)rightBarButtonClicked:(id)sender{
    [self deleteCharge];
}

- (void)updateAppearance {
    [self.editBtn ssj_setBorderColor:SSJ_CELL_SEPARATOR_COLOR];
    [self.editBtn setTitleColor:SSJ_MARCATO_COLOR forState:UIControlStateNormal];
    [self.editBtn ssj_setBackgroundColor:SSJ_SECONDARY_FILL_COLOR forState:UIControlStateNormal];
    self.tipLab.textColor = SSJ_SECONDARY_COLOR;
}

@end
