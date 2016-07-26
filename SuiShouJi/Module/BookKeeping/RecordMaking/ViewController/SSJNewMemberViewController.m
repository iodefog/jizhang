
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

@interface SSJNewMemberViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
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
    self.navigationItem.rightBarButtonItem = rightButton;
    [self.view addSubview:self.header];
    [self.view addSubview:self.collectionView];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.originalItem.memberName.length) {
        self.title = @"新建成员";
        _selectColor = @"#fc7a60";
    }else{
        self.title = @"编辑成员";
        _selectColor = self.originalItem.memberColor;
    }
    self.header.selectedColor = _selectColor;
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
    }
    [self saveMember];
}

#pragma mark - Private
-(void)saveMember{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSString *userId = SSJUSERID();
        if ([db intForQuery:@"select * from bk_member where cname = ? and cmemberid <> ?",weakSelf.header.nameInput.text ,weakSelf.originalItem.memberId]) {
            [db executeUpdate:@"update bk_member set istate = 1 where cname = ?",weakSelf.header.nameInput.text];
        }else{
            if (!weakSelf.originalItem.memberId.length) {
                [db executeUpdate:@"insert into bk_member (cmemberid, cname, ccolor, cuserid, operatortype, iversion, cwritedate, istate) values (?, ?, ?, ?, 0, ?, ?, 1)",SSJUUID(),weakSelf.header.nameInput.text,_selectColor,userId,@(SSJSyncVersion()),writeDate];
            }else{
                [db executeUpdate:@"update bk_member set cname = ?, ccolor = ?, operatortype = 1, iversion = ?, cwritedate = ? where cmemberid = ?",weakSelf.header.nameInput.text,_selectColor,@(SSJSyncVersion()),writeDate,weakSelf.originalItem.memberId];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    }];
}

#pragma mark - Getter
-(UICollectionView *)collectionView{
    if (_collectionView==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.minimumLineSpacing = 10;
        _collectionView =[[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor ssj_colorWithHex:@"ffffff" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
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
