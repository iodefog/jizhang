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
//@property (nonatomic, assign) NSInteger lastSelectedIndex;

@property (nonatomic) SSJBooksType booksType;

@property (nonatomic, copy) void(^saveBooksBlock)(SSJBooksType booksType, NSString *bookName);

/**是否是共享账本进入,目的：友盟统计*/
@property (nonatomic, assign ) BOOL isShareBook;
@end
