//
//  SSJADDNewTypeViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJADDNewTypeViewController.h"
#import "SSJCategoryCollectionViewCell.h"
#import "SSJRecordMakingCategoryItem.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "FMDB.h"

#import "SCYSlidePagingHeaderView.h"
#import "SSJAddNewTypeColorSelectionView.h"
#import "SSJCategoryListHelper.h"

@interface SSJADDNewTypeViewController () <SCYSlidePagingHeaderViewDelegate, UITextFieldDelegate>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) UIView *rightbuttonView;

@property (nonnull, strong) NSArray *customItems;

@property (nonatomic, strong) SCYSlidePagingHeaderView *titleSegmentView;

@property (nonatomic, strong) UITextField *customTypeInputView;

@property (nonatomic, strong) UIImageView *selectedTypeView;

@property (nonatomic, strong) SSJAddNewTypeColorSelectionView *colorSelectionView;

@end

@implementation SSJADDNewTypeViewController{
    NSIndexPath *_selectedIndex;
    NSString *_selectedID;
    SSJRecordMakingCategoryItem *_selectedItem;
    SSJRecordMakingCategoryItem *_defualtItem;
}

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"添加新类别";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    
    self.view.backgroundColor = [UIColor ssj_colorWithHex:@"F6F6F6"];
    [self ssj_showBackButtonWithImage:[UIImage imageNamed:@"close"] target:self selector:@selector(closeButtonClicked:)];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:self.rightbuttonView];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    self.navigationItem.titleView = self.titleSegmentView;
    [self.view addSubview:self.customTypeInputView];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.colorSelectionView];
}

-(void)viewDidLayoutSubviews{
    [self updateView];
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return (_titleSegmentView.selectedIndex ? _customItems.count : _items.count);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJCategoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCollectionViewCellIdentifier" forIndexPath:indexPath];
    NSArray *currentItems = (_titleSegmentView.selectedIndex ? _customItems : _items);
    cell.item = (SSJRecordMakingCategoryItem*)[currentItems objectAtIndex:indexPath.row];
    if ([cell.item.categoryID isEqualToString:_selectedItem.categoryID]) {
        cell.categoryImage.tintColor = [UIColor whiteColor];
        cell.categoryImage.image = [cell.categoryImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.categoryImage.backgroundColor = [UIColor ssj_colorWithHex:cell.item.categoryColor];
    }else{
        cell.categoryImage.backgroundColor = [UIColor clearColor];
        [cell.categoryImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _selectedID = ((SSJCategoryCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath]).item.categoryID;
    _selectedItem = ((SSJCategoryCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath]).item;
    [collectionView reloadData];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _collectionView) {
        if (_titleSegmentView.selectedIndex != 1) {
            return;
        }
        if (scrollView.dragging && !scrollView.decelerating) {
            CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:scrollView];
            if (velocity.y < 0) {
                [_customTypeInputView resignFirstResponder];
            } else {
                [_customTypeInputView becomeFirstResponder];
            }
        }
    }
}

#pragma mark - UITextFieldDelegate

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    [self updateView];
    if (index == 0) {
        [_customTypeInputView resignFirstResponder];
        _collectionView.collectionViewLayout = [self addLayout];
    } else if (index == 1) {
        [_customTypeInputView becomeFirstResponder];
        _collectionView.collectionViewLayout = [self customLayout];
    }
}

#pragma mark - Event
- (void)selectColorAction {
    NSString *colorValue = [_colorSelectionView.colors ssj_safeObjectAtIndex:_colorSelectionView.selected];
}

