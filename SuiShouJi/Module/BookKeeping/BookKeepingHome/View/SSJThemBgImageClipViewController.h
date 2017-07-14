//
//  SSJThemBgImageClipViewController.h
//  SuiShouJi
//
//  Created by yi cai on 2017/4/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJBaseViewController.h"

typedef void(^ClipImageBlock)(UIImage *seleImg);
@interface SSJThemBgImageClipViewController : SSJBaseViewController
/**<#注释#>*/

/**<#注释#>*/
@property (nonatomic, copy) ClipImageBlock clipImageBlock;

- (instancetype)initWithNormalImage:(UIImage *)normalImg normalClipSize:(CGSize)clipSize;
@end
