//
//  SSJPagingNetworkService.m
//  SuiShouJi
//
//  Created by old lang on 15/11/2.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJPagingNetworkService.h"
#import "SSJLoadMoreItem.h"
#import "NSObject+MJKeyValue.h"

@interface SSJPagingNetworkService ()

@property (readwrite, nonatomic) NSInteger totalPage;      // 总页数
@property (nonatomic, strong) NSMutableArray *itemList;

@end

@implementation SSJPagingNetworkService

- (instancetype)initWithDelegate:(id<SSJBaseNetworkServiceDelegate>)delegate {
    if (self = [super initWithDelegate:delegate]) {
        self.numberPerPage = 10;
        self.currentPage = 1;
        self.itemList = [@[] mutableCopy];
    }
    return self;
}

- (void)request:(NSString *)urlString params:(id)params {
    NSMutableDictionary *paramDic = [params ?: @{} mutableCopy];
    [paramDic setObject:@(self.currentPage) forKey:@"pn"];
    [paramDic setObject:@(self.numberPerPage) forKey:@"ps"];
    [super request:urlString params:paramDic];
}

- (void)handleResult:(NSDictionary *)rootElement {
    if ([self.returnCode isEqualToString:@"1"]) {
        NSDictionary *results = rootElement[@"results"];
        if (results && [results isKindOfClass:[NSDictionary class]]) {
            
            //  解析分页数据
            NSDictionary *pageInfo = [results objectForKey:@"page"];
            if (pageInfo && [pageInfo isKindOfClass:[NSDictionary class]]) {
                self.totalPage = [pageInfo[@"tp"] integerValue];
                self.currentPage = [pageInfo[@"pn"] integerValue];
            }
            
            if ([self.itemList.lastObject isKindOfClass:[SSJLoadMoreItem class]]) {
                [self.itemList removeLastObject];
            }
            
            //  解析数据列表
            Class class = [self itemClass];
            if (class) {
                NSArray *itemList = [results objectForKey:@"data"];
                
                if ([self mappingTable]) {
                    [class mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
                        return [self mappingTable];
                    }];
                }
                
                [self.itemList addObjectsFromArray:[class mj_objectArrayWithKeyValuesArray:itemList]];
                
                //  如果还有数据没加载
                if (self.currentPage < self.totalPage) {
                    [self.itemList addObject:[SSJLoadMoreItem itemWithTitle:@"加载更多"]];
                    self.currentPage ++;
                }
            }
        }
    }
}

- (Class)itemClass {
    return Nil;
}

- (NSDictionary *)mappingTable {
    return nil;
}

- (NSArray *)getItems {
    return [NSArray arrayWithArray:self.itemList];
}

@end
