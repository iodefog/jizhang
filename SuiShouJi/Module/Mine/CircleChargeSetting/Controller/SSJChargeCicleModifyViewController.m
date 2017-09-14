
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
static NSString *const kTitle12 = @"结束时间";

static NSString * SSJChargeCircleEditeCellIdentifier = @"chargeCircleEditeCell";


#import "SSJChargeCicleModifyViewController.h"
#import "SSJChargeCircleModifyCell.h"
#import "SSJCircleChargeStore.h"
#import "SSJCategoryListHelper.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJFundingTypeSelectView.h"
#import "SSJChargeCircleSelectView.h"
#import "SSJBillTypeSelectViewController.h"
#import "SSJFundingTypeSelectViewController.h"
#import "SSJHomeDatePickerView.h"
#import "SSJCircleChargeTypeSelectView.h"
#import "SSJImaageBrowseViewController.h"
#import "SSJRecordMakingCategoryItem.h"
#import "SSJDatabaseQueue.h"
#import "SSJChargeMemberItem.h"
#import "SSJMemberSelectView.h"
#import "SSJMemberManagerViewController.h"
#import "SSJNewMemberViewController.h"
#import "SSJDataSynchronizer.h"
#import "SSJCreditCardItem.h"
#import "SSJTextFieldToolbarManager.h"
#import "SSJChargeCircleBooksSelectView.h"

@interface SSJChargeCicleModifyViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic, strong) NSArray *titles;

