
//
//  SSJChargeCicleModifyViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/5/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

static NSString *const kTitle1 = @"账本";
static NSString *const kTitle2 = @"收支类型";
static NSString *const kTitle3 = @"类别";
static NSString *const kTitle4 = @"金额";
static NSString *const kTitle5 = @"备注";
static NSString *const kTitle6 = @"照片";
static NSString *const kTitle7 = @"循环周期";
static NSString *const kTitle8 = @"资金账户";
static NSString *const kTitle9 = @"起始日期";
static NSString *const kTitle10 = @"不支持设置历史日期的周期账";

static NSString * SSJChargeCircleEditeCellIdentifier = @"chargeCircleEditeCell";


#import "SSJChargeCicleModifyViewController.h"
#import "SSJChargeCircleModifyCell.h"

@interface SSJChargeCicleModifyViewController ()
@property(nonatomic, strong) NSArray *titles;
@end

@implementation SSJChargeCicleModifyViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"添加周期记账";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titles = @[@[kTitle1,kTitle2],@[kTitle3,kTitle4,kTitle5,kTitle6],@[kTitle7,kTitle8,kTitle9,kTitle10]];
    [self.tableView registerClass:[SSJChargeCircleModifyCell class] forCellReuseIdentifier:SSJChargeCircleEditeCellIdentifier];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.item == nil) {
        
    }
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle10]) {
        return 30;
    }else{
        return 55;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectZero];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
}


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.titles[section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    SSJChargeCircleModifyCell *mineHomeCell = [tableView dequeueReusableCellWithIdentifier:SSJChargeCircleEditeCellIdentifier];
    if (!mineHomeCell) {
        mineHomeCell = [[SSJChargeCircleModifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SSJChargeCircleEditeCellIdentifier];
        mineHomeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if ([title isEqualToString:kTitle10]) {
        mineHomeCell.cellSubTitle = title;
    }else{
        mineHomeCell.cellTitle = title;
    }
    
    return mineHomeCell;
}

-(void)setItem:(SSJBillingChargeCellItem *)item{
    _item = item;
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
