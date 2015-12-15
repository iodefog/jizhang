//
//  SSJPagingNetworkService.h
//  SuiShouJi
//
//  Created by old lang on 15/11/2.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

//  分页请求

#import "SSJBaseNetworkService.h"

@interface SSJPagingNetworkService : SSJBaseNetworkService {
    @protected
    NSMutableArray *_itemList;  //  列表数据
}

@property (nonatomic) NSInteger numberPerPage;          // 每页显示条数，默认为10条
@property (nonatomic) NSInteger currentPage;            // 当前页数
@property (readonly, nonatomic) NSInteger totalPage;    // 总页数

/**
 *  返回item的类型，需要子类覆写，默认返回为Nil
 *
 *  @return (NSDictionary *)
 */
- (Class)itemClass;

/**
 *  如果模型中的属性名和字典中的key不相同，子类需要重写此方法返回映射表，默认返回nil
 *
 *  @return (NSDictionary *)
 */
- (NSDictionary *)mappingTable;

/**
 *  获取列表数据
 *
 *  @return (NSArray *)
 */
- (NSArray *)getItems;

@end
