
//
//  SSJNewMemberViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/7/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNewMemberViewController.h"
#import "SSJBaselineTextField.h"

@interface SSJNewMemberViewController ()
@property(nonatomic, strong) SSJBaselineTextField *nameInput;
@end

@implementation SSJNewMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.originalItem.memberName.length) {
        self.title = @"新建成员";
    }else{
        self.title = @"编辑成员";
    }
    // Do any additional setup after loading the view.
}

#pragma mark - Getter
-(SSJBaselineTextField *)nameInput{
    if (!_nameInput) {
        _nameInput = [[SSJBaselineTextField alloc]init];
        _nameInput.text = self.originalItem.memberName;
        _nameInput.font = [UIFont systemFontOfSize:18];
        _nameInput.textAlignment = NSTextAlignmentLeft;
        _nameInput.normalLineColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _nameInput.highlightLineColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _nameInput;
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
