//
//  SSJLoginGraphVerView.h
//  SuiShouJi
//
//  Created by yi cai on 2017/6/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJLoginGraphVerView : UIView
/**title*/
@property (nonatomic, copy) NSString *titleStr;

/**验证码*/
@property (nonatomic, strong) UIImage *verImage;


- (void)show;
@end
