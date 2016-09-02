//
//  SSJRecordMakingCategoryItem.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/29.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJRecordMakingCategoryItem : NSObject
@property (nonatomic,strong) NSString *categoryTitle;
@property (nonatomic,strong) NSString *categoryImage;
@property (nonatomic,strong) NSString *categoryColor;
@property (nonatomic,strong) NSString *categoryID;
@property (nonatomic) int order;

@property (nonatomic,strong) NSString *categoryTintColor;

@property (nonatomic) BOOL selected;

@end
