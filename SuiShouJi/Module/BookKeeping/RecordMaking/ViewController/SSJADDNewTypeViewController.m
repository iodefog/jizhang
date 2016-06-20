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

@property (nonatomic, strong) NSArray *customItems;

@property (nonatomic, strong) UIScrollView *scrollView;

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
    
    [self ssj_showBackButtonWithTarget:self selector:@selector(goBackAction)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"checkmark"] style:UIBarButtonItemStylePlain target:self action:@selector(comfirmButtonClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.navigationItem.titleView = self.titleSegmentView;
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.newCategoryCollectionView];
    [self.scrollView addSubview:self.customTypeInputView];
    [self.scrollView addSubview:self.customCategoryCollectionView];
    [self.scrollView addSubview:self.colorSelectionView];
}

-(void)viewDidLayoutSubviews{
    _scrollView.frame = self.view.bounds;
    _scrollView.contentSize = CGSizeMake(self.view.width * 2, self.view.height);
    _newCategoryCollectionView.frame = CGRectMake(0, 10, self.view.width, self.view.height - 10);
    _colorSelectionView.bottom = self.view.height;
    _customCategoryCollectionView.frame = CGRectMake(_scrollView.width, _customTypeInputView.bottom, self.view.width, self.view.height - _customTypeInputView.bottom - _colorSelectionView.height - 5);
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
        if (self.incomeOrExpence) {
            [MobClick event:@"add_user_bill_in"];
        }else{
            [MobClick event:@"add_user_bill_out"];
        }
        _newCategorySelectedIndex = indexPath.item;
        for (int i = 0; i < _items.count; i ++) {
            SSJRecordMakingCategoryItem *item = _items[i];
            item.selected = i == _newCategorySelectedIndex;
        }
        [_newCategoryCollectionView reloadData];
    } else if (collectionView == _customCategoryCollectionView) {
        if (self.incomeOrExpence) {
            [MobClick event:@"add_user_bill_in_custom"];
        }else{
            [MobClick event:@"add_user_bill_out_custom"];
        }
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _scrollView) {
        [_titleSegmentView setSelectedIndex:(_scrollView.contentOffset.x / _scrollView.width) animated:YES];
        [self loadData];
    }
}

#pragma mark - UITextFieldDelegate
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    NSLog(@"%@", [[textField textInputMode] primaryLanguage]);
//    if (textField == _customTypeInputView) {
//        NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
//        if (newText.length > 4) {
//            [CDAutoHideMessageHUD showMessage:@"类别名称不能超过4个字符"];
//            return NO;
//        }
//    }
//    return YES;
//}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    [self loadData];
    [_scrollView setContentOffset:CGPointMake(_scrollView.width * index, 0) animated:YES];
    if (index == 0) {
        [_customTypeInputView resignFirstResponder];
    } else if (index == 1) {
        [_customTypeInputView becomeFirstResponder];
    }
}

#pragma mark - Event
- (void)selectColorAction {
    [MobClick event:@"add_user_bill_color"];
    NSString *colorValue = [_colorSelectionView.colors ssj_safeObjectAtIndex:_colorSelectionView.selectedIndex];
    _selectedTypeView.tintColor = [UIColor ssj_colorWithHex:colorValue];
    [_customItems makeObjectsPerformSelector:@selector(setCategoryColor:) withObject:colorValue];
    [_customCategoryCollectionView reloadData];
}

-(void)comfirmButtonClick:(id)sender{
    if (_titleSegmentView.selectedIndex == 0) {
        SSJRecordMakingCategoryItem *item = [_items ssj_safeObjectAtIndex:_newCategorySelectedIndex];
        [SSJCategoryListHelper addNewCategoryWithidentifier:item.categoryID incomeOrExpenture:_incomeOrExpence success:^{
            [self.navigationController popViewControllerAnimated:YES];
            if (self.addNewCategoryAction) {
                self.addNewCategoryAction(item.categoryID);
            }
        } failure:^(NSError *error) {
            [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
        }];
        
    } else if (_titleSegmentView.selectedIndex == 1) {
        NSString *name = _customTypeInputView.text;
        if (name.length == 0) {
            [CDAutoHideMessageHUD showMessage:@"请输入类别名称"];
            return;
        } else if (name.length > 4) {
            [CDAutoHideMessageHUD showMessage:@"类别名称不能超过4个字符"];
            return;
        }
        
        SSJRecordMakingCategoryItem *selectedItem = [_customItems ssj_safeObjectAtIndex:_customCategorySelectedIndex];
        [SSJCategoryListHelper addNewCustomCategoryWithIncomeOrExpenture:_incomeOrExpence name:name icon:selectedItem.categoryImage color:selectedItem.categoryColor success:^(NSString *categoryId){
            [self.navigationController popViewControllerAnimated:YES];
            if (self.addNewCategoryAction) {
                self.addNewCategoryAction(categoryId);
            }
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        } failure:^(NSError *error) {
            [CDAutoHideMessageHUD showMessage:[error localizedDescription]];
        }];
    }
}

#pragma mark - Getter
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

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor ssj_colorWithHex:@"F6F6F6"];
    }
    return _scrollView;
}

