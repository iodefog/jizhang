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

/**原始图片*/
@property (nonatomic, strong) UIImage *normalImage;

/**<#注释#>*/
@property (nonatomic, assign) CGSize normalImagesize;

/**最原始的裁剪框大小*/
@property (nonatomic, assign) CGSize normalClipSize;

/**
 最终图片
 */
@property (nonatomic, strong) UIImage *selectedImage;

@property (nonatomic, strong) CALayer *clipView;


@property (nonatomic, strong) CAShapeLayer *coverLayer;
@end
static CGFloat imageScale = 0.8; //裁剪框和真实尺寸大小比例
@implementation SSJThemBgImageClipViewController

- (instancetype)initWithNormalImage:(UIImage *)normalImg normalClipSize:(CGSize)clipSize {
    if (self = [super init]) {
        self.normalClipSize = clipSize;
        self.normalImage = normalImg;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.scrollview];
    [self.scrollview addSubview:self.imageView];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.chooseButton];
    self.view.backgroundColor = [UIColor blackColor];
    self.scrollview.backgroundColor = [UIColor blackColor];
    [self.view.layer addSublayer:self.coverLayer];
    [self.view.layer addSublayer:self.clipView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.scrollview.frame = self.view.bounds;
    self.cancelButton.leftBottom = CGPointMake(20, self.view.height - 20);
    self.chooseButton.rightBottom = CGPointMake(self.view.width - 20, self.view.height - 20);
    self.clipView.size = CGSizeMake(self.normalClipSize.width*imageScale, self.normalClipSize.height*imageScale);
    self.clipView.left = (self.view.width - self.clipView.size.width)*0.5;
    self.clipView.top = (self.view.height - self.clipView.size.height)*0.5;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - Setter
- (void)setNormalImage:(UIImage *)normalImage
{
    float imageHeight = normalImage.size.height;
    float imageWidth = normalImage.size.width;
    float maxLegth = MAX(imageHeight , imageWidth);
    float tempscale = 1;
    if (maxLegth > 2000) {
        tempscale = 2000 / maxLegth;
        imageHeight = imageHeight * tempscale;
        imageWidth = imageWidth * tempscale;
    }
    UIImage *resizeImage = [self clipWithImageRect:CGRectMake(0, 0, imageWidth, imageHeight) clipImage:normalImage];
    normalImage = [resizeImage fixOrientation];
    _normalImage = normalImage;
    self.normalImagesize = CGSizeMake(normalImage.size.width, normalImage.size.height);
//    self.oldImage = normalImage;
    self.imageView.image = normalImage;
    double clipH = self.normalClipSize.height * imageScale;
    double clipW = self.normalClipSize.width * imageScale;
    double imgH = normalImage.size.height;
    double imgW = normalImage.size.width;
    if (imgW > imgH) { //宽》 高
        if (imgH <= clipH) {
            self.imageView.size = normalImage.size;
        } else {//imgh>cliph
            double scale = imgW / imgH;
            self.imageView.size = CGSizeMake(clipH * scale, clipH);
            if (self.imageView.width < clipW && imgW > clipW) {
                double scale1 = imgH / imgW;
                self.imageView.size = CGSizeMake(clipW, clipW * scale1);
            }
        }
    } else { //高》宽
        if (imgW <= clipW) {
            self.imageView.size = normalImage.size;
        } else {//imgw>clipW
            double scale = imgH / imgW;
            self.imageView.size = CGSizeMake(clipW, clipW * scale);
            
            if (self.imageView.height < clipH && imgH > clipH) {
                double scale1 = imgW / imgH;
                self.imageView.size = CGSizeMake(clipH*scale1, clipH);
            }
        }
    }

    self.scrollview.contentSize = self.imageView.size;
    CGPoint conOfSet = self.scrollview.contentOffset;
    conOfSet.x = -self.normalClipSize.width * (1 - imageScale) * 0.5;
    conOfSet.y = -(SSJSCREENHEIGHT - self.normalClipSize.height *imageScale) *0.5;
    
    self.scrollview.contentOffset = conOfSet;
}

#pragma mark - Event
- (void)chooseButtonClicked
{
    CGPoint conOfSet = self.scrollview.contentOffset;
    
    //计算裁剪比例
    CGFloat imageClipScale = self.normalImagesize.width / self.imageView.width;
    CGSize clipSize = CGSizeMake(self.clipView.width * imageClipScale, self.clipView.height * imageClipScale);
    CGFloat clipLeft = 0;
    CGFloat clipTop = 0;
    
    CGRect imageViewFrame = [self.imageView convertRect:self.imageView.frame toView:self.view];
    clipLeft = (self.clipView.left - imageViewFrame.origin.x) * imageClipScale;
    clipTop = (self.clipView.top - imageViewFrame.origin.y) * imageClipScale;
    
    CGRect clipRect = CGRectMake(clipLeft, clipTop, clipSize.width, clipSize.height);
    self.selectedImage = [self imageFromView:self.view atFrame:clipRect];
//    [UIImagePNGRepresentation(self.selectedImage) writeToFile:@"/Users/yicai/Desktop/test.png" atomically:YES];
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
//获得某个范围内的屏幕图像
- (UIImage *)imageFromView: (UIView *)theView atFrame:(CGRect)rect
{
    UIImage * image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(self.normalImage.CGImage, rect)];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.4);
    return  [UIImage imageWithData:imageData];
}

