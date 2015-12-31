//
//  SSJCategoryListView.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/21.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJCategoryListView : UIView<UIScrollViewDelegate>

typedef void (^CategorySelected)(NSString *categoryTitle , NSString *categoryImage , NSString *categoryID , NSString *categoryColor);


//收入或支出 1为支出,0为收入
@property (nonatomic) BOOL incomeOrExpence;

//选择类型的回调
@property (nonatomic, copy) CategorySelected CategorySelected;

//重载数据
-(void)reloadData;

@property(nonatomic,strong) UIScrollView *scrollView;

@property(nonatomic,strong) NSMutableArray *collectionViewArray;

@end
