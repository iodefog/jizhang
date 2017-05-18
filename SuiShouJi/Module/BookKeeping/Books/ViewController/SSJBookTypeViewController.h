//
//  SSJBookTypeViewController.h
//  SuiShouJi
//
//  Created by yi cai on 2017/5/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

@interface SSJBookTypeViewController : SSJBaseViewController
/**上一次选择的账本类型indexPath.row*/
@property (nonatomic, assign) NSInteger lastSelectedIndex;

@property (nonatomic, copy) void(^saveBooksBlock)(NSInteger bookTypeIndex);
@end
