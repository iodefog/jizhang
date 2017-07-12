

//
//  SSJPasswordModifyViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJPasswordModifyViewController.h"
#import "SSJPasswordModifyCell.h"
#import "SSJPasswordModifyService.h"
#import "SSJLoginVerifyPhoneViewController.h"

#import "SSJDataSynchronizer.h"
#import "SSJUserTableManager.h"
#import "SSJUserDefaultDataCreater.h"

@interface SSJPasswordModifyViewController ()
@property(nonatomic, strong) UIView *comfirmView;
@property(nonatomic, strong) UITextField *oldPasswordInput;
@property(nonatomic, strong) UITextField *modifiedPasswordInput;
@property(nonatomic, strong) UITextField *comfirmNewPasswordInput;
@property(nonatomic, strong) SSJPasswordModifyService *service;
@end

@implementation SSJPasswordModifyViewController

#pragma mark - Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"修改登录密码";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改密码";
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
    if (section == [self.tableView numberOfSections] - 1) {
        return self.comfirmView;
    }
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectZero];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == [self.tableView numberOfSections] - 1) {
        return 80;
    }
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJPasswordModifyCell";
    SSJPasswordModifyCell *passwordModifyCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!passwordModifyCell) {
        passwordModifyCell = [[SSJPasswordModifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        passwordModifyCell.passwordInput.delegate = self;
    }
    if (indexPath.row == 0) {
        passwordModifyCell.passwordInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"原密码" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor],NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3]}];
        self.oldPasswordInput = passwordModifyCell.passwordInput;
    }
    if (indexPath.row == 1) {
        passwordModifyCell.passwordInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"新密码" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor],NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3]}];
        self.modifiedPasswordInput = passwordModifyCell.passwordInput;
    }
    if (indexPath.row == 2) {
        passwordModifyCell.passwordInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"确认新密码" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor],NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3]}];
        self.comfirmNewPasswordInput = passwordModifyCell.passwordInput;
    }
    return passwordModifyCell;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = textField.text ? : @"";
    text = [text stringByReplacingCharactersInRange:range withString:string];
    if (text.length > 15) {
        [CDAutoHideMessageHUD showMessage:@"最多只能输入15位" inView:self.view.window duration:1];
        return NO;
    }
    return YES;
}

#pragma mark - Getter
-(UIView *)comfirmView{
    if (_comfirmView == nil) {
        _comfirmView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
        UIButton *comfirmButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _comfirmView.width - 20, 40)];
        [comfirmButton setTitle:@"确定" forState:UIControlStateNormal];
        comfirmButton.layer.cornerRadius = 3.f;
        comfirmButton.layer.masksToBounds = YES;
        [comfirmButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
        [comfirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [comfirmButton addTarget:self action:@selector(comfirmButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        comfirmButton.center = CGPointMake(_comfirmView.width / 2, _comfirmView.height / 2);
        [_comfirmView addSubview:comfirmButton];
    }
    return _comfirmView;
}

-(SSJPasswordModifyService *)service{
    if (!_service) {
        _service = [[SSJPasswordModifyService alloc]initWithDelegate:self];
    }
    return _service;
}

#pragma mark - Private
- (void)comfirmButtonClicked:(id)sender{
    if (!SSJVerifyPassword(self.modifiedPasswordInput.text)){
        [CDAutoHideMessageHUD showMessage:@"您的新密码不是由6到15位数字和字母组成的哦，请重新设置一个吧～"];
        return;
    }else if (![self.comfirmNewPasswordInput.text isEqualToString:self.modifiedPasswordInput.text]){
        [CDAutoHideMessageHUD showMessage:@"您两次输入的新密码不一致，请重新输入吧～"];
        return;
    }
    [self.service modifyPasswordWithOldPassword:self.oldPasswordInput.text newPassword:self.modifiedPasswordInput.text];
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    [super serverDidFinished:service];
    if ([service.returnCode isEqualToString:@"1"]) {
        [CDAutoHideMessageHUD showMessage:@"修改密码成功"];
        [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:NULL failure:NULL];
        [SSJUserTableManager reloadUserIdWithSuccess:^{
            SSJLoginVerifyPhoneViewController *loginVc = [[SSJLoginVerifyPhoneViewController alloc]init];
            loginVc.backController = [self.navigationController.viewControllers firstObject];
            [self.navigationController pushViewController:loginVc animated:YES];
            [SSJUserDefaultDataCreater asyncCreateAllDefaultDataWithUserId:SSJUSERID() success:NULL failure:NULL];
        } failure:^(NSError * _Nonnull error) {
            [SSJAlertViewAdapter showError:error];
        }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:service.desc delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

@end