-(void)comfirmButtonClick:(id)sender{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db){
        [db executeUpdate:@"UPDATE BK_USER_BILL SET ISTATE = 1 , CWRITEDATE = ? , IVERSION = ? , OPERATORTYPE = 1 WHERE CBILLID = ? AND CUSERID = ?",[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[NSNumber numberWithLongLong:SSJSyncVersion()],_selectedID,SSJUSERID()];
//        [weakSelf getDateFromDb];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [[NSNotificationCenter defaultCenter]postNotificationName:@"addNewTypeNotification" object:nil];
            [weakSelf.collectionView reloadData];
            [weakSelf.navigationController popViewControllerAnimated:YES];
            if (weakSelf.NewCategorySelectedBlock) {
                weakSelf.NewCategorySelectedBlock(_selectedID,_selectedItem);
            }
        });
    }];
    if (SSJSyncSetting() == SSJSyncSettingTypeWIFI) {
        [[SSJDataSynchronizer shareInstance]startSyncWithSuccess:NULL failure:NULL];
    }
}

#pragma mark - Getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = self.titleSegmentView.selectedIndex ? [self customLayout] : [self addLayout];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) collectionViewLayout:layout];
        _collectionView.dataSource=self;
        _collectionView.delegate=self;
        [_collectionView registerClass:[SSJCategoryCollectionViewCell class] forCellWithReuseIdentifier:@"CategoryCollectionViewCellIdentifier"];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.contentOffset = CGPointMake(0, 0);
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)addLayout {
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    CGFloat width = (self.view.width - 16) * 0.2;
    flowLayout.itemSize = CGSizeMake(width, 94);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8);
    return flowLayout;
}

- (UICollectionViewFlowLayout *)customLayout {
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    CGFloat width = (self.view.width - 16) * 0.2;
    flowLayout.itemSize = CGSizeMake(width, 60);
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 8, 0, 8);
    return flowLayout;
}

