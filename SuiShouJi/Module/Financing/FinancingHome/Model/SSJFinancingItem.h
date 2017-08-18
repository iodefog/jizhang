//
//  SSJFinancingItemProtocol.h
//  SuiShouJi
//
//  Created by ricky on 2017/8/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SSJFinancingItemProtocol

//账本id
@property (nonatomic, strong) NSString *booksId;

//账本名称
@property (nonatomic, strong) NSString *booksName;

//账本顺序
@property (nonatomic) NSInteger booksOrder;

//账本父类
@property (nonatomic) SSJBooksType booksParent;

// 共享账本还是日常账本
@property (nonatomic) SSJBooksCategory booksCategory;

@end