@property(nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property(nonatomic, strong) UIView *saveFooterView;

@property(nonatomic, strong) SSJFundingTypeSelectView *fundSelectView;

@property(nonatomic, strong) SSJChargeCircleSelectView *circleSelectView;

@property(nonatomic, strong) SSJHomeDatePickerView *chargeCircleTimeView;

@property(nonatomic, strong) SSJHomeDatePickerView *chargeCircleEndTimeView;

@property(nonatomic, strong) SSJCircleChargeTypeSelectView *chargeTypeSelectView;

@property(nonatomic, strong) SSJMemberSelectView *memberSelectView;

@property (nonatomic, strong) SSJChargeCircleBooksSelectView *booksSelectView;

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
    }
    return self;
} 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titles = @[@[kTitle1,kTitle2],@[kTitle3,kTitle4,kTitle5,kTitle7],@[kTitle6,kTitle8,kTitle9,kTitle10,kTitle11,kTitle12]];
    _images = @[@[@"xuhuan_zhangben",@"xuhuan_shouzhileixing"],@[@"xuhuan_leibie",@"xuhuan_jine",@"xuhuan_beizhu",@"xuhuan_paizhao" ],@[@"xunhuan_chengyuan",@"xuhuan_xuhuan",@"xuhuan_zijinzhanghu",@"xuhuan_riqi",@"",@"xunhuan_end"]];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[SSJChargeCircleModifyCell class] forCellReuseIdentifier:SSJChargeCircleEditeCellIdentifier];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transferTextDidChange) name:UITextFieldTextDidChangeNotification object:nil];
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
            item.incomeOrExpence = 1;
            weakSelf.item = item;
        } failure:^(NSError *error) {
            [SSJAlertViewAdapter showError:error];
        }];
    }
    self.memberSelectView.preiodConfigId = self.item.sundryId;
    [self.memberSelectView reloadData:^{
        [self.tableView reloadData];
    }];
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
    // ios8以上UIActionSheet也是控制器，如果立即调用相册／相机，在ipad上无法正常调用，所以要在主线程的下一次loop迭代中调用
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        switch (buttonIndex)
        {
            case 0:  //打开照相机拍照
                [weakSelf takePhoto];
                break;
            case 1:  //打开本地相册
                [weakSelf localPhoto];
                break;
        }
    }];
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
    if (section == 0) {
        return 0.1f;
    }
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
        billTypeSelectVC.incomeOrExpenture = self.item.incomeOrExpence;
        billTypeSelectVC.selectedId = self.item.billId;
        billTypeSelectVC.booksId = self.item.booksId;
        billTypeSelectVC.typeSelectBlock = ^(SSJRecordMakingBillTypeSelectionCellItem *item){
            weakSelf.item.typeName = item.title;
            weakSelf.item.billId = item.ID;
            weakSelf.item.imageName = item.imageName;
            [weakSelf.tableView reloadData];
        };
        [self.navigationController pushViewController:billTypeSelectVC animated:YES];
    }
    if ([title isEqualToString:kTitle10]) {
        if (self.item.billDate.length) {
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate* date = [dateFormatter dateFromString:self.item.billDate];
            self.chargeCircleTimeView.date = date;
        }else{
            self.chargeCircleTimeView.date = [NSDate date];
        }
        [self.chargeCircleTimeView show];
    }
    if ([title isEqualToString:kTitle2]) {
        [self.chargeTypeSelectView show];
    }
    if ([title isEqualToString:kTitle6]) {
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
    if ([title isEqualToString:kTitle12]) {
        NSDate *startDate = [NSDate dateWithString:(self.item.chargeCircleEndDate ?: self.item.billDate) formatString:@"yyyy-MM-dd"];
        if (startDate) {
            self.chargeCircleEndTimeView.date = startDate;
            [self.chargeCircleEndTimeView show];
        }
    }
    if ([title isEqualToString:kTitle1]) {
        [SSJCircleChargeStore getBooksForCircleChargeWithsuccess:^(NSArray *books) {
            self.booksSelectView.booksArr = books;
            [self.booksSelectView showWithSelectBooksId:self.item.booksId];
        } failure:NULL];
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
        if (self.item.money.length) {
            circleModifyCell.cellInput.text = [NSString stringWithFormat:@"%.2f",[self.item.money doubleValue]];
        }
        circleModifyCell.cellInput.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        circleModifyCell.cellInput.keyboardType = UIKeyboardTypeDecimalPad;
        circleModifyCell.cellInput.delegate = self;
        circleModifyCell.cellInput.tag = 100;
        [circleModifyCell.cellInput ssj_installToolbar];
        _moneyInput = circleModifyCell.cellInput;
    }else if ([title isEqualToString:kTitle5]) {
        circleModifyCell.cellInput.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"备注说明" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        circleModifyCell.cellInput.delegate = self;
        circleModifyCell.cellInput.hidden = NO;
        circleModifyCell.cellInput.tag = 101;
        circleModifyCell.cellInput.text = self.item.chargeMemo;
        circleModifyCell.cellInput.returnKeyType = UIReturnKeyDone;
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
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if ([title isEqualToString:kTitle2]) {
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (self.item.incomeOrExpence) {
            circleModifyCell.cellDetail = @"支出";
        }else{
            circleModifyCell.cellDetail = @"收入";
        }
    }else if ([title isEqualToString:kTitle3]) {
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        circleModifyCell.cellDetail = self.item.typeName;
        circleModifyCell.cellTypeImageName = self.item.imageName;
        circleModifyCell.cellTypeImageColor = self.item.colorValue;
    }else if ([title isEqualToString:kTitle8]) {
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        switch (self.item.chargeCircleType) {
            case SSJCyclePeriodTypeDaily:
                circleModifyCell.cellDetail = @"每天";
                break;
            case SSJCyclePeriodTypeWorkday:
                circleModifyCell.cellDetail = @"每个工作日";
                break;
            case SSJCyclePeriodTypePerWeekend:
                circleModifyCell.cellDetail = @"每个周末";
                break;
            case SSJCyclePeriodTypeWeekly:
                circleModifyCell.cellDetail = @"每周";
                break;
            case SSJCyclePeriodTypePerMonth:
                circleModifyCell.cellDetail = @"每月";
                break;
            case SSJCyclePeriodTypeLastDayPerMonth:
                circleModifyCell.cellDetail = @"每月最后一天";
                break;
            case SSJCyclePeriodTypePerYear:
                circleModifyCell.cellDetail = @"每年";
                break;
            default:
                break;
        }
    }else if ([title isEqualToString:kTitle9]) {
        [SSJCircleChargeStore getFinancingItemWithFundingId:self.item.fundId success:^(SSJFinancingHomeitem *fundingItem) {
            circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
            circleModifyCell.cellDetail = fundingItem.fundingName;
            circleModifyCell.cellTypeImageName = fundingItem.fundingIcon;
            circleModifyCell.cellTypeImageColor = fundingItem.fundingColor;
        } failure:NULL];
    }else if ([title isEqualToString:kTitle10]) {
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        circleModifyCell.cellDetail = self.item.billDate;
    }else if ([title isEqualToString:kTitle6]){
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (self.memberSelectView.selectedMemberItems.count == 1) {
            circleModifyCell.cellDetail = ((SSJChargeMemberItem *)[self.memberSelectView.selectedMemberItems firstObject]).memberName;
        }else{
            circleModifyCell.cellDetail = [NSString stringWithFormat:@"%d人",(int)self.memberSelectView.selectedMemberItems.count];
        }
    }else if ([title isEqualToString:kTitle12]) {
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (self.item.chargeCircleEndDate.length) {
            circleModifyCell.cellDetail = self.item.chargeCircleEndDate;
        }else{
            circleModifyCell.cellDetail = @"请选择结束日期";
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
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = [text ssj_reserveDecimalDigits:2 intDigits:9];
        return NO;
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
        _fundSelectView.fundingTypeSelectBlock = ^(SSJFinancingHomeitem *item){
            if (item.fundingID.length) {
                weakSelf.item.fundId = item.fundingID;
                weakSelf.item.fundName = item.fundingName;
                weakSelf.item.fundImage = item.fundingIcon;
                weakSelf.item.colorValue = item.fundingColor;
                [weakSelf.tableView reloadData];
                [weakSelf.fundSelectView dismiss];
            }else{
                SSJFundingTypeSelectViewController *NewFundingVC = [[SSJFundingTypeSelectViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
                NewFundingVC.needLoanOrNot = NO;
                NewFundingVC.addNewFundingBlock = ^(SSJFinancingHomeitem *item){
                    weakSelf.item.fundId = item.fundingID;
                    weakSelf.item.fundName = item.fundingName;
                    weakSelf.item.fundImage = item.fundingIcon;
                    weakSelf.item.colorValue = item.fundingColor;
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

-(SSJHomeDatePickerView *)chargeCircleTimeView{
    if (!_chargeCircleTimeView) {
        _chargeCircleTimeView = [[SSJHomeDatePickerView alloc]initWithFrame:CGRectMake(0, 0, SSJSCREENWITH, 244)];
        _chargeCircleTimeView.horuAndMinuBgViewBgColor = [UIColor clearColor];;
        _chargeCircleTimeView.datePickerMode = SSJDatePickerModeDate;
        __weak typeof(self)weakSelf = self;
        _chargeCircleTimeView.shouldConfirmBlock = ^(SSJHomeDatePickerView *view, NSDate *selecteDate) {
            NSDate *currentDate = [NSDate date];
            currentDate = [NSDate dateWithYear:currentDate.year month:currentDate.month day:currentDate.day];
            if ([selecteDate compare:currentDate] == NSOrderedAscending) {
                [CDAutoHideMessageHUD showMessage:@"不能设置历史日期的周期记账哦"];
                return NO;
            }
            NSDate *endDate = [NSDate dateWithString:weakSelf.item.chargeCircleEndDate formatString:@"yyyy-MM-dd"];
            if (endDate && [selecteDate compare:endDate] == NSOrderedDescending) {
                [CDAutoHideMessageHUD showMessage:@"起始日期不能晚于结束日期哦"];
                return NO;
            }
            return YES;
        };
        _chargeCircleTimeView.confirmBlock = ^(SSJHomeDatePickerView *view) {
            weakSelf.item.billDate = [view.date formattedDateWithFormat:@"yyyy-MM-dd"];
            [weakSelf.tableView reloadData];
        };
    }
    return _chargeCircleTimeView;
}

-(SSJHomeDatePickerView *)chargeCircleEndTimeView{
    if (!_chargeCircleEndTimeView) {
        _chargeCircleEndTimeView = [[SSJHomeDatePickerView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _chargeCircleTimeView.horuAndMinuBgViewBgColor = [UIColor clearColor];;
        _chargeCircleEndTimeView.datePickerMode = SSJDatePickerModeDate;
        _chargeCircleEndTimeView.leftButtonItem = [SSJHomeDatePickerViewButtonItem buttonItemWithTitle:@"清空" titleColor:[UIColor ssj_colorWithHex:SSJOverrunRedColorValue] image:nil];
        __weak typeof(self) weakSelf = self;
        _chargeCircleEndTimeView.shouldConfirmBlock = ^(SSJHomeDatePickerView *view, NSDate *selecteDate) {
            NSDate *beginDate = [NSDate dateWithString:weakSelf.item.billDate formatString:@"yyyy-MM-dd"];
            if ([selecteDate compare:beginDate] == NSOrderedAscending) {
                [CDAutoHideMessageHUD showMessage:@"结束日期不能早于起始日期哦"];
                return NO;
            }
            return YES;
        };
        _chargeCircleEndTimeView.confirmBlock = ^(SSJHomeDatePickerView *view) {
            weakSelf.item.chargeCircleEndDate = [view.date formattedDateWithFormat:@"yyyy-MM-dd"];
            [weakSelf.tableView reloadData];
        };
        _chargeCircleEndTimeView.closeBlock = ^(SSJHomeDatePickerView *view) {
            weakSelf.item.chargeCircleEndDate = nil;
            [weakSelf.tableView reloadData];
        };
    }
    return _chargeCircleEndTimeView;
}

-(SSJCircleChargeTypeSelectView *)chargeTypeSelectView{
    if (!_chargeTypeSelectView) {
        _chargeTypeSelectView = [[SSJCircleChargeTypeSelectView alloc]init];
        @weakify(self);
        _chargeTypeSelectView.chargeTypeSelectBlock = ^(NSInteger selectType){
            @strongify(self);
            [SSJCircleChargeStore getFirstBillItemForBooksId:self.item.booksId billType:selectType withSuccess:^(SSJRecordMakingBillTypeSelectionCellItem *billItem) {
                self.item.billId = billItem.ID;
                self.item.typeName = billItem.title;
                self.item.imageName = billItem.imageName;
                [self.tableView reloadData];
            } failure:NULL];
        };
    }
    return _chargeTypeSelectView;
}

-(SSJMemberSelectView *)memberSelectView{
    if (!_memberSelectView) {
        __weak typeof(self) weakSelf = self;
        _memberSelectView = [[SSJMemberSelectView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _memberSelectView.selectedMemberDidChangeBlock = ^(NSArray *selectedMemberItems){
            [weakSelf.tableView reloadData];
        };
        _memberSelectView.manageBlock = ^(NSMutableArray *items){
            SSJMemberManagerViewController *membermanageVc = [[SSJMemberManagerViewController alloc]init];
            membermanageVc.items = items;
            [weakSelf.navigationController pushViewController:membermanageVc animated:YES];
        };
        _memberSelectView.addNewMemberBlock = ^(){
            SSJNewMemberViewController *newMemberVc = [[SSJNewMemberViewController alloc]init];
            newMemberVc.addNewMemberAction = ^(SSJChargeMemberItem *item){
                [weakSelf.memberSelectView show];
                [weakSelf.memberSelectView addSelectedMemberItem:item];
            };
            [weakSelf.navigationController pushViewController:newMemberVc animated:YES];
        };
    }
    return _memberSelectView;
}

- (SSJChargeCircleBooksSelectView *)booksSelectView {
    if (!_booksSelectView) {
        _booksSelectView = [[SSJChargeCircleBooksSelectView alloc] init];
        @weakify(self);
        _booksSelectView.didSelectBooksItem = ^(SSJBooksTypeItem *booksItem) {
            @strongify(self);
            self.item.booksId = booksItem.booksId;
            self.item.booksName = booksItem.booksName;
            [SSJCircleChargeStore getFirstBillItemForBooksId:booksItem.booksId billType:self.item.incomeOrExpence withSuccess:^(SSJRecordMakingBillTypeSelectionCellItem *billItem) {
                self.item.billId = billItem.ID;
                self.item.typeName = billItem.title;
                self.item.imageName = billItem.imageName;
                [self.tableView reloadData];
            } failure:NULL];
        };
    }
    return _booksSelectView;
}

#pragma mark - Event
-(void)saveButtonClicked:(id)sender{
    self.item.membersItem = self.memberSelectView.selectedMemberItems;
    [_moneyInput resignFirstResponder];
    [_memoInput resignFirstResponder];
    if (!_moneyInput.text.length) {
        [CDAutoHideMessageHUD showMessage:@"请输入金额"];
        return;
    }
    
    if (!self.item.membersItem.count) {
        [CDAutoHideMessageHUD showMessage:@"至少选择一个成员"];
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
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError *error) {
        [CDAutoHideMessageHUD showMessage:@"周期记账保存失败"];
    }];
}

-(void)deleteButtonClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
    UIAlertAction *comfirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf deleteChargeConfig];
    }];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"你确定要删除这条周期记账吗?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:cancelAction];
    [alert addAction:comfirmAction];
    [self.navigationController presentViewController:alert animated:YES completion:NULL];
}

- (void)deleteChargeConfig{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *writeDate = [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        if ([db intForQuery:@"select count(1) from bk_charge_period_config where iconfigid = ?",weakSelf.item.sundryId]) {
            [db executeUpdate:@"update bk_charge_period_config set operatortype = 2 ,cwritedate = ? ,iversion = ? where iconfigid = ?",writeDate,@(SSJSyncVersion()),weakSelf.item.sundryId];
        }
        SSJDispatch_main_async_safe(^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    }];
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
        SSJPRINT(@"模拟其中无法打开照相机,请在真机中使用");
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
