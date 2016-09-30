//
//  SSJSearchBar.h
//  SuiShouJi
//
//  Created by ricky on 16/9/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJSearchBar : UIView

@property(nonatomic, strong) UISearchBar *searchTextInput;

@property (nonatomic, copy) void (^cancelAction)();

@end
