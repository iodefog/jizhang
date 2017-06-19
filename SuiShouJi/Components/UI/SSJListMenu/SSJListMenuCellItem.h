//
//  SSJListMenuCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/7/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJListMenuCellItem : SSJBaseCellItem

@property (nonatomic) CGSize imageSize;

@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, strong) UIColor *imageColor;

@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic) CGFloat gapBetweenImageAndTitle;

@property (nonatomic) UIControlContentHorizontalAlignment contentAlignment;

@property (nonatomic) UIEdgeInsets contentInset;

@property (nonatomic, strong) UIColor *backgroundColor;

@end
