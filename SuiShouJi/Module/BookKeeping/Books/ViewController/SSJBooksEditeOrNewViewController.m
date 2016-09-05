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
#import "SSJBooksTypeStore.h"
#import "SSJDatabaseQueue.h"

@interface SSJBooksEditeOrNewViewController ()

@property(nonatomic, strong) SSJNewOrEditCustomCategoryView *booksEditeView;

@end

@implementation SSJBooksEditeOrNewViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.booksEditeView];
    if (self.item.booksId.length) {
        self.title = @"编辑账本";
    }else{
        self.title = @"添加账本";
        self.item = [[SSJBooksTypeItem alloc]init];
        self.item.booksColor = @"#fc7a60";
        self.item.booksIcoin = @"book_moren";
    }
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"checkmark"] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.mm_drawerController setMaximumLeftDrawerWidth:SSJSCREENWITH];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mm_drawerController setMaximumLeftDrawerWidth:SSJSCREENWITH * 0.8];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
}

#pragma mark - Getter
- (SSJNewOrEditCustomCategoryView *)booksEditeView{
    if (!_booksEditeView) {
        _booksEditeView = [[SSJNewOrEditCustomCategoryView alloc]initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM + 10, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM - 10)];
        _booksEditeView.colors = [self colorsArray];
        _booksEditeView.images = [self imageArray];
        __weak typeof(self) weakSelf = self;
        _booksEditeView.selectImageAction = ^(SSJNewOrEditCustomCategoryView *view){
            weakSelf.item.booksIcoin = view.selectedImage;
        };
        _booksEditeView.selectColorAction = ^(SSJNewOrEditCustomCategoryView *view){
            weakSelf.item.booksColor = view.selectedColor;
        };
        if (self.item.booksName.length) {
            _booksEditeView.textField.text = self.item.booksName;
        }
        if (self.item.booksIcoin.length) {
            _booksEditeView.selectedImage = self.item.booksIcoin;
        }
        if (self.item.booksColor.length) {
            _booksEditeView.selectedColor = [self.item.booksColor lowercaseString];
        }
        _booksEditeView.displayColorRowCount = 3;
    }
    return _booksEditeView;
}

#pragma mark - Event
- (void)rightButtonClicked:(id)sender{
    self.item.booksName = self.booksEditeView.textField.text;
    if (!self.item.booksName.length) {
        [CDAutoHideMessageHUD showMessage:@"请输入账本名称"];
        return;
    }
    if (self.item.booksName.length > 5) {
        [CDAutoHideMessageHUD showMessage:@"账本名称不能超过5个字"];
        return;
    }
    if ([SSJBooksTypeStore saveBooksTypeItem:self.item]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [CDAutoHideMessageHUD showMessage:@"保存失败"];
    }
}

#pragma mark - Private
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
