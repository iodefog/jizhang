//
//  SSJFundingTransferViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/12.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingTransferViewController.h"
#import "SSJFundingItem.h"
#import "SSJFundingTypeSelectView.h"
#import "SSJNewFundingViewController.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "SSJFundingTransferDetailViewController.h"
#import "FMDB.h"

@interface SSJFundingTransferViewController ()
@property (nonatomic,strong) UIBarButtonItem *rightButton;
@property (nonatomic,strong) UITextField *transferIntext;
@property (nonatomic,strong) UITextField *transferOuttext;
@property (nonatomic,strong) UIImageView *transferImage;
@property (nonatomic,strong) UIView *transferInButtonView;
@property (nonatomic,strong) UIView *transferOutButtonView;
@property (nonatomic,strong) UIButton *transferInButton;
@property (nonatomic,strong) UIButton *transferOutButton;
@property (nonatomic,strong) SSJFundingTypeSelectView *transferInFundingTypeSelect;
@property (nonatomic,strong) SSJFundingTypeSelectView *transferOutFundingTypeSelect;
@property (nonatomic,strong) UILabel *transferLabel;
@property (nonatomic,strong) UILabel *memoLabel;
@property (nonatomic,strong) UITextField  *memoInput;
@property(nonatomic, strong) UIButton *comfirmButton;
@end

@implementation SSJFundingTransferViewController{
    SSJFundingItem *_transferInItem;
    SSJFundingItem *_transferOutItem;
}

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"转账";
        self.hideKeyboradWhenTouch = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
    self.navigationItem.rightBarButtonItem = self.rightButton;
    [self.view addSubview:self.transferIntext];
    [self.view addSubview:self.transferOuttext];
    [self.view addSubview:self.transferLabel];
    [self.view addSubview:self.transferImage];
    [self.view addSubview:self.memoInput];
    [self.view addSubview:self.memoLabel];
    [self.view addSubview:self.comfirmButton];
}

-(void)viewDidLayoutSubviews{
    self.transferOuttext.size = CGSizeMake(self.view.width, 60);
    self.transferOuttext.leftTop = CGPointMake(0, 20);
    self.transferIntext.size = CGSizeMake(self.view.width, 60);
    self.transferIntext.leftTop = CGPointMake(0, self.transferOuttext.bottom + 85);
    self.transferImage.size = CGSizeMake(14, 24);
    self.transferImage.centerX = self.view.width / 2 - 14;
    self.transferImage.centerY = self.transferOuttext.bottom + 42.5;
    self.transferLabel.left = _transferImage.right;
    self.transferLabel.centerY = _transferImage.centerY;
    self.memoInput.size = CGSizeMake(self.view.width, 50);
    self.memoInput.top = self.transferIntext.bottom;
    [self.memoInput ssj_relayoutBorder];
    self.memoLabel.centerY = self.memoInput.centerY;
    self.memoLabel.left = 20;
    self.comfirmButton.size = CGSizeMake(self.view.width - 40, 40);
    self.comfirmButton.top = self.memoInput.bottom + 20;
    self.comfirmButton.centerX = self.view.width / 2;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.item != nil) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Getter
-(UIBarButtonItem *)rightButton{
    if (!_rightButton) {
        _rightButton = [[UIBarButtonItem alloc]initWithTitle:@"转账记录" style:UIBarButtonItemStyleBordered target:self action:@selector(rightButtonClicked:)];
        _rightButton.tintColor = [UIColor ssj_colorWithHex:@"eb4a64"];
    }
    return _rightButton;
}

-(UITextField *)transferIntext{
    if (_transferIntext == nil) {
        _transferIntext = [[UITextField alloc]init];
//        _transferIntext.borderStyle = UITextBorderStyleRoundedRect;
        _transferIntext.backgroundColor = [UIColor whiteColor];
        _transferIntext.keyboardType = UIKeyboardTypeDecimalPad;
        _transferIntext.font = [UIFont systemFontOfSize:24];
        if (self.item != nil) {
            _transferIntext.text = [NSString stringWithFormat:@"¥%.2f",[self.item.transferMoney doubleValue]];
        }
        _transferIntext.placeholder = @"¥0.00";
        _transferIntext.leftView = self.transferInButtonView;
        _transferIntext.leftViewMode = UITextFieldViewModeAlways;
        _transferIntext.textAlignment = NSTextAlignmentRight;
        _transferIntext.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 35)];
        _transferIntext.rightView = rightView;
        _transferIntext.rightViewMode = UITextFieldViewModeAlways;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transferTextDidChange)name:UITextFieldTextDidChangeNotification object:nil];
    }
    return _transferIntext;
}

