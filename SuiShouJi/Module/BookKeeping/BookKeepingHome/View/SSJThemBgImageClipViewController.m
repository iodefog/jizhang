//
//  SSJThemBgImageClipViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/4/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJThemBgImageClipViewController.h"

@interface SSJThemBgImageClipViewController ()<UIScrollViewDelegate>


@property (nonatomic, strong) UIScrollView *scrollview;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIButton *chooseButton;

@property (nonatomic, strong) UIButton *cancelButton;

/**<#注释#>*/
@property (nonatomic, strong) UIImage *selectedImage;

@end

@implementation SSJThemBgImageClipViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.scrollview];
    [self.scrollview addSubview:self.imageView];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.chooseButton];
    self.view.backgroundColor = [UIColor blackColor];
    self.scrollview.backgroundColor = [UIColor blackColor];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.scrollview.frame = self.view.bounds;
    self.cancelButton.leftBottom = CGPointMake(20, self.view.height - 20);
    self.chooseButton.rightBottom = CGPointMake(self.view.width - 20, self.view.height - 20);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self.imageView sizeToFit];
    self.scrollview.contentSize = self.imageView.size;
    self.imageView.center = CGPointMake(self.scrollview.contentSize.width*0.5, self.scrollview.contentSize.height*0.5);
    if (self.imageView.size.width < self.view.width) {
        self.imageView.centerX = self.view.width*0.5;
    }
    if (self.imageView.size.height<self.view.height) {
        self.imageView.centerY = self.view.height*0.5;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - Setter
- (void)setNormalImage:(UIImage *)normalImage
{
    _normalImage = normalImage;
    self.imageView.image = normalImage;
    self.imageView.size = CGSizeMake(normalImage.size.width, normalImage.size.height);
    self.scrollview.contentSize = self.imageView.size;
    self.imageView.center = CGPointMake(self.scrollview.contentSize.width*0.5, self.scrollview.contentSize.height*0.5);
    if (self.imageView.size.width < self.view.width) {
        self.imageView.centerX = self.view.width*0.5;
    }
    if (self.imageView.size.height<self.view.height) {
        self.imageView.centerY = self.view.height*0.5;
    }
}

#pragma mark - Event
- (void)chooseButtonClicked
{
    //裁剪图片
    //隐藏取消选择按钮
    self.chooseButton.hidden = YES;
    self.cancelButton.hidden = YES;
   self.selectedImage = [self screenView:self.view];
    if (!self.selectedImage) return;
    if (self.clipImageBlock) {
        self.clipImageBlock(self.selectedImage);
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)cancelButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private
//截图
- (UIImage*)screenView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.width, view.height), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark - Lazy
- (UIScrollView *)scrollview
{
    if (!_scrollview) {
        _scrollview = [[UIScrollView alloc] init];
        _scrollview.delegate = self;
        _scrollview.minimumZoomScale = 0.2;
        _scrollview.maximumZoomScale = 2;
    }
    return _scrollview;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UIButton *)chooseButton
{
    if (!_chooseButton) {
        _chooseButton = [[UIButton alloc] init];
        [_chooseButton setTitle:@"选择" forState:UIControlStateNormal];
        [_chooseButton addTarget:self action:@selector(chooseButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_chooseButton sizeToFit];
    }
    return _chooseButton;
}

- (UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton sizeToFit];
    }
    return _cancelButton;
}
@end
