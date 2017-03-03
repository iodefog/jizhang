//
//  SSJBillNoteWebViewController.h
//  SuiShouJi
//
//  Created by yi cai on 2017/1/9.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

//#import "SSJNormalWebViewController.h"

DEPRECATED_ATTRIBUTE
@interface SSJBillNoteWebViewController : UIViewController

@property (nonatomic, copy) void(^backButtonClickBlock)();
/**
 <#注释#>
 */
@property (nonatomic, copy) NSString *urlStr;
@end
