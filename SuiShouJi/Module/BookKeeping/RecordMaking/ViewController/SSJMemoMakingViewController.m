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
@property (nonatomic,strong) UIView *rightbuttonView;
@end

@implementation SSJMemoMakingViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"备注";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:self.rightbuttonView];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    [self.view addSubview:self.textView];
    [self.view addSubview:self.imageView];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.imageView.size = CGSizeMake(50, 50);
    self.imageView.leftTop = CGPointMake(0, 10);
    self.textView.size = CGSizeMake(self.view.width - self.imageView.width , self.view.height);
    self.textView.leftTop = CGPointMake(self.imageView.right, 0);
}

#pragma mark - Getter
-(SSJCustomTextView *)textView{
    if (!_textView) {
        _textView = [[SSJCustomTextView alloc]init];
        if ([self.oldMemo isEqualToString:@""] || self.oldMemo == nil) {
            _textView.placeholder = @"好记性不如烂笔头,备忘录开启~";
        }else{
            _textView.text = self.oldMemo;
        }
    }
    return _textView;
}

-(UIView *)rightbuttonView{
    if (!_rightbuttonView) {
        _rightbuttonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 22, 22)];
        UIButton *comfirmButton = [[UIButton alloc]init];
        comfirmButton.frame = CGRectMake(0, 0, 22, 22);
        [comfirmButton setBackgroundImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
        [comfirmButton addTarget:self action:@selector(comfirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_rightbuttonView addSubview:comfirmButton];
    }
    return _rightbuttonView;
}

-(UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.image = [UIImage imageNamed:@"home_pen"];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

#pragma mark - Private
-(void)comfirmButtonClick:(id)sender{
    if (self.MemoMakingBlock) {
        self.MemoMakingBlock(self.textView.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
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