-(UITextField *)transferOuttext{
    if (_transferOuttext == nil) {
        _transferOuttext = [[UITextField alloc]init];
        //        _transferIntext.borderStyle = UITextBorderStyleRoundedRect;
        _transferOuttext.backgroundColor = [UIColor whiteColor];
        _transferOuttext.keyboardType = UIKeyboardTypeDecimalPad;
        _transferOuttext.font = [UIFont systemFontOfSize:24];
        if (self.item != nil) {
            _transferOuttext.text = [NSString stringWithFormat:@"¥%.2f",[self.item.transferMoney doubleValue]];
        }
        _transferOuttext.placeholder = @"¥0.00";
        _transferOuttext.leftView = self.transferOutButtonView;
        _transferOuttext.leftViewMode = UITextFieldViewModeAlways;
        _transferOuttext.textAlignment = NSTextAlignmentRight;
        _transferOuttext.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 35)];
        _transferOuttext.rightView = rightView;
        _transferOuttext.rightViewMode = UITextFieldViewModeAlways;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transferTextDidChange)name:UITextFieldTextDidChangeNotification object:nil];
        
    }
    return _transferOuttext;
}

-(UIView *)transferInButtonView{
    if (!_transferInButtonView) {
        _transferInButtonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 ,170, 30)];
        _transferInButton = [[UIButton alloc]initWithFrame:CGRectMake(20, 0 ,150, 30)];
        _transferInButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        if (self.item == nil) {
            [_transferInButton setTitle:@"请选择转入账户" forState:UIControlStateNormal];
        }else{
            [_transferInButton setTitle:self.item.transferInName forState:UIControlStateNormal];
            [_transferInButton setImage:[UIImage imageNamed:self.item.transferInImage] forState:UIControlStateNormal];
        }
        _transferInButton.titleLabel.textColor = [UIColor blackColor];
        [_transferInButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _transferInButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_transferInButton addTarget:self action:@selector(transferInButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_transferInButtonView addSubview:_transferInButton];
    }
    return _transferInButtonView;
}

-(UIView *)transferOutButtonView{
    if (!_transferOutButtonView) {
        _transferOutButtonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 ,170, 30)];
        _transferOutButton = [[UIButton alloc]initWithFrame:CGRectMake(20, 0 ,150, 30)];
        _transferOutButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        if (self.item == nil) {
            [_transferOutButton setTitle:@"请选择转出账户" forState:UIControlStateNormal];
        }else{
            [_transferOutButton setTitle:self.item.transferOutName forState:UIControlStateNormal];
            [_transferOutButton setImage:[UIImage imageNamed:self.item.transferOutImage] forState:UIControlStateNormal];
        }
        [_transferOutButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _transferOutButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_transferOutButton addTarget:self action:@selector(transferOutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_transferOutButtonView addSubview:_transferOutButton];

    }
    return _transferOutButtonView;
}

