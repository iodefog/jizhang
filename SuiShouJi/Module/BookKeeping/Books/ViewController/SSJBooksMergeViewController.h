//
//  SSJBooksMergeViewController.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "SSJBooksItem.h"

@interface SSJBooksMergeViewController : SSJBaseViewController

@property (nonatomic, strong) __kindof SSJBaseCellItem<SSJBooksItemProtocol> *transferInBooksItem;

@property (nonatomic, strong) __kindof SSJBaseCellItem<SSJBooksItemProtocol> *transferOutBooksItem;


@end
