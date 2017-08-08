//
//  SSJWishPhotoChooseViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishPhotoChooseViewController.h"
#import "SSJThemBgImageClipViewController.h"

#import "SSJWishPhotoChooseCollectionViewCell.h"

@interface SSJWishPhotoChooseViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UICollectionView *imageCollectionView;

@property (nonatomic, strong) NSArray *dataArray;
@end
static NSString *wishChoosePhotoCellId = @"SSJWishPhotoChooseCollectionViewCellId";
@implementation SSJWishPhotoChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"愿景图片";
    [self.view addSubview:self.imageCollectionView];
    [self updateViewConstraints];
}

- (void)updateViewConstraints {
    [self.imageCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(SSJ_NAVIBAR_BOTTOM);
    }];
    [super updateViewConstraints];
}

#pragma mark - Private
//选择相册
-(void)openLocalPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    //    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:^{}];
}

- (NSString *)localImageSelectedWithImgIndex:(NSInteger)imgIndex {
    switch (imgIndex) {
        case 1:
            return @"wish_image_def_one";
            break;
        case 2:
            return @"wish_image_def_two";
            break;
        case 3:
            return @"wish_image_def_three";
            break;
        case 4:
            return @"wish_image_def_four";
            break;
        case 5:
            return @"wish_image_def_five";
            break;
            
        default:
            return @"";
            break;
    }
    return nil;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:NO completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (!image) return;
    //图片编辑
    SSJThemBgImageClipViewController *imageClipVC = [[SSJThemBgImageClipViewController alloc] initWithNormalImage:image normalClipSize:CGSizeMake(SSJSCREENWITH, kFinalImgHeight(SSJSCREENWITH))];
    @weakify(self);
    imageClipVC.clipImageBlock = ^(UIImage *newImage) {
        @strongify(self);
        if (self.changeTopImage) {
            self.changeTopImage(newImage,SSJWishCustomImageName);
        }
    };
    [self presentViewController:imageClipVC animated:YES completion:NULL];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SSJWishPhotoChooseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:wishChoosePhotoCellId forIndexPath:indexPath];
    [cell setImage:[self.dataArray ssj_safeObjectAtIndex:indexPath.row] indexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self openLocalPhoto];
        return;
    }
    //切换背景
    if (self.changeTopImage) {
        self.changeTopImage([UIImage imageNamed:[self.dataArray ssj_safeObjectAtIndex:indexPath.row]],[self.dataArray ssj_safeObjectAtIndex:indexPath.row]);
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((SSJSCREENWITH - 50) * 0.5, kFinalImgHeight((SSJSCREENWITH - 50) * 0.5));
}

#pragma mark - Lazy

- (UICollectionView *)imageCollectionView {
    if (!_imageCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 15;
        flowLayout.minimumLineSpacing = 15;
        flowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
        _imageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _imageCollectionView.delegate = self;
        _imageCollectionView.dataSource = self;
        _imageCollectionView.backgroundColor = [UIColor clearColor];
        [_imageCollectionView registerClass:[SSJWishPhotoChooseCollectionViewCell class] forCellWithReuseIdentifier:wishChoosePhotoCellId];
    }
    return _imageCollectionView;
}


- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[@"wish_image_def",@"wish_image_def_one",@"wish_image_def_two",@"wish_image_def_three",@"wish_image_def_four",@"wish_image_def_five"];
    }
    return _dataArray;
}

@end
