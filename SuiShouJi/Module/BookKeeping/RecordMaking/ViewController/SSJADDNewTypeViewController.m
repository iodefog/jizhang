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

static NSString *const kCellId = @"CategoryCollectionViewCellIdentifier";

@interface SSJADDNewTypeViewController () <SCYSlidePagingHeaderViewDelegate, UITextFieldDelegate>

@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) UIView *rightbuttonView;

@property (nonnull, strong) NSArray *customItems;

@property (nonatomic,strong) UICollectionView *newCategoryCollectionView;

@property (nonatomic,strong) UICollectionView *customCategoryCollectionView;

@property (nonatomic, strong) SCYSlidePagingHeaderView *titleSegmentView;

@property (nonatomic, strong) UITextField *customTypeInputView;

@property (nonatomic, strong) UIImageView *selectedTypeView;

@property (nonatomic, strong) SSJAddNewTypeColorSelectionView *colorSelectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *newCategoryLayout;

@property (nonatomic, strong) UICollectionViewFlowLayout *customCategoryLayout;

@property (nonatomic) NSInteger newCategorySelectedIndex;

@property (nonatomic) NSInteger customCategorySelectedIndex;

@end

@implementation SSJADDNewTypeViewController

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
    [self ssj_showBackButtonWithTarget:self selector:@selector(goBackAction)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"checkmark"] style:UIBarButtonItemStylePlain target:self action:@selector(comfirmButtonClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
//    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:self.rightbuttonView];
//    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    self.navigationItem.titleView = self.titleSegmentView;
    [self.view addSubview:self.newCategoryCollectionView];
    [self.view addSubview:self.customTypeInputView];
    [self.view addSubview:self.customCategoryCollectionView];
    [self.view addSubview:self.colorSelectionView];
}

-(void)viewDidLayoutSubviews{
    _newCategoryCollectionView.frame = CGRectMake(0, 10, self.view.width, self.view.height - 10);
    _colorSelectionView.frame = CGRectMake(0, self.view.height - 186, self.view.width, 186);
    _customCategoryCollectionView.frame = CGRectMake(0, _customTypeInputView.bottom, self.view.width, self.view.height - _customTypeInputView.bottom - _colorSelectionView.height - 5);
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return (_titleSegmentView.selectedIndex ? _customItems.count : _items.count);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJCategoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    NSArray *currentItems = (_titleSegmentView.selectedIndex ? _customItems : _items);
    cell.item = (SSJRecordMakingCategoryItem*)[currentItems objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _newCategoryCollectionView) {
        _newCategorySelectedIndex = indexPath.item;
        for (int i = 0; i < _items.count; i ++) {
            SSJRecordMakingCategoryItem *item = _items[i];
            item.selected = i == _newCategorySelectedIndex;
        }
        [_newCategoryCollectionView reloadData];
    } else if (collectionView == _customCategoryCollectionView) {
        _customCategorySelectedIndex = indexPath.item;
        for (int i = 0; i < _customItems.count; i ++) {
            SSJRecordMakingCategoryItem *item = _customItems[i];
            item.selected = i == _customCategorySelectedIndex;
        }
        [_customCategoryCollectionView reloadData];
        [self updateSelectedImage];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _customCategoryCollectionView) {
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
    [self loadData];
    [self updateView];
    if (index == 0) {
        [_customTypeInputView resignFirstResponder];
    } else if (index == 1) {
        [_customTypeInputView becomeFirstResponder];
    }
}

#pragma mark - Event
- (void)selectColorAction {
    NSString *colorValue = [_colorSelectionView.colors ssj_safeObjectAtIndex:_colorSelectionView.selectedIndex];
    _selectedTypeView.tintColor = [UIColor ssj_colorWithHex:colorValue];
    [_customItems makeObjectsPerformSelector:@selector(setCategoryColor:) withObject:colorValue];
    [_customCategoryCollectionView reloadData];
}

-(void)comfirmButtonClick:(id)sender{
    if (_titleSegmentView.selectedIndex == 0) {
        __weak typeof(self) weakSelf = self;
        SSJRecordMakingCategoryItem *item = [_items ssj_safeObjectAtIndex:_newCategorySelectedIndex];
        [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db){
            [db executeUpdate:@"UPDATE BK_USER_BILL SET ISTATE = 1 , CWRITEDATE = ? , IVERSION = ? , OPERATORTYPE = 1 WHERE CBILLID = ? AND CUSERID = ?",[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[NSNumber numberWithLongLong:SSJSyncVersion()],item.categoryID,SSJUSERID()];
            //        [weakSelf getDateFromDb];
            dispatch_async(dispatch_get_main_queue(), ^(){
                [weakSelf.navigationController popViewControllerAnimated:YES];
                if (weakSelf.addNewCategoryAction) {
                    weakSelf.addNewCategoryAction(item.categoryID);
                }
            });
        }];
        
    } else if (_titleSegmentView.selectedIndex == 1) {
        NSString *name = _customTypeInputView.text;
        if (name.length == 0) {
            [CDAutoHideMessageHUD showMessage:@"请输入类别名称"];
            return;
        } else if (name.length > 5) {
            [CDAutoHideMessageHUD showMessage:@"类别名称不能超过5个字符"];
            return;
        }
        
        SSJRecordMakingCategoryItem *selectedItem = [_customItems ssj_safeObjectAtIndex:_customCategorySelectedIndex];
        [SSJCategoryListHelper addNewCustomCategoryWithIncomeOrExpenture:_incomeOrExpence name:name icon:selectedItem.categoryImage color:selectedItem.categoryColor success:^(NSString *categoryId){
            [self.navigationController popViewControllerAnimated:YES];
            if (self.addNewCategoryAction) {
                self.addNewCategoryAction(categoryId);
            }
        } failure:^(NSError *error) {
            [CDAutoHideMessageHUD showMessage:[error localizedDescription]];
        }];
    }
    
    if (SSJSyncSetting() == SSJSyncSettingTypeWIFI) {
        [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:NULL failure:NULL];
    }
}

#pragma mark - Getter
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

- (UICollectionView *)newCategoryCollectionView {
    if (!_newCategoryCollectionView) {
        _newCategoryCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) collectionViewLayout:self.newCategoryLayout];
        _newCategoryCollectionView.dataSource=self;
        _newCategoryCollectionView.delegate=self;
        [_newCategoryCollectionView registerClass:[SSJCategoryCollectionViewCell class] forCellWithReuseIdentifier:kCellId];
        _newCategoryCollectionView.backgroundColor = [UIColor whiteColor];
        _newCategoryCollectionView.contentOffset = CGPointMake(0, 0);
    }
    return _newCategoryCollectionView;
}

