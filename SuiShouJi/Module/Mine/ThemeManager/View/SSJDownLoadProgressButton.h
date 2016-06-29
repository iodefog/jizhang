//
//  SSJDownLoadProgressButton.h
//  SuiShouJi
//
//  Created by ricky on 16/6/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJDownLoadProgressButton : UIView
@property(nonatomic) float downloadProgress;
@property(nonatomic, strong) NSString *maskColor;
@property(nonatomic, strong) UIButton *button;
@end
