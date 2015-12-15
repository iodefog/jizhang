//
//  SSJPageNetworkService.h
//  YYDB
//
//  Created by cdd on 15/11/5.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"

@class SSJPageModel;

@interface SSJPageNetworkService : SSJBaseNetworkService

@property (assign, nonatomic,readonly) BOOL loadFromTop;
@property (nonatomic, strong,readonly) SSJPageModel *page;
@property (strong, nonatomic,readonly) NSArray *datas;

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
 *  加载（子类包装调用,也可直接调用）
 *
 *  @param api     请求相对地址（不含host）
 *  @param dict    参数（不需要传入pn，ps）
 *  @param fromTop 是否从第一页加载
 *  @param show    是否显示网络加载指示器
 */
- (void)loadService:(NSString *)api Params:(NSDictionary *)dict FromTop:(BOOL)fromTop ShowIndicator:(BOOL)show;

@end
