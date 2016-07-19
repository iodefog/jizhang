//
//  SSJAddNewTypeColorSelectionView.h
//  SuiShouJi
//
//  Created by old lang on 16/5/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

//  自定义类别颜色选择

#import <UIKit/UIKit.h>

@interface SSJAddNewTypeColorSelectionView : UIControl

- (instancetype)initWithWidth:(CGFloat)width;

@property (nonatomic, strong) NSArray *colors;

@property (nonatomic) NSInteger selectedIndex;

@end
