//
//  SSJShareBooksMenberManagerViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/15.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksMenberManagerViewController.h"
#import "SSJShareBooksStore.h"

@interface SSJShareBooksMenberManagerViewController ()

@property(nonatomic, strong) UICollectionView *collectionView;

@property(nonatomic, strong) UIButton *deleteButton;

@property(nonatomic, strong) NSArray <SSJShareBookMemberItem *> *items;

@end

@implementation SSJShareBooksMenberManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
    [SSJShareBooksStore queryTheMemberListForTheShareBooks:self.item Success:^(NSArray<SSJShareBookMemberItem *> *result) {
        weakSelf.items = result;
        [weakSelf.collectionView reloadData];
    } failure:NULL];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
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