-(UIView *)rightbuttonView{
    if (!_rightbuttonView) {
        _rightbuttonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        UIButton *comfirmButton = [[UIButton alloc]init];
        comfirmButton.frame = CGRectMake(0, 0, 44, 44);
        [comfirmButton setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
        [comfirmButton addTarget:self action:@selector(comfirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_rightbuttonView addSubview:comfirmButton];
    }
    return _rightbuttonView;
}

- (SCYSlidePagingHeaderView *)titleSegmentView {
    if (!_titleSegmentView) {
        _titleSegmentView = [[SCYSlidePagingHeaderView alloc] initWithFrame:CGRectMake(0, 0, 204, 44)];
        _titleSegmentView.customDelegate = self;
        _titleSegmentView.buttonClickAnimated = YES;
        _titleSegmentView.titleColor = [UIColor ssj_colorWithHex:@"999999"];
        _titleSegmentView.selectedTitleColor = [UIColor ssj_colorWithHex:@"EB4A64"];
        [_titleSegmentView setTabSize:CGSizeMake(102, 2)];
        _titleSegmentView.titles = @[@"添加类别", @"自定义类别"];
    }
    return _titleSegmentView;
}

- (UITextField *)customTypeInputView {
    if (!_customTypeInputView) {
        _customTypeInputView = [[UITextField alloc] initWithFrame:CGRectMake(0, 10, self.view.width, 63)];
        _customTypeInputView.backgroundColor = [UIColor whiteColor];
        _customTypeInputView.font = [UIFont systemFontOfSize:15];
        _customTypeInputView.placeholder = @"请输入类别名称";
        _customTypeInputView.delegate = self;
        [_customTypeInputView ssj_setBorderWidth:1];
        [_customTypeInputView ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
        [_customTypeInputView ssj_setBorderStyle:(SSJBorderStyleTop | SSJBorderStyleBottom)];
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, _customTypeInputView.height)];
        _selectedTypeView = [[UIImageView alloc] init];
        [leftView addSubview:_selectedTypeView];
        _customTypeInputView.leftView = leftView;
        _customTypeInputView.leftViewMode = UITextFieldViewModeAlways;
    }
    return _customTypeInputView;
}

- (SSJAddNewTypeColorSelectionView *)colorSelectionView {
    if (!_colorSelectionView) {
        _colorSelectionView = [[SSJAddNewTypeColorSelectionView alloc] initWithFrame:CGRectMake(0, self.view.height - 186, self.view.width, 186)];
        _colorSelectionView.colors = _incomeOrExpence ? [SSJCategoryListHelper payOutColors] : [SSJCategoryListHelper incomeColors];
        [_colorSelectionView ssj_setBorderWidth:1];
        [_colorSelectionView ssj_setBorderStyle:SSJBorderStyleTop];
        [_colorSelectionView ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
        [_colorSelectionView addTarget:self action:@selector(selectColorAction) forControlEvents:UIControlEventValueChanged];
    }
    return _colorSelectionView;
}

#pragma mark - private
//-(void)getDateFromDb{
//    [self.collectionView ssj_showLoadingIndicator];
//    
//    __weak typeof(self) weakSelf = self;
//    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db){
//        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
//        FMResultSet *rs = [db executeQuery:@"SELECT * FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE A.ITYPE = ? AND B.ISTATE = 0 AND B.CUSERID = ? AND A.ID = B.CBILLID",[NSNumber numberWithBool:self.incomeOrExpence],SSJUSERID()];
//        while ([rs next]) {
//            SSJRecordMakingCategoryItem *item = [[SSJRecordMakingCategoryItem alloc]init];
//            item.categoryTitle = [rs stringForColumn:@"CNAME"];
//            item.categoryImage = [rs stringForColumn:@"CCOIN"];
//            item.categoryColor = [rs stringForColumn:@"CCOLOR"];
//            item.categoryID = [rs stringForColumn:@"ID"];
//            [tempArray addObject:item];
//        }
//        dispatch_async(dispatch_get_main_queue(), ^(){
//            weakSelf.items = tempArray;
//            [weakSelf.collectionView reloadData];
//            _selectedID = ((SSJRecordMakingCategoryItem*)[weakSelf.items firstObject]).categoryID;
//            [weakSelf.collectionView ssj_hideLoadingIndicator];
//        });
//    }];
//}

//-(void)getdefualtItem{
//    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
//        FMResultSet *rs = [db executeQuery:@"SELECT * FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE A.ITYPE = ? AND B.ISTATE = 0 AND B.CUSERID = ? AND A.ID = B.CBILLID LIMIT 1 OFFSET 0",[NSNumber numberWithBool:self.incomeOrExpence],SSJUSERID()];
//        while ([rs next]) {
//            _defualtItem = [[SSJRecordMakingCategoryItem alloc]init];
//            _defualtItem.categoryTitle = [rs stringForColumn:@"CNAME"];
//            _defualtItem.categoryImage = [rs stringForColumn:@"CCOIN"];
//            _defualtItem.categoryColor = [rs stringForColumn:@"CCOLOR"];
//            _defualtItem.categoryID = [rs stringForColumn:@"ID"];
//        }
//        _selectedItem = _defualtItem;
//    }];
//}

- (void)loadData {
    [_collectionView ssj_showLoadingIndicator];
    [SSJCategoryListHelper queryForUnusedCategoryListWithIncomeOrExpenture:_incomeOrExpence success:^(NSMutableArray<SSJRecordMakingCategoryItem *> *result) {
        _items = result;
        [SSJCategoryListHelper queryCustomCategoryListWithIncomeOrExpenture:_incomeOrExpence success:^(NSArray<SSJRecordMakingCategoryItem *> *items) {
            [_collectionView ssj_showLoadingIndicator];
            _customItems = items;
            [_collectionView reloadData];
        } failure:^(NSError *error) {
            [_collectionView ssj_showLoadingIndicator];
            [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
        }];
    } failure:^(NSError *error) {
        [_collectionView ssj_showLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];
}

-(void)closeButtonClicked:(id)sender{
    [self ssj_backOffAction];
}

- (void)updateView {
    if (_titleSegmentView.selectedIndex == 0) {
        _customTypeInputView.hidden = YES;
        _colorSelectionView.hidden = YES;
        _collectionView.frame = CGRectMake(0, 10, self.view.width, self.view.height - 10);
    } else if (_titleSegmentView.selectedIndex == 1) {
        _customTypeInputView.hidden = NO;
        _colorSelectionView.hidden = NO;
        _collectionView.frame = CGRectMake(0, _customTypeInputView.bottom, self.view.width, self.view.height - _customTypeInputView.bottom - _colorSelectionView.height - 5);
    }
}

@end
