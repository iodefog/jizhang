//
//  SSJRecordMakingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/16.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingViewController.h"
#import "SSJCustomKeyboard.h"

@interface SSJRecordMakingViewController ()
@property (nonatomic,strong) SSJCustomKeyboard* customKeyBoard;
@property (nonatomic,strong) UICollectionView* collectionView;
@property (nonatomic,strong) UIView* selectedCategoryView;
@property (nonatomic,strong) UIView* inputView;

@property (nonatomic,strong) UILabel* textInput;
@property (nonatomic,strong) UILabel* categoryNameLabel;
@property (nonatomic,strong) UIImageView* categoryImage;

@end

@implementation SSJRecordMakingViewController{
    NSString *_caculationResult;
}
#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.selectedCategoryView];
    [self.selectedCategoryView addSubview:self.textInput];
    [self.selectedCategoryView addSubview:self.categoryNameLabel];
    [self.selectedCategoryView addSubview:self.categoryImage];
    [self.view addSubview:self.inputView];
    [self.inputView addSubview:self.customKeyBoard];

}

-(void)viewDidLayoutSubviews{
    self.selectedCategoryView.leftTop = CGPointMake(0, 0);
    self.categoryImage.left = 12.0f;
    self.categoryImage.centerY = self.selectedCategoryView.centerY;
    self.textInput.right = self.selectedCategoryView.right - 12;
    self.textInput.centerY = self.categoryImage.centerY;
    self.categoryNameLabel.left = self.categoryImage.right + 5;
    self.categoryNameLabel.centerY = self.categoryImage.centerY;
    self.inputView.bottom = self.view.bottom;
}

#pragma mark SSJCustomKeyboardDelegate
- (void)didNumKeyPressed:(UIButton *)button{
    if (self.customKeyBoard.decimalModel == NO) {
        if ([self.textInput.text isEqualToString:@"0.00"]) {
            self.textInput.text = [NSString stringWithFormat:@"%.2f",[[NSString stringWithFormat:@"%@",button.titleLabel.text] floatValue] ];
            return;
        }
        self.textInput.text = [NSString stringWithFormat:@"%ld%@.00",[self.textInput.text integerValue],button.titleLabel.text];
    }else{
        NSString *intPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:0];
        NSString *decimalPart = [[self.textInput.text componentsSeparatedByString:@"."] objectAtIndex:1];
        if ([decimalPart isEqualToString:@"00"] && ![button.titleLabel.text isEqualToString:@"0"]) {
            self.textInput.text = [NSString stringWithFormat:@"%@.%@0",intPart,button.titleLabel.text];
        }else{
            if ([decimalPart hasSuffix:@"0"]) {
                decimalPart = [decimalPart substringWithRange:NSMakeRange(0, 1)];
                self.textInput.text =[NSString stringWithFormat:@"%@.%@%@",intPart,decimalPart,button.titleLabel.text];
                    return;
            }
            decimalPart = [NSString stringWithFormat:@"%@%@",decimalPart,button.titleLabel.text];
                decimalPart = [decimalPart substringWithRange:NSMakeRange(0, 2)];
            self.textInput.text = [NSString stringWithFormat:@"%@.%@",intPart,decimalPart];
        }
    }
}

- (void)didDecimalPointKeyPressed{
    self.customKeyBoard.decimalModel = YES;
}

- (void)didClearKeyPressed{
    self.textInput.text = @"0.00";
    self.customKeyBoard.decimalModel = NO;
}

- (void)didBackspaceKeyPressed{
    
}

- (void)didPlusKeyPressed{
    
}

- (void)didMinusKeyPressed{
    
}

- (void)didComfirmKeyPressed:(UIButton*)button{
    if ([button.titleLabel.text isEqualToString:@"确定"]) {
        NSLog(@"确定");
    }else if ([button.titleLabel.text isEqualToString:@"="]){
        
    }
}

#pragma mark - Getter
-(SSJCustomKeyboard*)customKeyBoard{
    if (!_customKeyBoard) {
        _customKeyBoard = [[SSJCustomKeyboard alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 216)];
        _customKeyBoard.delegate = self;
    }
    return _customKeyBoard;
}

-(UIView*)selectedCategoryView{
    if (!_selectedCategoryView) {
        _selectedCategoryView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        [_selectedCategoryView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_selectedCategoryView ssj_setBorderWidth:1.0f];
        [_selectedCategoryView ssj_setBorderColor:[UIColor blackColor]];
    }
    return _selectedCategoryView;
}

-(UILabel*)textInput{
    if (!_textInput) {
        _textInput = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 44)];
        _textInput.font = [UIFont systemFontOfSize:18];
        _textInput.textAlignment = NSTextAlignmentRight;
        _textInput.text = @"0.00";
    }
    return _textInput;
}

-(UIImageView*)categoryImage{
    if (!_categoryImage) {
        _categoryImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 26, 26)];
        _categoryImage.layer.cornerRadius = 13;
        _categoryImage.layer.masksToBounds = YES;
        _categoryImage.image = [UIImage imageNamed:@"餐饮 测试"];
    }
    return _categoryImage;
}

-(UIView*)inputView{
    if (!_inputView ) {
        _inputView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 216)];
        _inputView.backgroundColor = [UIColor yellowColor];
    }
    return _inputView;
}

-(UILabel*)categoryNameLabel{
    if (!_categoryNameLabel) {
        _categoryNameLabel = [[UILabel alloc]init];
        _categoryNameLabel.text = @"餐饮";
        [_categoryNameLabel sizeToFit];
        _categoryNameLabel.font = [UIFont systemFontOfSize:15];
    }
    return _categoryNameLabel;
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
