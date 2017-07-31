//
//  SSJBooksSelectView.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJBooksItem.h"


@interface SSJBooksSelectView : UIView

@property (nonatomic, strong) NSArray *booksItems;

- (void)showWithSelectedItem:(SSJBaseCellItem <SSJBooksItemProtocol> *)item;

@property (nonatomic, copy) void(^booksTypeSelectBlock)(SSJBaseCellItem <SSJBooksItemProtocol> *item);

@end