-(SSJFundingTypeSelectView *)transferInFundingTypeSelect{
    if (!_transferInFundingTypeSelect) {
        __weak typeof(self) weakSelf = self;
        _transferInFundingTypeSelect = [[SSJFundingTypeSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        if (self.item != nil) {
            _transferOutFundingTypeSelect.selectFundID = self.item.transferInId;
        }
        _transferInFundingTypeSelect.fundingTypeSelectBlock = ^(SSJFundingItem *fundingItem){
            if (![fundingItem.fundingName isEqualToString:@"添加资金新的账户"])
            {
                [weakSelf.transferInButton setTitle:fundingItem.fundingName forState:UIControlStateNormal];
                [weakSelf.transferInButton setImage:[UIImage imageNamed:fundingItem.fundingIcon] forState:UIControlStateNormal];
                _transferInItem = fundingItem;
            }else{
                SSJNewFundingViewController *NewFundingVC = [[SSJNewFundingViewController alloc]init];
                NewFundingVC.finishBlock = ^(SSJFundingItem *newFundingItem){
                    [weakSelf.transferOutButton setTitle:newFundingItem.fundingName forState:UIControlStateNormal];
                    [weakSelf.transferOutButton setImage:[UIImage imageNamed:newFundingItem.fundingIcon] forState:UIControlStateNormal];
                    _transferInItem = newFundingItem;
                };
                [weakSelf.navigationController pushViewController:NewFundingVC animated:YES];
            }
            [weakSelf.transferInFundingTypeSelect dismiss];
        };
    }
    return _transferInFundingTypeSelect;
}

-(SSJFundingTypeSelectView *)transferOutFundingTypeSelect{
    if (!_transferOutFundingTypeSelect) {
        __weak typeof(self) weakSelf = self;
        _transferOutFundingTypeSelect = [[SSJFundingTypeSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        if (self.item != nil) {
            _transferOutFundingTypeSelect.selectFundID = self.item.transferOutId;
        }
        _transferOutFundingTypeSelect.fundingTypeSelectBlock = ^(SSJFundingItem *fundingItem){
            if (![fundingItem.fundingName isEqualToString:@"添加资金新的账户"])
            {
                [weakSelf.transferOutButton setTitle:fundingItem.fundingName forState:UIControlStateNormal];
                [weakSelf.transferOutButton setImage:[UIImage imageNamed:fundingItem.fundingIcon] forState:UIControlStateNormal];
                _transferOutItem = fundingItem;
            }else{
                SSJNewFundingViewController *NewFundingVC = [[SSJNewFundingViewController alloc]init];
                NewFundingVC.finishBlock = ^(SSJFundingItem *newFundingItem){
                    [weakSelf.transferOutButton setTitle:fundingItem.fundingName forState:UIControlStateNormal];
                    [weakSelf.transferOutButton setImage:[UIImage imageNamed:fundingItem.fundingIcon] forState:UIControlStateNormal];
                    _transferOutItem = newFundingItem;
                };
                [weakSelf.navigationController pushViewController:NewFundingVC animated:YES];
            }
            [weakSelf.transferOutFundingTypeSelect dismiss];
        };
    }
    return _transferOutFundingTypeSelect;
}

-(UIImageView *)transferImage{
    if (!_transferImage) {
        _transferImage = [[UIImageView alloc]init];
        _transferImage.image = [UIImage imageNamed:@"founds_exchange"];
    }
    return _transferImage;
}

-(UILabel *)transferLabel{
    if (!_transferLabel) {
        _transferLabel = [[UILabel alloc]init];
        _transferLabel.font = [UIFont systemFontOfSize:13];
        _transferLabel.textColor = [UIColor ssj_colorWithHex:@"929292"];
        _transferLabel.text = @"转至";
        [_transferLabel sizeToFit];
    }
    return _transferLabel;
}

-(UILabel *)memoLabel{
    if (!_memoLabel) {
        _memoLabel = [[UILabel alloc]init];
        _memoLabel.text = @"备注:";
        _memoLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _memoLabel.font = [UIFont systemFontOfSize:15];
        [_memoLabel sizeToFit];
    }
    return _memoLabel;
}

-(UITextField *)memoInput{
    if (!_memoInput) {
        _memoInput = [[UITextField alloc]init];
        _memoInput.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _memoInput.font = [UIFont systemFontOfSize:15];
        _memoInput.textAlignment = NSTextAlignmentLeft;
        if (self.item != nil) {
            _memoInput.text = self.item.transferMemo;
        }
        float textWidth = [@"备注:" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}].width;
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30 + textWidth, 0)];
        _memoInput.leftView = view;
        _memoInput.leftViewMode = UITextFieldViewModeAlways;
        _memoInput.backgroundColor = [UIColor whiteColor];
        [_memoInput ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
        [_memoInput ssj_setBorderStyle:SSJBorderStyleTop];
    }
    return _memoInput;
}

-(UIButton *)comfirmButton{
    if (!_comfirmButton) {
        _comfirmButton = [[UIButton alloc]init];
        [_comfirmButton setTitle:@"确认转账" forState:UIControlStateNormal];
        [_comfirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _comfirmButton.backgroundColor = [UIColor ssj_colorWithHex:@"#eb4a64"];
        _comfirmButton.layer.cornerRadius = 3.f;
        [_comfirmButton addTarget:self action:@selector(saveClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _comfirmButton;
}

#pragma mark - Event
-(void)rightButtonClicked:(id)sender{
    SSJFundingTransferDetailViewController *transferDetailVc = [[SSJFundingTransferDetailViewController alloc]init];
    [self.navigationController pushViewController:transferDetailVc animated:YES];
}

-(void)saveClicked:(id)sender{
    NSString *str = [_transferIntext.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
    if (self.item == nil) {
        if (_transferInItem == nil || _transferOutItem == nil) {
            [CDAutoHideMessageHUD showMessage:@"请选择资金账户"];
            return;
        }
    }
    if ([_transferOutItem.fundingID isEqualToString:_transferInItem.fundingID]) {
        [CDAutoHideMessageHUD showMessage:@"请选择不同账户"];
        return;
    }else if ([str doubleValue] == 0 || [self.transferIntext.text isEqualToString:@""]) {
        [CDAutoHideMessageHUD showMessage:@"请输入金额"];
        return;
    }
    __block NSString *booksid = SSJGetCurrentBooksType();
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance]asyncInTransaction:^(FMDatabase *db , BOOL *rollback){
        NSString *userid = SSJUSERID();
        NSString *writedate = [[NSDate date] ssj_systemCurrentDateWithFormat:@"YYYY-MM-dd HH:mm:ss.SSS"];
        if (self.item == nil) {
            if (![db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFUNSID , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE  , CBILLDATE , CBOOKSID , CMEMO) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",SSJUUID(),userid,str,@"3",_transferInItem.fundingID,@"",@"",writedate,@(SSJSyncVersion()),[NSNumber numberWithInt:0],[[NSDate date] ssj_systemCurrentDateWithFormat:@"YYYY-MM-dd"],booksid,weakSelf.memoInput.text])
            {
                *rollback = YES;
            }
            if (![db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFUNSID , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE  , CBILLDATE , CBOOKSID , CMEMO) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",SSJUUID(),userid,str,@"4",_transferOutItem.fundingID,@"",@"",writedate,@(SSJSyncVersion()),[NSNumber numberWithInt:0],[[NSDate date] ssj_systemCurrentDateWithFormat:@"YYYY-MM-dd"],booksid,weakSelf.memoInput.text]) {
                *rollback = YES;
            }
            if (![db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE + ? WHERE CFUNDID = ? AND CUSERID = ?",[NSNumber numberWithDouble:[str doubleValue]],_transferInItem.fundingID,SSJUSERID()] || ![db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE - ? WHERE CFUNDID = ? AND CUSERID = ?",[NSNumber numberWithDouble:[str doubleValue]],_transferOutItem.fundingID,SSJUSERID()]) {
                *rollback = YES;
            }
            SSJDispatch_main_async_safe(^(){
                [self.navigationController popViewControllerAnimated:YES];
            });
        }else{
            if (![db executeUpdate:@"update bk_user_charge set imoney = ? , ifunsid = ? , cwritedate = ? , iversion = ? , operatortype = 1 , cmemo = ? where ichargeid = ?",[NSNumber numberWithDouble:[str doubleValue]],weakSelf.item.transferInId,writedate,@(SSJSyncVersion()),weakSelf.memoInput.text,weakSelf.item.transferInChargeId]) {
                *rollback = YES;
            }
            if (![db executeUpdate:@"update bk_user_charge set imoney = ? , ifunsid = ? , cwritedate = ? , iversion = ? , operatortype = 1 , cmemo = ? where ichargeid = ?",[NSNumber numberWithDouble:[str doubleValue]],_transferOutItem.fundingID,writedate,@(SSJSyncVersion()),weakSelf.memoInput.text,weakSelf.item.transferOutChargeId]) {
                *rollback = YES;
            }
            if (![db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE - ? WHERE CFUNDID = ? AND CUSERID = ?",[NSNumber numberWithDouble:[weakSelf.item.transferMoney doubleValue]],weakSelf.item.transferInId,SSJUSERID()] || ![db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE + ? WHERE CFUNDID = ? AND CUSERID = ?",[NSNumber numberWithDouble:[weakSelf.item.transferMoney doubleValue]],_transferOutItem.fundingID,SSJUSERID()]) {
                *rollback = YES;
            }
            if (![db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE + ? WHERE CFUNDID = ? AND CUSERID = ?",[NSNumber numberWithDouble:[str doubleValue]],_transferInItem.fundingID,SSJUSERID()] || ![db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE - ? WHERE CFUNDID = ? AND CUSERID = ?",[NSNumber numberWithDouble:[str doubleValue]],_transferOutItem.fundingID,SSJUSERID()]) {
                *rollback = YES;
            }
            weakSelf.item.transferOutId = _transferOutItem.fundingID;
            weakSelf.item.transferInId = _transferInItem.fundingID;
            weakSelf.item.transferOutName = _transferOutItem.fundingName;
            weakSelf.item.transferInName = _transferInItem.fundingName;
            weakSelf.item.transferMoney = str;
            weakSelf.item.transferMemo = weakSelf.memoInput.text;
            SSJDispatch_main_async_safe(^(){
                if (weakSelf.editeCompleteBlock) {
                    weakSelf.editeCompleteBlock(weakSelf.item);
                }
                [self.navigationController popViewControllerAnimated:YES];
                
            });
        }
        
    }];
    if (SSJSyncSetting() == SSJSyncSettingTypeWIFI) {
        [[SSJDataSynchronizer shareInstance]startSyncWithSuccess:NULL failure:NULL];
    }
}

#pragma mark - Private

-(void)transferTextDidChange{
    [self setupTextFiledNum:self.transferIntext num:2];
    [self setupTextFiledNum:self.transferOuttext num:2];
    if ([self.transferIntext isFirstResponder]) {
        if (![self.transferIntext.text hasPrefix:@"¥"]&&![self.transferIntext.text isEqualToString:@""]) {
            self.transferIntext.text = [NSString stringWithFormat:@"¥%@",self.transferIntext.text];
        }else if ([self.transferIntext.text isEqualToString:@"¥"]){
            self.transferIntext.text = @"";
        }
        self.transferOuttext.text = self.transferIntext.text;
    }else{
        if (![self.transferOuttext.text hasPrefix:@"¥"]&&![self.transferIntext.text isEqualToString:@""]) {
            self.transferOuttext.text = [NSString stringWithFormat:@"¥%@",self.transferOuttext.text];
        }else if ([self.transferOuttext.text isEqualToString:@"¥"]){
            self.transferOuttext.text = @"";
        }
        self.transferIntext.text = self.transferOuttext.text;
    }
}

-(void)transferOutButtonClicked:(id)sender{
    [self.transferIntext resignFirstResponder];
    [self.transferOuttext resignFirstResponder];
    [self.transferOutFundingTypeSelect show];
}

-(void)transferInButtonClicked:(id)sender{
    [self.transferIntext resignFirstResponder];
    [self.transferOuttext resignFirstResponder];
    [self.transferInFundingTypeSelect show];
}


/**
 *   限制输入框小数点(输入框只改变时候调用valueChange)
 *
 *  @param TF  输入框
 *  @param num 小数点后限制位数
 */
-(void)setupTextFiledNum:(UITextField *)TF num:(int)num
{
    NSString *str = [TF.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
    NSArray *arr = [TF.text componentsSeparatedByString:@"."];
    if ([str isEqualToString:@"0."] || [str isEqualToString:@"."]) {
        TF.text = @"0.";
    }else if (str.length == 2) {
        if ([str floatValue] == 0) {
            TF.text = @"0";
        }else if(arr.count < 2){
            TF.text = [NSString stringWithFormat:@"%d",[str intValue]];
        }
    }
    
    if (arr.count > 2) {
        TF.text = [NSString stringWithFormat:@"%@.%@",arr[0],arr[1]];
    }
    
    if (arr.count == 2) {
        NSString * lastStr = arr.lastObject;
        if (lastStr.length > num) {
            TF.text = [NSString stringWithFormat:@"%@.%@",arr[0],[lastStr substringToIndex:num]];
        }
    }
}

-(void)closeButtonClicked:(id)sender{
    [self ssj_backOffAction];
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