- (UICollectionView *)customCategoryCollectionView {
    if (!_customCategoryCollectionView) {
        _customCategoryCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, _customTypeInputView.bottom, self.view.width, self.view.height - _customTypeInputView.bottom - _colorSelectionView.height - 5) collectionViewLayout:self.customCategoryLayout];
        _customCategoryCollectionView.dataSource=self;
        _customCategoryCollectionView.delegate=self;
        [_customCategoryCollectionView registerClass:[SSJCategoryCollectionViewCell class] forCellWithReuseIdentifier:kCellId];
        _customCategoryCollectionView.backgroundColor = [UIColor whiteColor];
        _customCategoryCollectionView.contentOffset = CGPointMake(0, 0);
        _customCategoryCollectionView.hidden = YES;
    }
    return _customCategoryCollectionView;
}

- (UICollectionViewFlowLayout *)newCategoryLayout {
    if (!_newCategoryLayout) {
        _newCategoryLayout = [[UICollectionViewFlowLayout alloc] init];
        [_newCategoryLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _newCategoryLayout.minimumInteritemSpacing = 0;
        _newCategoryLayout.minimumLineSpacing = 0;
        CGFloat width = (self.view.width - 16) * 0.2;
        _newCategoryLayout.itemSize = CGSizeMake(width, 94);
        _newCategoryLayout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8);
    }
    return _newCategoryLayout;
}

- (UICollectionViewFlowLayout *)customCategoryLayout {
    if (!_customCategoryLayout) {
        _customCategoryLayout = [[UICollectionViewFlowLayout alloc] init];
        [_customCategoryLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _customCategoryLayout.minimumInteritemSpacing = 0;
        _customCategoryLayout.minimumLineSpacing = 0;
        CGFloat width = (self.view.width - 16) * 0.2;
        _customCategoryLayout.itemSize = CGSizeMake(width, 60);
        _customCategoryLayout.sectionInset = UIEdgeInsetsMake(10, 8, 0, 8);
    }
    return _customCategoryLayout;
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
        [leftView addSubview:self.selectedTypeView];
        _customTypeInputView.leftView = leftView;
        _customTypeInputView.leftViewMode = UITextFieldViewModeAlways;
        _customTypeInputView.hidden = YES;
    }
    return _customTypeInputView;
}

