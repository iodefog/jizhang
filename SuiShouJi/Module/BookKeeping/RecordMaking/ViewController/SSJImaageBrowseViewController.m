//
//  SSJImaageBrowseViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/2/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJImaageBrowseViewController.h"

@interface SSJImaageBrowseViewController ()
@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) UIButton *changeImageButton;
@property (nonatomic,strong) UIButton *deleteButton;
@property (nonatomic,strong) UIButton *comfirmButton;
@property (nonatomic,strong) UIView *bottomBackGroundView;
@property (nonatomic,strong) UIImageView *imageBrowser;
@property (nonatomic,strong) UILabel *moneyLabel;
@property (nonatomic,strong) UILabel *memoLabel;
@property (nonatomic,strong) UILabel *dateLabel;
@end

@implementation SSJImaageBrowseViewController{
    UIImage *_selectedImage;
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
    _selectedImage = self.image;
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.imageBrowser];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.bottomBackGroundView];
    [self.view addSubview:self.comfirmButton];
    [self.view addSubview:self.deleteButton];
    [self.view addSubview:self.changeImageButton];
    [self.view addSubview:self.moneyLabel];
    [self.view addSubview:self.memoLabel];
    [self.view addSubview:self.dateLabel];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];

}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.imageBrowser.center = self.view.center;
    self.backButton.size = CGSizeMake(30, 30);
    self.backButton.leftTop = CGPointMake(10, 10);
    self.bottomBackGroundView.size = CGSizeMake(self.view.width, 100);
    self.bottomBackGroundView.bottom = self.view.height;
    self.comfirmButton.size = CGSizeMake(58, 58);
    self.comfirmButton.center = self.bottomBackGroundView.center;
    self.changeImageButton.size = CGSizeMake(45, 70);
    self.changeImageButton.top = self.bottomBackGroundView.top + 10;
    self.changeImageButton.centerX = self.comfirmButton.left / 2;
    self.deleteButton.size = CGSizeMake(45, 70);
    self.deleteButton.top = self.bottomBackGroundView.top + 10;
    self.deleteButton.centerX = self.comfirmButton.right + (self.view.width - self.comfirmButton.right) / 2;
    self.moneyLabel.leftTop = CGPointMake(10, self.bottomBackGroundView.top + 10);
    self.memoLabel.leftTop = CGPointMake(10, self.moneyLabel.bottom + 10);
    self.dateLabel.rightTop = CGPointMake(self.view.width - 10, self.bottomBackGroundView.top + 10);
}

