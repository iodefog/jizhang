//
//  SSJCreditCardRepaymentViewController.m
//  SuiShouJi
//
//  Created by ricky on 2016/12/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCreditCardRepaymentViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJChargeCircleModifyCell.h"

#import "SSJRepaymentModel.h"

static NSString *const SSJRepaymentEditeCellIdentifier = @"SSJRepaymentEditeCellIdentifier";

static NSString *const kTitle1 = @"待还款账户";
static NSString *const kTitle2 = @"还款金额";
static NSString *const kTitle3 = @"备注";
static NSString *const kTitle4 = @"付款账户";
static NSString *const kTitle5 = @"还款日期";

@interface SSJCreditCardRepaymentViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic, strong) SSJRepaymentModel *repaymentModel;

@property(nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property(nonatomic, strong) UIView *saveFooterView;

@property(nonatomic, strong) NSArray *titles;

@property(nonatomic, strong) NSArray *images;

@end

@implementation SSJCreditCardRepaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titles = @[@[kTitle1,kTitle2,kTitle3],@[kTitle4,kTitle5]];
    self.images = @[@[@"loan_person",@"loan_money",@"loan_memo"],@[@"card_zhanghu",@"loan_expires"]];
    [self.tableView registerClass:[SSJChargeCircleModifyCell class] forCellReuseIdentifier:SSJRepaymentEditeCellIdentifier];
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return self.saveFooterView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return 80 ;
    }
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
    NSString *image = [self.images ssj_objectAtIndexPath:indexPath];
    SSJChargeCircleModifyCell *repaymentModifyCell = [tableView dequeueReusableCellWithIdentifier:SSJRepaymentEditeCellIdentifier];
    repaymentModifyCell.cellTitle = title;
    repaymentModifyCell.cellImageName = image;
    return repaymentModifyCell;
}

#pragma mark - Getter
-(TPKeyboardAvoidingTableView *)tableView{
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc]initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    }
    return _tableView;
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
