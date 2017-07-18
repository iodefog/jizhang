//
//  SSJWishPhotoChooseViewController.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

@interface SSJWishPhotoChooseViewController : SSJBaseViewController

typedef void(^ChangeTopImage)(UIImage *seleImg);

@property (nonatomic, copy) ChangeTopImage changeTopImage;
@end
