//
//  SSJMemoMakingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/2/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMemoMakingViewController.h"

@interface SSJMemoMakingViewController ()
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic,strong) UIImageView *imageView;
@end

@implementation SSJMemoMakingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Getter
-(UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc]init];
    }
    return _textView;
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