- (UICollectionView *)newCategoryCollectionView {
    if (!_newCategoryCollectionView) {
        _newCategoryCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) collectionViewLayout:self.newCategoryLayout];
        _newCategoryCollectionView.dataSource=self;
        _newCategoryCollectionView.delegate=self;
        _newCategoryCollectionView.bounces = YES;
        _newCategoryCollectionView.alwaysBounceVertical = YES;
        [_newCategoryCollectionView registerClass:[SSJCategoryCollectionViewCell class] forCellWithReuseIdentifier:kCellId];
        _newCategoryCollectionView.backgroundColor = [UIColor whiteColor];
        _newCategoryCollectionView.contentOffset = CGPointMake(0, 0);
        _newCategoryCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 94, 0);
    }
    return _newCategoryCollectionView;
}

- (UICollectionView *)customCategoryCollectionView {
    if (!_customCategoryCollectionView) {
        _customCategoryCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, _customTypeInputView.bottom, self.view.width, self.view.height - _customTypeInputView.bottom - _colorSelectionView.height - 5) collectionViewLayout:self.customCategoryLayout];
        _customCategoryCollectionView.dataSource=self;
        _customCategoryCollectionView.delegate=self;
        _customCategoryCollectionView.bounces = YES;
        _customCategoryCollectionView.alwaysBounceVertical = YES;
        [_customCategoryCollectionView registerClass:[SSJCategoryCollectionViewCell class] forCellWithReuseIdentifier:kCellId];
        _customCategoryCollectionView.backgroundColor = [UIColor whiteColor];
        _customCategoryCollectionView.contentOffset = CGPointMake(0, 0);
    }
    return _customCategoryCollectionView;
}

- (UICollectionViewFlowLayout *)newCategoryLayout {
    if (!_newCategoryLayout) {
        _newCategoryLayout = [[UICollectionViewFlowLayout alloc] init];
        _newCategoryLayout.minimumInteritemSpacing = 0;
        _newCategoryLayout.minimumLineSpacing = 0;
        CGFloat width = (self.view.width - 16) * 0.2;
        _newCategoryLayout.itemSize = CGSizeMake(floor(width), 94);
        _newCategoryLayout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8);
    }
    return _newCategoryLayout;
}

- (UICollectionViewFlowLayout *)customCategoryLayout {
    if (!_customCategoryLayout) {
        _customCategoryLayout = [[UICollectionViewFlowLayout alloc] init];
        _customCategoryLayout.minimumInteritemSpacing = 0;
        _customCategoryLayout.minimumLineSpacing = 0;
        CGFloat width = (self.view.width - 16) * 0.2;
        _customCategoryLayout.itemSize = CGSizeMake(floor(width), 60);
        _customCategoryLayout.sectionInset = UIEdgeInsetsMake(10, 8, 0, 8);
    }
    return _customCategoryLayout;
}

- (UITextField *)customTypeInputView {
    if (!_customTypeInputView) {
        _customTypeInputView = [[UITextField alloc] initWithFrame:CGRectMake(self.view.width, 10, self.view.width, 63)];
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
        _colorSelectionView = [[SSJAddNewTypeColorSelectionView alloc] initWithFrame:CGRectMake(self.view.width, 0, self.view.width, 0)];
        [_colorSelectionView sizeToFit];
        _colorSelectionView.colors = _incomeOrExpence ? [SSJCategoryListHelper payOutColors] : [SSJCategoryListHelper incomeColors];
        [_colorSelectionView ssj_setBorderWidth:1];
        [_colorSelectionView ssj_setBorderStyle:SSJBorderStyleTop];
        [_colorSelectionView ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
        [_colorSelectionView addTarget:self action:@selector(selectColorAction) forControlEvents:UIControlEventValueChanged];
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
