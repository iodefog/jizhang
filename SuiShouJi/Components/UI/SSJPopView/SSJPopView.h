//
//  SSJPopView.h
//  SuiShouJi
//
//  Created by ricky on 2017/8/1.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJPopView : UIView

@property (nonatomic, copy) void(^didSelectAtIndexBlock)(NSInteger selectIndex);

- (void)setTitles:(NSArray *)titles andImages:(NSArray *)images;

@property (nonatomic, strong) NSString *title;

- (void)showWithSelectedIndex:(NSInteger)index;

- (void)updateCellAppearanceAfterThemeChanged;


@end
