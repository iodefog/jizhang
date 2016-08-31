//
//  SSJBooksEditeOrNewViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/8/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBooksEditeOrNewViewController.h"
#import "SSJNewOrEditCustomCategoryView.h"
#import "UIViewController+MMDrawerController.h"

@interface SSJBooksEditeOrNewViewController ()

@property(nonatomic, strong) SSJNewOrEditCustomCategoryView *booksEditeView;

@end

@implementation SSJBooksEditeOrNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.booksEditeView];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.mm_drawerController setMaximumLeftDrawerWidth:SSJSCREENWITH];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mm_drawerController setMaximumLeftDrawerWidth:SSJSCREENWITH * 0.8];
}

- (SSJNewOrEditCustomCategoryView *)booksEditeView{
    if (!_booksEditeView) {
        _booksEditeView = [[SSJNewOrEditCustomCategoryView alloc]initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM)];
        _booksEditeView.colors = [self colorsArray];
        _booksEditeView.images = [self imageArray];
    }
    return _booksEditeView;
}

- (NSArray *)colorsArray{
    return @[@"#fc7a60",@"#b1c23e",@"#25b4dd",@"#5ca0d9",@"#7fb04f",@"#ad82dd",@"#20cac0",@"#f5a237",@"#ff6363",@"#eb66a7",@"#ba2e8b",@"#6a7fe7",@"#d96421",@"#ba4747",@"#2aaf69"];
}

- (NSArray *)imageArray{
    return @[@"book_moren",@"book_zhuangxiu",@"book_jiehun",@"book_shengyi",@"book_lvxing",@"book_qiche",@"book_renqing",@"book_jucan",@"book_zufang",@"book_tuandui",@"book_class",@"book_house",@"book_chuchai",@"book_yifu",@"book_family",@"book_shopping",@"book_shenghuo",@"book_movie",@"book_hufu",@"book_qiankuan",@"book_jiechu",@"book_sport",@"book_licai",@"book_pet",@"book_school",@"book_taobao",@"book_jiaoyu",@"book_yule",@"book_baoxiao",@"book_meirong",@"book_yiliao",@"book_canyin",@"book_shucai",@"book_jiaju",@"book_yinger",@"book_yingye",@"book_shui",@"book_fuwu",@"book_xiebao",@"book_weixiu"];
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