//返回裁剪区域图片,返回裁剪区域大小图片
- (UIImage *)clipWithImageRect:(CGRect)clipRect clipImage:(UIImage *)clipImage
{
    UIGraphicsBeginImageContext(clipRect.size);
    [clipImage drawInRect:CGRectMake(0,0,clipRect.size.width,clipRect.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Lazy
- (UIScrollView *)scrollview
{
    if (!_scrollview) {
        _scrollview = [[UIScrollView alloc] init];
        _scrollview.delegate = self;
        _scrollview.minimumZoomScale = 0.2;
        _scrollview.maximumZoomScale = MAXFLOAT;
        self.scrollview.contentInset = UIEdgeInsetsMake((self.view.height - self.clipView.height) * 0.5, (self.view.width - self.clipView.width) * 0.5, (self.view.height - self.clipView.height) * 0.5, (self.view.width - self.clipView.width) * 0.5);
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

- (CALayer *)clipView {
    if (!_clipView) {
        _clipView = [CALayer layer];
        _clipView.borderWidth = 1;
        _clipView.backgroundColor = [UIColor clearColor].CGColor;
        _clipView.borderColor = [UIColor whiteColor].CGColor;
    }
    return _clipView;
}

- (CAShapeLayer *)coverLayer
{
    if (!_coverLayer) {
        _coverLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        CGPoint leftTop = CGPointMake(0, 0);
        CGPoint rightTop = CGPointMake(SSJSCREENWITH, 0);
        CGPoint leftBottom = CGPointMake(0, SSJSCREENHEIGHT);
        CGPoint rightBottom = CGPointMake(SSJSCREENWITH, SSJSCREENHEIGHT);
        
        CGFloat leftPad = (SSJSCREENWITH - self.normalClipSize.width * imageScale) * 0.5;//SSJSCREENWITH * (1 - imageScale) * 0.5;
        CGFloat topPad = (SSJSCREENHEIGHT - self.normalClipSize.height * imageScale) * 0.5;//SSJSCREENHEIGHT * (1 - imageScale) * 0.5;
        CGPoint leftTops = CGPointMake(leftPad, topPad);
        CGPoint rightTops = CGPointMake(SSJSCREENWITH - leftPad, topPad);
        CGPoint leftBottoms = CGPointMake(leftPad, SSJSCREENHEIGHT - topPad);
        CGPoint rightBottoms = CGPointMake(SSJSCREENWITH - leftPad, SSJSCREENHEIGHT - topPad);
        
        [path moveToPoint:leftTop];
        [path addLineToPoint:leftTops];
        [path addLineToPoint:rightTops];
        [path addLineToPoint:rightTop];
        [path closePath];
        
        [path moveToPoint:rightTop];
        [path addLineToPoint:rightTops];
        [path addLineToPoint:rightBottoms];
        [path addLineToPoint:rightBottom];
        [path closePath];
        
        [path moveToPoint:rightBottom];
        [path addLineToPoint:rightBottoms];
        [path addLineToPoint:leftBottoms];
        [path addLineToPoint:leftBottom];
        [path closePath];
        
        [path moveToPoint:leftBottom];
        [path addLineToPoint:leftBottoms];
        [path addLineToPoint:leftTops];
        [path addLineToPoint:leftTop];
        [path closePath];
        
        
        [_coverLayer setFillColor:[UIColor ssj_colorWithHex:@"000000" alpha:0.5].CGColor];
        _coverLayer.path = path.CGPath;
    }
    return _coverLayer;
}
@end
