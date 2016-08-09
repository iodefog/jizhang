
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
static NSString *const kTitle6 = @"成员";
static NSString *const kTitle7 = @"照片";
static NSString *const kTitle8 = @"循环周期";
static NSString *const kTitle9 = @"资金账户";
static NSString *const kTitle10 = @"起始日期";
static NSString *const kTitle11 = @"不支持设置历史日期的周期账";

static NSString * SSJChargeCircleEditeCellIdentifier = @"chargeCircleEditeCell";


#import "SSJChargeCicleModifyViewController.h"
#import "SSJChargeCircleModifyCell.h"
#import "SSJCircleChargeStore.h"
#import "SSJCategoryListHelper.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJFundingTypeSelectView.h"
#import "SSJChargeCircleSelectView.h"
#import "SSJBillTypeSelectViewController.h"
#import "SSJChargeCircleTimeSelectView.h"
#import "SSJCircleChargeTypeSelectView.h"
#import "SSJImaageBrowseViewController.h"
#import "SSJRecordMakingCategoryItem.h"
#import "SSJNewFundingViewController.h"
#import "SSJDatabaseQueue.h"
#import "SSJChargeMemBerItem.h"
#import "SSJMemberSelectView.h"
#import "SSJMemberManagerViewController.h"
#import "SSJNewMemberViewController.h"

@interface SSJChargeCicleModifyViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic, strong) NSArray *titles;
@property(nonatomic, strong) TPKeyboardAvoidingTableView *tableView;
@property(nonatomic, strong) UIView *saveFooterView;
@property(nonatomic, strong) SSJFundingTypeSelectView *fundSelectView;
@property(nonatomic, strong) SSJChargeCircleSelectView *circleSelectView;
@property(nonatomic, strong) SSJChargeCircleTimeSelectView *chargeCircleTimeView;
@property(nonatomic, strong) SSJCircleChargeTypeSelectView *chargeTypeSelectView;
@property(nonatomic, strong) SSJMemberSelectView *memberSelectView;
@property(nonatomic, strong) UIImage *selectedImage;

@end

