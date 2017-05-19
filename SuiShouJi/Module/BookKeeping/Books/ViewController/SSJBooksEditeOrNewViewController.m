    //
//  SSJBooksEditeOrNewViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/8/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBooksEditeOrNewViewController.h"
#import "SSJBooksColorAndIconSelectView.h"
#import "UIViewController+MMDrawerController.h"
#import "SSJBooksTypeStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"

@interface SSJBooksEditeOrNewViewController ()

@property(nonatomic, strong) SSJBooksColorAndIconSelectView *booksEditeView;

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
        if (!self.item) {
            self.item = [[SSJBooksTypeItem alloc]init];
        }
        self.item.booksColor = @"#fc7a60";
        self.item.booksIcoin = @"bk_moren";
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

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getter
- (SSJBooksColorAndIconSelectView *)booksEditeView{
    if (!_booksEditeView) {
        _booksEditeView = [[SSJBooksColorAndIconSelectView alloc]initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM + 10, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM - 10)];
        _booksEditeView.colors = [self colorsArray];
        _booksEditeView.booksParent = self.item.booksParent;
        _booksEditeView.images = [self imageArray];
        __weak typeof(self) weakSelf = self;
        _booksEditeView.selectImageAction = ^(SSJBooksColorAndIconSelectView *view){
            [SSJAnaliyticsManager event:@"accountbook_icon_pick"];
            weakSelf.item.booksIcoin = view.selectedImage;
        };
        _booksEditeView.selectColorAction = ^(SSJBooksColorAndIconSelectView *view){
            [SSJAnaliyticsManager event:@"accountbook_color_pick"];
//            weakSelf.item.booksColor = view.selectedColor;
        };
        if (self.item.booksName.length) {
            _booksEditeView.textField.text = self.item.booksName;
        }
        if (self.item.booksIcoin.length) {
            _booksEditeView.selectedImage = self.item.booksIcoin;
        }
//        if (self.item.booksColor.length) {
//            _booksEditeView.selectedColor = [self.item.booksColor lowercaseString];
//        }
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
//    __weak typeof(self) weakSelf = self;
    [SSJBooksTypeStore saveBooksTypeItem:self.item sucess:^{
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        [[NSNotificationCenter defaultCenter]postNotificationName:SSJBooksTypeDidChangeNotification object:nil];
        [self.navigationController popViewControllerAnimated:YES];
        if (_saveBooksBlock) {
            _saveBooksBlock(self.item.booksId);
        }
    } failure:^(NSError *error) {
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];
}

#pragma mark - Private
- (NSArray *)colorsArray{
    return @[@"#fc7a60",@"#b1c23e",@"#25b4dd",@"#5ca0d9",@"#7fb04f",@"#ad82dd",@"#20cac0",@"#f5a237",@"#ff6363",@"#eb66a7",@"#ba2e8b",@"#6a7fe7",@"#d96421",@"#ba4747",@"#2aaf69"];
}

- (NSArray *)imageArray{
    return @[@"bk_moren",@"bk_zhuangxiu",@"bk_jiehun",@"bk_shengyi",@"bk_lvxing",@"bk_qiche",@"bk_renqing",@"bk_jucan",@"bk_zufang",@"bk_tuandui",@"bk_class",@"bk_house",@"bk_chuchai",@"bk_yifu",@"bk_family",@"bk_shopping",@"bk_shenghuo",@"bk_movie",@"bk_hufu",@"bk_qiankuan",@"bk_jiechu",@"bk_sport",@"bk_licai",@"bk_pet",@"bk_school",@"bk_taobao",@"bk_jiaoyu",@"bk_yule",@"bk_baoxiao",@"bk_meirong",@"bk_yiliao",@"bk_canyin",@"bk_shucai",@"bk_jiaju",@"bk_yinger",@"bk_yingye",@"bk_shui",@"bk_fuwu",@"bk_xiebao",@"bk_weixiu"];
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
