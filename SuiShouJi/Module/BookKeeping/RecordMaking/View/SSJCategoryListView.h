//
//  SSJCategoryListView.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/21.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJRecordMakingCategoryItem.h"

@interface SSJCategoryListView : UIView<UIScrollViewDelegate>


typedef void (^CategorySelectedBlock)(SSJRecordMakingCategoryItem *item);


//收入或支出 1为支出,0为收入
@property (nonatomic) BOOL incomeOrExpence;

//选择类型的回调
@property (nonatomic, copy) CategorySelectedBlock CategorySelectedBlock;

//重载数据
-(void)reloadData;

@property(nonatomic,strong) UIScrollView *scrollView;

@property(nonatomic,strong) NSMutableArray *collectionViewArray;

@property (nonatomic,strong) SSJRecordMakingCategoryItem *item;

@property (nonatomic,strong) NSString *selectedId;
@end