- (UIImageView *)selectedTypeView {
    if (!_selectedTypeView) {
        _selectedTypeView = [[UIImageView alloc] init];
    }
    return _selectedTypeView;
}

- (SSJAddNewTypeColorSelectionView *)colorSelectionView {
    if (!_colorSelectionView) {
        _colorSelectionView = [[SSJAddNewTypeColorSelectionView alloc] initWithFrame:CGRectMake(0, self.view.height - 186, self.view.width, 186)];
        _colorSelectionView.colors = _incomeOrExpence ? [SSJCategoryListHelper payOutColors] : [SSJCategoryListHelper incomeColors];
        [_colorSelectionView ssj_setBorderWidth:1];
        [_colorSelectionView ssj_setBorderStyle:SSJBorderStyleTop];
        [_colorSelectionView ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
        [_colorSelectionView addTarget:self action:@selector(selectColorAction) forControlEvents:UIControlEventValueChanged];
        _colorSelectionView.hidden = YES;
    }
    return _colorSelectionView;
}

#pragma mark - private
- (void)loadData {
    if (_titleSegmentView.selectedIndex == 0) {
        if (_items.count == 0) {
            [_newCategoryCollectionView ssj_showLoadingIndicator];
            [SSJCategoryListHelper queryForUnusedCategoryListWithIncomeOrExpenture:_incomeOrExpence success:^(NSMutableArray<SSJRecordMakingCategoryItem *> *result) {
                _items = result;
                
                _newCategorySelectedIndex = MIN(_newCategorySelectedIndex, _items.count - 1);
                SSJRecordMakingCategoryItem *selectedItem = _items[_newCategorySelectedIndex];
                selectedItem.selected = YES;
                
                [_newCategoryCollectionView reloadData];
                [_newCategoryCollectionView ssj_hideLoadingIndicator];
            } failure:^(NSError *error) {
                [_newCategoryCollectionView ssj_hideLoadingIndicator];
                [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
            }];
        }
    } else if (_titleSegmentView.selectedIndex == 1) {
        if (_customItems.count == 0) {
            [_customCategoryCollectionView ssj_showLoadingIndicator];
            [SSJCategoryListHelper queryCustomCategoryListWithIncomeOrExpenture:_incomeOrExpence success:^(NSArray<SSJRecordMakingCategoryItem *> *items) {
                _customItems = items;
                
                _customCategorySelectedIndex = MIN(_customCategorySelectedIndex, _customItems.count - 1);
                SSJRecordMakingCategoryItem *selectedItem = _customItems[_customCategorySelectedIndex];
                selectedItem.selected = YES;
                
                [self selectColorAction];
                [_customCategoryCollectionView reloadData];
                [_customCategoryCollectionView ssj_hideLoadingIndicator];
                
                [self updateSelectedImage];
            } failure:^(NSError *error) {
                [_customCategoryCollectionView ssj_hideLoadingIndicator];
                [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
            }];
        }
    }
}

- (void)updateView {
    [UIView transitionWithView:self.view duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        if (_titleSegmentView.selectedIndex == 0) {
            _customTypeInputView.hidden = YES;
            _colorSelectionView.hidden = YES;
            _customCategoryCollectionView.hidden = YES;
            _newCategoryCollectionView.hidden = NO;
        } else if (_titleSegmentView.selectedIndex == 1) {
            _customTypeInputView.hidden = NO;
            _colorSelectionView.hidden = NO;
            _customCategoryCollectionView.hidden = NO;
            _newCategoryCollectionView.hidden = YES;
        }
    } completion:NULL];
}

- (void)updateSelectedImage {
    NSString *colorValue = [_colorSelectionView.colors ssj_safeObjectAtIndex:_colorSelectionView.selectedIndex];
    SSJRecordMakingCategoryItem *selectedItem = [_customItems ssj_safeObjectAtIndex:_customCategorySelectedIndex];
    _selectedTypeView.tintColor = [UIColor ssj_colorWithHex:colorValue];
    _selectedTypeView.image = [[UIImage imageNamed:selectedItem.categoryImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_selectedTypeView sizeToFit];
    _selectedTypeView.left = 30;
    _selectedTypeView.centerY = _customTypeInputView.height * 0.5;
}

@end
