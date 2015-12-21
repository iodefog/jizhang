//
//  SSJCategoryListView.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/21.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJCategoryListView : UIView<UIScrollViewDelegate>

typedef void (^CategorySelected)(NSString *categoryTitle , UIImage *categoryImage);

//选择类型的回调
@property (nonatomic, copy) CategorySelected CategorySelected;

//重载数据
-(void)reloadData;
@end
