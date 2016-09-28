//
//  SSJSearchingViewController.h
//  SuiShouJi
//
//  Created by ricky on 16/9/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNewBaseTableViewController.h"

@interface SSJSearchingViewController : SSJNewBaseTableViewController

typedef NS_ENUM(NSInteger, SSJSearchModel) {
    SSJSearchHistoryModel,   //搜索历史页面
    SSJSearchResultModel     //搜索结果页面
};

@property(nonatomic) SSJSearchModel model;

@end
