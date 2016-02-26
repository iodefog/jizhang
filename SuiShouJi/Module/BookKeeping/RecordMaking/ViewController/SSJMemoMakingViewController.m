//
//  SSJMemoMakingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/2/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMemoMakingViewController.h"
#import "SSJCustomTextView.h"

@interface SSJMemoMakingViewController ()
@property (nonatomic,strong) SSJCustomTextView *textView;
@property (nonatomic,strong) UIImageView *imageView;
@end

@implementation SSJMemoMakingViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.textView];
    [self.view addSubview:self.imageView];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.textView.frame = self.view.frame;
}

#pragma mark - Getter
-(SSJCustomTextView *)textView{
    if (!_textView) {
        _textView = [[SSJCustomTextView alloc]init];
        if ([self.memo isEqualToString:@""] || self.memo == nil) {
            _textView.placeholder = @"好记性不如烂笔头,备忘录开启~";
        }else{
            _textView.text = self.memo;
        }
    }
    return _textView;
}

-(UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
    }
    return _imageView;
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
