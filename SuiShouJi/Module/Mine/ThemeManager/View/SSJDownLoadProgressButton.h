//
//  SSJDownLoadProgressButton.h
//  SuiShouJi
//
//  Created by ricky on 16/6/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJDownLoadProgressButton : UIView

//下载进度
@property(nonatomic) float downloadProgress;

//进度条颜色
@property(nonatomic, strong) NSString *maskColor;

@property(nonatomic, strong) UIButton *button;

@property(nonatomic, strong) UIView *downloadMaskView;
@end