@implementation SSJChargeCicleModifyViewController{
    UITextField *_moneyInput;
    NSArray *_images;
    UITextField *_memoInput;
}

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
        self.hideKeyboradWhenTouch = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    return self;
} 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titles = @[@[kTitle1,kTitle2],@[kTitle3,kTitle4,kTitle5,kTitle7],@[kTitle6,kTitle8,kTitle9,kTitle10,kTitle11]];
    _images = @[@[@"xuhuan_zhangben",@"xuhuan_shouzhileixing"],@[@"xuhuan_leibie",@"xuhuan_jine",@"xuhuan_beizhu",@"xuhuan_paizhao" ],@[@"xunhuan_chengyuan",@"xuhuan_xuhuan",@"xuhuan_zijinzhanghu",@"xuhuan_riqi",@""]];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[SSJChargeCircleModifyCell class] forCellReuseIdentifier:SSJChargeCircleEditeCellIdentifier];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transferTextDidChange)name:UITextFieldTextDidChangeNotification object:nil];
    if (self.item != nil) {
        self.title = @"编辑周期记账";
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClicked:)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }else{
        self.title = @"添加周期记账";
    }
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.item == nil) {
        __weak typeof(self) weakSelf = self;
        [SSJCircleChargeStore queryDefualtItemWithIncomeOrExpence:1 Success:^(SSJBillingChargeCellItem *item) {
            weakSelf.item = item;
            [weakSelf.tableView reloadData];
        } failure:^(NSError *error) {
            
        }];
    }else{
        if (![self.item.membersItem count]) {
            SSJChargeMemberItem *memberItem = [[SSJChargeMemberItem alloc]init];
            memberItem.memberId = [NSString stringWithFormat:@"%@-0",SSJUSERID()];
            memberItem.memberName = @"我";
            self.item.membersItem = [@[memberItem] mutableCopy];
            [self.tableView reloadData];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.selectedImage = image;
    [self.tableView reloadData];
}


#pragma mark - UIActionSheetDelegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:  //打开照相机拍照
            [self takePhoto];
            break;
        case 1:  //打开本地相册
            [self localPhoto];
            break;
    }
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle11]) {
        return 30;
    }else{
        return 55;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 2) {
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
    if ([title isEqualToString:kTitle9]) {
        self.fundSelectView.selectFundID = self.item.fundId;
        [self.fundSelectView show];
    }
    if ([title isEqualToString:kTitle8]) {
        self.circleSelectView.selectCircleType = self.item.chargeCircleType;
        [self.circleSelectView show];
    }
    if ([title isEqualToString:kTitle3]) {
        SSJBillTypeSelectViewController *billTypeSelectVC = [[SSJBillTypeSelectViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
        __weak typeof(self) weakSelf = self;
        billTypeSelectVC.incomeOrExpenture = !self.item.incomeOrExpence;
        billTypeSelectVC.selectedId = self.item.billId;
        billTypeSelectVC.typeSelectBlock = ^(SSJRecordMakingBillTypeSelectionCellItem *item){
            weakSelf.item.typeName = item.title;
            weakSelf.item.billId = item.ID;
            weakSelf.item.imageName = item.imageName;
            [weakSelf.tableView reloadData];
        };
        [self.navigationController pushViewController:billTypeSelectVC animated:YES];
    }
    if ([title isEqualToString:kTitle10]) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate* date = [dateFormatter dateFromString:self.item.billDate];
        self.chargeCircleTimeView.currentDate = date;
        [self.chargeCircleTimeView show];
    }
    if ([title isEqualToString:kTitle2]) {
        [self.chargeTypeSelectView show];
    }
    if ([title isEqualToString:kTitle6]) {
        self.memberSelectView.selectedMemberItems = self.item.membersItem;
        [self.memberSelectView show];
    }
    if ([title isEqualToString:kTitle7]) {
        if (self.item.chargeImage.length || self.selectedImage != nil) {
            __weak typeof(self) weakSelf = self;
            SSJImaageBrowseViewController *imageBrowseVc = [[SSJImaageBrowseViewController alloc]init];
            imageBrowseVc.type = SSJImageBrowseVcTypeEdite;
            imageBrowseVc.image = self.selectedImage;
            imageBrowseVc.item = self.item;
            imageBrowseVc.NewImageSelectedBlock = ^(UIImage *image){
                weakSelf.selectedImage = image;
                [weakSelf.tableView reloadData];
            };
            imageBrowseVc.DeleteImageBlock = ^(){
                weakSelf.selectedImage = nil;
                weakSelf.item.chargeImage = @"";
                [weakSelf.tableView reloadData];
            };
            [self.navigationController pushViewController:imageBrowseVc animated:YES];
        }else{
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄照片" ,@"从相册选择", nil];
            [sheet showInView:self.view];
        }
    }
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
    NSString *image = [_images ssj_objectAtIndexPath:indexPath];
    SSJChargeCircleModifyCell *circleModifyCell = [tableView dequeueReusableCellWithIdentifier:SSJChargeCircleEditeCellIdentifier];
    if (!circleModifyCell) {
        circleModifyCell = [[SSJChargeCircleModifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SSJChargeCircleEditeCellIdentifier];
    }
    circleModifyCell.cellImageName = image;
    if ([title isEqualToString:kTitle4]) {
        circleModifyCell.cellInput.hidden = NO;
        circleModifyCell.cellInput.text = self.item.money;
        circleModifyCell.cellInput.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        circleModifyCell.cellInput.keyboardType = UIKeyboardTypeDecimalPad;
        circleModifyCell.cellInput.delegate = self;
        circleModifyCell.cellInput.tag = 100;
        _moneyInput = circleModifyCell.cellInput;
    }else if ([title isEqualToString:kTitle5]) {
        circleModifyCell.cellInput.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"选填" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        circleModifyCell.cellInput.delegate = self;
        circleModifyCell.cellInput.hidden = NO;
        circleModifyCell.cellInput.tag = 101;
        circleModifyCell.cellInput.text = self.item.chargeMemo;
        _memoInput = circleModifyCell.cellInput;
    }else{
        circleModifyCell.cellInput.hidden = YES;
    }
    if ([title isEqualToString:kTitle1] || [title isEqualToString:kTitle4] || [title isEqualToString:kTitle5] || [title isEqualToString:kTitle10]) {
        circleModifyCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else{
        circleModifyCell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
    }
    if ([title isEqualToString:kTitle11]) {
        circleModifyCell.cellTitle = @"";
        circleModifyCell.cellDetail = @"";
        circleModifyCell.cellSubTitle = title;
        circleModifyCell.cellSubTitleLabel.hidden = NO;
    }else{
        circleModifyCell.cellTitle = title;
        circleModifyCell.cellSubTitleLabel.hidden = YES;
    }
    if ([title isEqualToString:kTitle1]) {
        circleModifyCell.cellDetail = self.item.booksName;
    }else if ([title isEqualToString:kTitle2]) {
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (!self.item.incomeOrExpence) {
            circleModifyCell.cellDetail = @"支出";
        }else{
            circleModifyCell.cellDetail = @"收入";
        }
    }else if ([title isEqualToString:kTitle3]) {
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        circleModifyCell.cellDetail = self.item.typeName;
        circleModifyCell.cellTypeImageName = self.item.imageName;
    }else if ([title isEqualToString:kTitle8]) {
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        switch (self.item.chargeCircleType) {
            case 0:
                circleModifyCell.cellDetail = @"每天";
                break;
            case 1:
                circleModifyCell.cellDetail = @"每个工作日";
                break;
            case 2:
                circleModifyCell.cellDetail = @"每个周末";
                break;
            case 3:
                circleModifyCell.cellDetail = @"每周";
                break;
            case 4:
                circleModifyCell.cellDetail = @"每月";
                break;
            case 5:
                circleModifyCell.cellDetail = @"每月最后一天";
                break;
            case 6:
                circleModifyCell.cellDetail = @"每年";
                break;
            default:
                break;
        }
    }else if ([title isEqualToString:kTitle9]) {
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        circleModifyCell.cellDetail = self.item.fundName;
        circleModifyCell.cellTypeImageName = self.item.fundImage;
    }else if ([title isEqualToString:kTitle10]) {
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        circleModifyCell.cellDetail = self.item.billDate;
    }else if ([title isEqualToString:kTitle6]){
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (self.item.membersItem.count == 1) {
            circleModifyCell.cellDetail = ((SSJChargeMemberItem *)[self.item.membersItem ssj_safeObjectAtIndex:0]).memberName;
        }else{
            circleModifyCell.cellDetail = [NSString stringWithFormat:@"%ld人",self.item.membersItem.count];
        }
    }
    if ([title isEqualToString:kTitle7]) {
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (self.item.chargeImage.length || self.selectedImage != nil) {
            circleModifyCell.cellImageView.image = [UIImage imageNamed:@"mark_pic"];
        }else{
            circleModifyCell.cellImageView.image = nil;
        }
    }else{
        circleModifyCell.cellImageView.image = nil;
    }
    return circleModifyCell;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.tag == 100) {
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 10) {
            [CDAutoHideMessageHUD showMessage:@"金额不能超过10位"];
            return NO;
        }
    }
    return YES;
}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == 100) {
        self.item.money = textField.text;
    }else if (textField.tag == 101){
        self.item.chargeMemo = textField.text;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Getter
-(TPKeyboardAvoidingTableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[TPKeyboardAvoidingTableView alloc]initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    }
    return _tableView;
}

