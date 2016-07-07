//
//  SSJHomeTableView.h
//  SuiShouJi
//
//  Created by ricky on 16/4/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJHomeTableView : UITableView
typedef void(^tableViewClickBlock)();

@property (nonatomic, copy) tableViewClickBlock tableViewClickBlock;

@property(nonatomic) float lineHeight;

@property(nonatomic) BOOL hasData;

- (void)updateAfterThemeChange;

@end
