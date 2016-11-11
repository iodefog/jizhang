//
//  SSJLoanChargeAddOrEditViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/11/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanChargeAddOrEditViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJLoanChargeModel.h"

@interface SSJLoanChargeAddOrEditViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@end

@implementation SSJLoanChargeAddOrEditViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - Private


#pragma mark - Getter
- (TPKeyboardAvoidingTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
//        [_tableView registerClass:[SSJAddOrEditLoanLabelCell class] forCellReuseIdentifier:kAddOrEditLoanLabelCellId];
//        [_tableView registerClass:[SSJAddOrEditLoanTextFieldCell class] forCellReuseIdentifier:kAddOrEditLoanTextFieldCellId];
//        [_tableView registerClass:[SSJAddOrEditLoanMultiLabelCell class] forCellReuseIdentifier:kAddOrEditLoanMultiLabelCellId];
        _tableView.sectionHeaderHeight = 10;
        _tableView.sectionFooterHeight = 0;
    }
    return _tableView;
}

@end