-(UIView *)saveFooterView{
    if (_saveFooterView == nil) {
        _saveFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
        UIButton *saveButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _saveFooterView.width - 20, 40)];
        [saveButton setTitle:@"保存" forState:UIControlStateNormal];
        saveButton.layer.cornerRadius = 3.f;
        saveButton.layer.masksToBounds = YES;
        [saveButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
        [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(saveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        saveButton.center = CGPointMake(_saveFooterView.width / 2, _saveFooterView.height / 2);
        [_saveFooterView addSubview:saveButton];
    }
    return _saveFooterView;
}

-(SSJFundingTypeSelectView *)fundSelectView{
    if (!_fundSelectView) {
        _fundSelectView = [[SSJFundingTypeSelectView alloc]init];
        __weak typeof(self) weakSelf = self;
        _fundSelectView.fundingTypeSelectBlock = ^(SSJFundingItem *item){
            if (item.fundingID.length) {
                weakSelf.item.fundId = item.fundingID;
                weakSelf.item.fundName = item.fundingName;
                weakSelf.item.fundImage = item.fundingIcon;
                [weakSelf.tableView reloadData];
                [weakSelf.fundSelectView dismiss];
            }else{
                SSJNewFundingViewController *NewFundingVC = [[SSJNewFundingViewController alloc]init];
                NewFundingVC.finishBlock = ^(SSJFundingItem *newFundingItem){
                    weakSelf.item.fundId = newFundingItem.fundingID;
                    weakSelf.item.fundName = newFundingItem.fundingName;
                    weakSelf.item.fundImage = newFundingItem.fundingIcon;
                    [weakSelf.tableView reloadData];
                };
                [weakSelf.fundSelectView dismiss];
                [weakSelf.navigationController pushViewController:NewFundingVC animated:YES];
            }
        };
    }
    return _fundSelectView;
}

-(SSJChargeCircleSelectView *)circleSelectView{
    if (!_circleSelectView) {
        _circleSelectView = [[SSJChargeCircleSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        __weak typeof(self) weakSelf = self;
        _circleSelectView.chargeCircleSelectBlock = ^(NSInteger chargeCircleType){
            weakSelf.item.chargeCircleType = chargeCircleType;
            [weakSelf.tableView reloadData];
        };
    }
    return _circleSelectView;
}

-(SSJChargeCircleTimeSelectView *)chargeCircleTimeView{
    if (!_chargeCircleTimeView) {
        _chargeCircleTimeView = [[SSJChargeCircleTimeSelectView alloc]initWithFrame:self.view.bounds];
        __weak typeof(self) weakSelf = self;
        _chargeCircleTimeView.timerSetBlock = ^(NSString *dateStr){
            weakSelf.item.billDate = dateStr;
            [weakSelf.tableView reloadData];
        };
    }
    return _chargeCircleTimeView;
}

-(SSJCircleChargeTypeSelectView *)chargeTypeSelectView{
    if (!_chargeTypeSelectView) {
        _chargeTypeSelectView = [[SSJCircleChargeTypeSelectView alloc]init];
        __weak typeof(self) weakSelf = self;
        
        _chargeTypeSelectView.chargeTypeSelectBlock = ^(NSInteger selectType){
            weakSelf.item.incomeOrExpence = selectType;
            SSJRecordMakingCategoryItem *categoryItem = [SSJCategoryListHelper queryfirstCategoryItemWithIncomeOrExpence:!weakSelf.item.incomeOrExpence];
            weakSelf.item.typeName = categoryItem.categoryTitle;
            weakSelf.item.billId = categoryItem.categoryID;
            [weakSelf.tableView reloadData];
        };
    }
    return _chargeTypeSelectView;
}

-(SSJMemberSelectView *)memberSelectView{
    if (!_memberSelectView) {
        __weak typeof(self) weakSelf = self;
        _memberSelectView = [[SSJMemberSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _memberSelectView.comfirmBlock = ^(NSArray *selectedMemberItems){
            weakSelf.item.membersItem = [selectedMemberItems mutableCopy];
            [weakSelf.tableView reloadData];
        };
        _memberSelectView.manageBlock = ^(NSMutableArray *items){
            SSJMemberManagerViewController *membermanageVc = [[SSJMemberManagerViewController alloc]init];
            membermanageVc.items = items;
            [weakSelf.navigationController pushViewController:membermanageVc animated:YES];
        };
        _memberSelectView.addNewMemberBlock = ^(){
            SSJNewMemberViewController *newMemberVc = [[SSJNewMemberViewController alloc]init];
            [weakSelf.navigationController pushViewController:newMemberVc animated:YES];
        };
    }
    return _memberSelectView;
}

#pragma mark - Private
-(void)takePhoto{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:^{}];
    }else{
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}

-(void)localPhoto{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:^{}];
}


-(void)transferTextDidChange{
    [self setupTextFiledNum:_moneyInput num:2];
}

-(void)saveButtonClicked:(id)sender{
    [_moneyInput resignFirstResponder];
    [_memoInput resignFirstResponder];
    if (!_moneyInput.text.length) {
        [CDAutoHideMessageHUD showMessage:@"请输入金额"];
        return;
    }
    if (self.selectedImage != nil) {
        NSString *imageName = SSJUUID();
        if (SSJSaveImage(self.selectedImage , imageName) && SSJSaveThumbImage(self.selectedImage, imageName)) {
            self.item.chargeImage = imageName;
            self.item.chargeThumbImage = [NSString stringWithFormat:@"%@-thumb",imageName];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
    if (!self.item.money.length) {
        self.item.money = _moneyInput.text;
    }
    [SSJCircleChargeStore saveCircleChargeItem:self.item success:^{
        [CDAutoHideMessageHUD showMessage:@"周期记账保存成功"];
    } failure:^(NSError *error) {
        [CDAutoHideMessageHUD showMessage:@"周期记账保存失败"];
    }];
}

-(void)deleteButtonClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *writeDate = [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        if ([db intForQuery:@"select count(1) from bk_charge_period_config where iconfigid = ?",weakSelf.item.configId]) {
            [db executeUpdate:@"update bk_charge_period_config set operatortype = 2 ,cwritedate = ? ,iversion = ? where iconfigid = ?",writeDate,@(SSJSyncVersion()),weakSelf.item.configId];
        }
        SSJDispatch_main_async_safe(^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    }];
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
