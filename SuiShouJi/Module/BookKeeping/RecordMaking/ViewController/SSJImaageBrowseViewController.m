//
//  SSJImaageBrowseViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/2/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJImaageBrowseViewController.h"
#import "SSJNavigationController.h"

@interface SSJImaageBrowseViewController ()
@property (nonatomic,strong) UIButton *changeImageButton;
@property (nonatomic,strong) UIButton *deleteButton;
@property (nonatomic,strong) UIButton *comfirmButton;
@property (nonatomic,strong) UIView *bottomBackGroundView;
@property (nonatomic,strong) UIImageView *imageBrowser;
@property (nonatomic,strong) UILabel *moneyLabel;
@property (nonatomic,strong) UILabel *memoLabel;
@property (nonatomic,strong) UILabel *dateLabel;
@property(nonatomic, strong) UIView *leftButtonView;
@end

@implementation SSJImaageBrowseViewController{
    UIImage *_selectedImage;
}

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
        self.appliesTheme = NO;
        self.hidesNavigationBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedImage = self.image;
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.imageBrowser];
    [self.view addSubview:self.bottomBackGroundView];
    [self.view addSubview:self.comfirmButton];
    [self.view addSubview:self.deleteButton];
    [self.view addSubview:self.changeImageButton];
    [self.view addSubview:self.moneyLabel];
    [self.view addSubview:self.memoLabel];
    [self.view addSubview:self.dateLabel];
//    [self getImageAndDetails];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor clearColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:self.leftButtonView];
    self.navigationItem.leftBarButtonItem = leftItem;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.imageBrowser.center = self.view.center;
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

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Getter
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
        [_comfirmButton setTitleColor:[UIColor ssj_colorWithHex:@"EE4F4F"] forState:UIControlStateNormal];
        _comfirmButton.layer.cornerRadius = 29;
        _comfirmButton.layer.borderColor = [UIColor ssj_colorWithHex:@"EE4F4F"].CGColor;
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
        _imageBrowser = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    }
    return _imageBrowser;
}


-(UILabel *)moneyLabel{
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc]init];
        _moneyLabel.textColor = [UIColor whiteColor];
        _moneyLabel.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_3];
        _moneyLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _moneyLabel;
}

-(UILabel *)memoLabel{
    if (!_memoLabel) {
        _memoLabel = [[UILabel alloc]init];
        _memoLabel.textColor = [UIColor whiteColor];
        _memoLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _memoLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _memoLabel;
}

-(UIView *)leftButtonView{
    if (!_leftButtonView) {
        _leftButtonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        UIButton *backButton = [[UIButton alloc]init];
        backButton.frame = CGRectMake(0, 0, 44, 44);
        [backButton setImage:[UIImage imageNamed:@"pic_back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_leftButtonView addSubview:backButton];
    }
    return _leftButtonView;
}

-(UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.textColor = [UIColor whiteColor];
        _dateLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _dateLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _dateLabel;
}

#pragma mark - Setter
-(void)setImage:(UIImage *)image{
    _image = image;
    self.imageBrowser.image = image;
    [self updateImageSize];
}

-(void)setItem:(SSJBillingChargeCellItem *)item{
    _item = item;
    if (self.type == SSJImageBrowseVcTypeBrowse) {
        self.deleteButton.hidden = YES;
        self.changeImageButton.hidden = YES;
        self.comfirmButton.hidden = YES;
        if (_item.incomeOrExpence) {
            self.moneyLabel.text = [NSString stringWithFormat:@"%@ : ￥%.2f",_item.typeName,[_item.money doubleValue]];
        }else{
            self.moneyLabel.text = [NSString stringWithFormat:@"%@ : ￥%.2f",_item.typeName,[_item.money doubleValue]];
            
        }
        [self.moneyLabel sizeToFit];
        if (_item.chargeMemo != nil && ![_item.chargeMemo isEqualToString:@""]) {
            self.memoLabel.text = [NSString stringWithFormat:@"备注 : %@",_item.chargeMemo];
            [self.memoLabel sizeToFit];
        }
        self.dateLabel.text = _item.billDate;
        [self.dateLabel sizeToFit];
    }
    
    if (self.item.chargeImage.length != 0) {
        [self.imageBrowser sd_setImageWithURL:SSJImageUrl(self.item.chargeImage, SSJWebImgPathCharge) placeholderImage:nil options:(SDWebImageProgressiveDownload | SDWebImageAllowInvalidSSLCertificates) completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [self updateImageSize];
        }];
    }
}

//-(void)getImageAndDetails{
//
//}

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
        }
        [self.navigationController popViewControllerAnimated:YES];
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
-(void)backButtonClicked:(id)sender{
    [self ssj_backOffAction];
}

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

- (void)updateImageSize {
    UIImage *image = self.imageBrowser.image;
    if (image.size.height > self.view.size.height || image.size.width > self.view.size.width) {
        CGFloat widthScale = image.size.width / self.view.size.width;
        CGFloat heightScale = image.size.height / self.view.size.height;
        CGFloat scale = MAX(widthScale, heightScale);
        self.imageBrowser.width = image.size.width / scale;
        self.imageBrowser.height = image.size.height / scale;
    }else{
        self.imageBrowser.size = image.size;
    }
}

@end