#pragma mark - Getter
-(UIButton *)backButton{
    if (!_backButton) {
        _backButton = [[UIButton alloc]init];
        [_backButton setImage:[UIImage imageNamed:@"home_back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_backButton ssj_setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] forState:UIControlStateNormal];
    }
    return _backButton;
}

-(UIButton *)changeImageButton{
    if (!_changeImageButton) {
        _changeImageButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 70)];
        [_changeImageButton setTitle:@"替换" forState:UIControlStateNormal];
        [_changeImageButton setImage:[UIImage imageNamed:@"tihuan"] forState:UIControlStateNormal];
        _changeImageButton.contentLayoutType = SSJButtonLayoutTypeImageTopTitleBottom;
        [_changeImageButton addTarget:self action:@selector(changeImageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeImageButton;
}

-(UIButton *)deleteButton{
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 70)];
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteButton setImage:[UIImage imageNamed:@"white_delete"] forState:UIControlStateNormal];
        _deleteButton.contentLayoutType = SSJButtonLayoutTypeImageTopTitleBottom;
        [_deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _deleteButton;
}

-(UIButton *)comfirmButton{
    if (!_comfirmButton) {
        _comfirmButton = [[UIButton alloc]init];
        [_comfirmButton setTitle:@"OK" forState:UIControlStateNormal];
        [_comfirmButton setTitleColor:[UIColor ssj_colorWithHex:@"47cfbe"] forState:UIControlStateNormal];
        _comfirmButton.layer.cornerRadius = 29;
        _comfirmButton.layer.borderColor = [UIColor ssj_colorWithHex:@"47cfbe"].CGColor;
        _comfirmButton.layer.borderWidth = 1;
        [_comfirmButton addTarget:self action:@selector(comfirmButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _comfirmButton;
}

-(UIView *)bottomBackGroundView{
    if (!_bottomBackGroundView) {
        _bottomBackGroundView = [[UIView alloc]init];
        _bottomBackGroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }
    return _bottomBackGroundView;
}

-(UIImageView *)imageBrowser{
    if (!_imageBrowser) {
        _imageBrowser = [[UIImageView alloc]init];
    }
    return _imageBrowser;
}

-(void)backButtonClicked:(id)sender{
    [self ssj_backOffAction];
}

-(UILabel *)moneyLabel{
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc]init];
        _moneyLabel.textColor = [UIColor whiteColor];
        _moneyLabel.font = [UIFont systemFontOfSize:15];
        _moneyLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _moneyLabel;
}

-(UILabel *)memoLabel{
    if (!_memoLabel) {
        _memoLabel = [[UILabel alloc]init];
        _memoLabel.textColor = [UIColor whiteColor];
        _memoLabel.font = [UIFont systemFontOfSize:15];
        _memoLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _memoLabel;
}

-(UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.textColor = [UIColor whiteColor];
        _dateLabel.font = [UIFont systemFontOfSize:15];
        _dateLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _dateLabel;
}

#pragma mark - Setter
-(void)setImage:(UIImage *)image{
    _image = image;
    if (image.size.height > self.view.size.height && image.size.width > self.view.size.width) {
        self.imageBrowser.width = self.view.width;
        self.imageBrowser.height = (self.view.width / self.image.size.width)*self.image.size.height;
    }else{
        self.imageBrowser.size = image.size;
    }
    self.imageBrowser.image = image;
}

-(void)setItem:(SSJBillingChargeCellItem *)item{
    _item = item;
    self.deleteButton.hidden = YES;
    self.changeImageButton.hidden = YES;
    self.comfirmButton.hidden = YES;
    if (item.incomeOrExpence) {
        self.moneyLabel.text = [NSString stringWithFormat:@"%@ : -%.2f",_item.typeName,[_item.money doubleValue]];
    }else{
        self.moneyLabel.text = [NSString stringWithFormat:@"%@ : +%.2f",_item.typeName,[_item.money doubleValue]];

    }
    [self.moneyLabel sizeToFit];
    if (_item.chargeMemo != nil && ![item.chargeMemo isEqualToString:@""]) {
        self.memoLabel.text = [NSString stringWithFormat:@"备注 : %@",_item.chargeMemo];
        [self.memoLabel sizeToFit];
    }
    self.dateLabel.text = _item.billDate;
    [self.dateLabel sizeToFit];
    if (!(self.item.chargeImage == nil || [self.item.chargeImage isEqualToString:@""])) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:SSJImagePath(self.item.chargeImage)]) {
            UIImage *image = [UIImage imageWithContentsOfFile:SSJImagePath(self.item.chargeImage)];
            if (image.size.height > self.view.size.height && image.size.width > self.view.size.width) {
                self.imageBrowser.width = self.view.width;
                self.imageBrowser.height = (self.view.width / image.size.width)* image.size.height;
            }else{
                self.imageBrowser.size = image.size;
            }
            self.imageBrowser.image = image;
        }else{
            [self.imageBrowser sd_setImageWithURL:[NSURL URLWithString:SSJGetChargeImageUrl(self.item.chargeThumbImage)]completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image.size.height > self.view.size.height && image.size.width > self.view.size.width) {
                    self.imageBrowser.width = self.view.width;
                    self.imageBrowser.height = (self.view.width / image.size.width)* image.size.height;
                }else{
                    self.imageBrowser.size = image.size;
                }
            }];
        }
    }
}

#pragma mark - UIActionSheetDelegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 10) {
        switch (buttonIndex)
        {
            case 0:  //打开照相机拍照
                [self takePhoto];
                break;
            case 1:  //打开本地相册
                [self localPhoto];
                break;
        }
    }else{
        if (self.DeleteImageBlock) {
            self.DeleteImageBlock();
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.image = image;
    _selectedImage = image;
}

#pragma mark - Private
-(void)changeImageButtonClicked:(id)sender{
    UIActionSheet *sheet;
    sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄照片" ,@"从相册选择", nil];
    sheet.tag = 10;
    [sheet showInView:self.view];
}

-(void)deleteButtonClicked:(id)sender{
    UIActionSheet *sheet;
    sheet = [[UIActionSheet alloc] initWithTitle:@"确定要删除这张照片吗" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除" , nil];
    sheet.tag = 11;
    [sheet showInView:self.view];
}

-(void)comfirmButtonClicked:(id)sender{
    if (self.NewImageSelectedBlock) {
        self.NewImageSelectedBlock(_selectedImage);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)takePhoto{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:^{}];
    }else
    {
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
