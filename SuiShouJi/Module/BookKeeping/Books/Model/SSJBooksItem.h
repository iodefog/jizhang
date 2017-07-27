//
//  SSJBooksItem.h
//  SuiShouJi
//
//  Created by yi cai on 2017/5/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJFinancingGradientColorItem.h"

@protocol SSJBooksItemProtocol

//账本id
@property (nonatomic, strong) NSString *booksId;

//账本名称
@property (nonatomic, strong) NSString *booksName;

//账本颜色
@property (nonatomic, strong) SSJFinancingGradientColorItem *booksColor;

//账本顺序
@property (nonatomic) NSInteger booksOrder;

//账本父类
@property (nonatomic) SSJBooksType booksParent;

@property (nonatomic, strong) NSString *cwriteDate;

- (NSString *)getSingleColor;

- (NSString *)parentIcon;

- (NSString *)parentName;

@end

