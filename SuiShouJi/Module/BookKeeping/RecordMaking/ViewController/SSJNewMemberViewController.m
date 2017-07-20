
//
//  SSJNewMemberViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/7/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNewMemberViewController.h"
#import "SSJBaselineTextField.h"
#import "SSJColorSelectCollectionViewCell.h"
#import "SSJNewMemberHeaderView.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"

@interface SSJNewMemberViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate>
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) SSJNewMemberHeaderView *header;
@end

@implementation SSJNewMemberViewController{
    NSArray *_colorArray;
    NSString *_selectColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _colorArray = @[@"#fc7a60",@"#b1c23e",@"#25b4dd",@"#5a98de",@"#8bb84a",@"#a883db",@"#20cac0",@"#faa94a",@"#ef6161",@"#f16189",@"#ba2e8b",@"#3260b5",@"#d96421",@"#ba4747",@"#bda337"];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"checkmark"] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    self.navigationItem.rightBarButtonItem = rightButton;
    [self.view addSubview:self.header];
    [self.view addSubview:self.collectionView];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.header.nameInput becomeFirstResponder];
    if (!self.originalItem.memberName.length) {
        self.title = @"新建成员";
        _selectColor = @"#fc7a60";
    }else{
        self.title = @"编辑成员";
        _selectColor = self.originalItem.memberColor;
    }
    self.header.selectedColor = _selectColor;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.header.nameInput resignFirstResponder];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.header.size = CGSizeMake(self.view.width, 63);
    self.header.leftTop = CGPointMake(0, SSJ_NAVIBAR_BOTTOM + 10);
    self.collectionView.size = CGSizeMake(self.view.width, self.view.height - 73);
    self.collectionView.leftTop = CGPointMake(0, self.header.bottom);
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _colorArray.count;
}

- (NSInteger)numberOfSections{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJColorSelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ColorSelectCollectionViewCell" forIndexPath:indexPath];
    cell.itemColor = _colorArray[indexPath.row];
    if ([cell.itemColor isEqualToString:_selectColor]) {
        cell.isSelected = YES;
    }else{
        cell.isSelected = NO;
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJColorSelectCollectionViewCell *cell = (SSJColorSelectCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    _selectColor = cell.itemColor;
    [UIView animateWithDuration:0.25 animations:^{
        self.header.selectedColor = _selectColor;
    }];
    [collectionView reloadData];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self rightButtonClicked:nil];
    return YES;
}

- (void)textFieldDidChange {
    if (self.header.nameInput.text.length >= 1) {
        self.header.firstWord = [self.header.nameInput.text substringWithRange:NSMakeRange(0, 1)];
    }else{
        self.header.firstWord = @"";
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = (self.view.width - 120) / 5;
    return CGSizeMake(itemWidth, itemWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark - Event
-(void)rightButtonClicked:(id)sender{
    if (!self.header.nameInput.text.length) {
        [CDAutoHideMessageHUD showMessage:@"请输入成员名称"];
        return;
    }
    if (self.header.nameInput.text.length > 5) {
        [CDAutoHideMessageHUD showMessage:@"成员名称最多只能输入5个字"];
        return;
    }
    [self saveMember];
}

#pragma mark - Private
-(void)saveMember{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *userId = SSJUSERID();
        if ([db intForQuery:@"select count(1) from bk_member where cname = ? and cuserid = ?",weakSelf.header.nameInput.text,userId]) {
            [db executeUpdate:@"update bk_member set istate = 1 ,ccolor =? ,cwritedate = ? ,iversion = ? , operatortype = 1 where cname = ? and cuserid = ?",_selectColor,writeDate,@(SSJSyncVersion()),weakSelf.header.nameInput.text,userId];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.addNewMemberAction) {
                    self.addNewMemberAction(nil);
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }else{
            if (!weakSelf.originalItem.memberId.length) {
                NSString *memberId = SSJUUID();
                [db executeUpdate:@"insert into bk_member (cmemberid, cname, ccolor, cuserid, operatortype, iversion, cwritedate, istate, cadddate) values (?, ?, ?, ?, 0, ?, ?, 1,?)",memberId,weakSelf.header.nameInput.text,_selectColor,userId,@(SSJSyncVersion()),writeDate,writeDate];
                dispatch_async(dispatch_get_main_queue(), ^{
                    SSJChargeMemberItem *item = [[SSJChargeMemberItem alloc]init];
                    item.memberId = memberId;
                    item.memberColor = _selectColor;
                    item.memberName = weakSelf.header.nameInput.text;
                    if (self.addNewMemberAction) {
                        self.addNewMemberAction(item);
                    }
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }else{
                [db executeUpdate:@"update bk_member set cname = ?, ccolor =?, operatortype = 1, iversion = ?, cwritedate = ? where cmemberid = ?",weakSelf.header.nameInput.text,_selectColor,@(SSJSyncVersion()),writeDate,weakSelf.originalItem.memberId];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.addNewMemberAction) {
                        self.addNewMemberAction(nil);
                    }
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }
        }
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    }];
}

#pragma mark - Getter
-(UICollectionView *)collectionView{
    if (_collectionView==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 25;
        flowLayout.minimumLineSpacing = 25;
        _collectionView =[[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
;
        _collectionView.dataSource=self;
        _collectionView.delegate=self;
        [_collectionView registerClass:[SSJColorSelectCollectionViewCell class] forCellWithReuseIdentifier:@"ColorSelectCollectionViewCell"];
    }
    return _collectionView;
}

-(SSJNewMemberHeaderView *)header{
    if (!_header) {
        _header = [[SSJNewMemberHeaderView alloc]init];
        _header.nameInput.text = self.originalItem.memberName;
        _header.nameInput.delegate = self;
        if (self.originalItem.memberName.length >= 1) {
            _header.firstWord = [self.originalItem.memberName substringWithRange:NSMakeRange(0, 1)];
        }
    }
    return _header;
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
