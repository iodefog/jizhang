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
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = self.rightButton;
    [self.view addSubview:self.transferIntext];
    [self.view addSubview:self.transferOuttext];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 10)];
    view.backgroundColor = [UIColor ssj_colorWithHex:@"F5F5F5"];
    [self.view addSubview:view];
    [self.view addSubview:self.transferLabel];
    [self.view addSubview:self.transferImage];
}

-(void)viewDidLayoutSubviews{
    self.transferIntext.size = CGSizeMake(self.view.width, 35);
    self.transferIntext.leftTop = CGPointMake(0, 45);
    [self.transferIntext ssj_relayoutBorder];
    self.transferOuttext.size = CGSizeMake(self.view.width, 35);
    self.transferOuttext.leftTop = CGPointMake(0, self.transferIntext.bottom + 60);
    [self.transferOuttext ssj_relayoutBorder];
    _transferImage.size = CGSizeMake(14, 24);
    _transferImage.centerX = self.view.width / 2 - 14;
    _transferImage.centerY = self.view.height / 2;
    _transferImage.top = self.transferIntext.bottom + 20;
    _transferLabel.left = _transferImage.right;
    _transferLabel.centerY = _transferImage.centerY;
}

#pragma mark - Getter
-(UIBarButtonItem *)rightButton{
    if (!_rightButton) {
        _rightButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"checkmark"] style:UIBarButtonItemStyleBordered target:self action:@selector(rightButtonClicked)];
        _rightButton.tintColor = [UIColor ssj_colorWithHex:@"47cfbe"];
    }
    return _rightButton;
}

-(UITextField *)transferIntext{
    if (_transferIntext == nil) {
        _transferIntext = [[UITextField alloc]init];
//        _transferIntext.borderStyle = UITextBorderStyleRoundedRect;
        [_transferIntext ssj_setBorderColor:[UIColor ssj_colorWithHex:@"47cfbe"]];
        [_transferIntext ssj_setBorderStyle:SSJBorderStyleBottom];
        _transferIntext.keyboardType = UIKeyboardTypeDecimalPad;
        _transferIntext.font = [UIFont systemFontOfSize:24];
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
        [_transferOuttext ssj_setBorderColor:[UIColor ssj_colorWithHex:@"47cfbe"]];
        [_transferOuttext ssj_setBorderStyle:SSJBorderStyleBottom];
        _transferOuttext.keyboardType = UIKeyboardTypeDecimalPad;
        _transferOuttext.font = [UIFont systemFontOfSize:24];
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
        [_transferInButton setImage:[UIImage imageNamed:@"founds_zhuanru"] forState:UIControlStateNormal];
        [_transferInButton setTitle:@"请选择转入账户" forState:UIControlStateNormal];
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

        [_transferOutButton setImage:[UIImage imageNamed:@"founds_zhuanchu"] forState:UIControlStateNormal];
        [_transferOutButton setTitle:@"请选择转出账户" forState:UIControlStateNormal];
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
        _transferInFundingTypeSelect.fundingTypeSelectBlock = ^(SSJFundingItem *fundingItem){
            [weakSelf.transferInButton setTitle:fundingItem.fundingName forState:UIControlStateNormal];
            [weakSelf.transferInButton setImage:[UIImage imageNamed:fundingItem.fundingIcon] forState:UIControlStateNormal];
            _transferInItem = fundingItem;
            [weakSelf.transferInFundingTypeSelect removeFromSuperview];
        };
    }
    return _transferInFundingTypeSelect;
}

-(SSJFundingTypeSelectView *)transferOutFundingTypeSelect{
    if (!_transferOutFundingTypeSelect) {
        __weak typeof(self) weakSelf = self;
        _transferOutFundingTypeSelect = [[SSJFundingTypeSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _transferOutFundingTypeSelect.fundingTypeSelectBlock = ^(SSJFundingItem *fundingItem){
            [weakSelf.transferOutButton setTitle:fundingItem.fundingName forState:UIControlStateNormal];
            [weakSelf.transferOutButton setImage:[UIImage imageNamed:fundingItem.fundingIcon] forState:UIControlStateNormal];
            _transferOutItem = fundingItem;
            [weakSelf.transferOutFundingTypeSelect removeFromSuperview];
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
        _transferLabel.font = [UIFont systemFontOfSize:12];
        _transferLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        _transferLabel.text = @"转至";
        [_transferLabel sizeToFit];
    }
    return _transferLabel;
}

#pragma mark - Private
-(void)rightButtonClicked{
    NSString *str = [_transferIntext.text stringByReplacingOccurrencesOfString:@"¥" withString:@""];
    if ([_transferOutItem.fundingID isEqualToString:_transferInItem.fundingID]) {
        [CDAutoHideMessageHUD showMessage:@"请选择不同账户"];
        return;
    }else if ([str doubleValue] == 0 || [self.transferIntext.text isEqualToString:@""]) {
        [CDAutoHideMessageHUD showMessage:@"请输入金额"];
        return;
    }else if (_transferInItem == nil || _transferOutItem == nil) {
        [CDAutoHideMessageHUD showMessage:@"请选择资金账户"];
        return;
    }
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()] ;
    if (![db open]) {
        NSLog(@"Could not open db.");
        return ;
    }
    [db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFID , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE  , CBILLDATE ) VALUES (?,?,?,?,?,?,?,?,?,?,?)",SSJUUID(),SSJUSERID(),str,@"3",_transferInItem.fundingID,@"",@"",[[NSDate alloc] ssj_systemCurrentDateWithFormat:@"YYYY-MM-dd hh:mm:ss:SSS"],@(SSJSyncVersion()),[NSNumber numberWithInt:0],[[NSDate alloc] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]];
    [db executeUpdate:@"INSERT INTO BK_USER_CHARGE (ICHARGEID , CUSERID , IMONEY , IBILLID , IFID , IOLDMONEY , IBALANCE , CWRITEDATE , IVERSION , OPERATORTYPE  , CBILLDATE ) VALUES (?,?,?,?,?,?,?,?,?,?,?)",SSJUUID(),SSJUSERID(),str,@"4",_transferOutItem.fundingID,@"",@"",[[NSDate alloc] ssj_systemCurrentDateWithFormat:@"YYYY-MM-dd hh:mm:ss:SSS"],@(SSJSyncVersion()),[NSNumber numberWithInt:0],[[NSDate alloc] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]];
    [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE + ? WHERE CFUNDID = ? AND CUSERID = ?",[NSNumber numberWithDouble:[str doubleValue]],_transferInItem.fundingID,SSJUSERID()];
    [db executeUpdate:@"UPDATE BK_FUNS_ACCT SET IBALANCE = IBALANCE - ? WHERE CFUNDID = ? AND CUSERID = ?",[NSNumber numberWithDouble:[str doubleValue]],_transferOutItem.fundingID,SSJUSERID()];
    [db close];
    [self.navigationController popViewControllerAnimated:YES];
}

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
    [[UIApplication sharedApplication].keyWindow addSubview:self.transferOutFundingTypeSelect];
}

-(void)transferInButtonClicked:(id)sender{
    [self.transferIntext resignFirstResponder];
    [self.transferOuttext resignFirstResponder];
    [[UIApplication sharedApplication].keyWindow addSubview:self.transferInFundingTypeSelect];
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
