//
//  SSJPageNetworkService.m
//  YYDB
//
//  Created by cdd on 15/11/5.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJPageNetworkService.h"
#import "SSJLoadMoreItem.h"
#import "SSJPageModel.h"

@interface SSJPageNetworkService ()

/**
 *  第几页
 */
@property (assign, nonatomic) NSInteger pn;

/**
 *  每页数据条数
 */
@property (assign, nonatomic) NSInteger ps;

/**
 *  数据总页数
 */
@property (assign, nonatomic) NSInteger pageCount;

/**
 *  数据总条数
 */
@property (copy, nonatomic) NSString* allDataCount;

@property (nonatomic, strong) NSMutableArray *tempData;

@end

@implementation SSJPageNetworkService

- (instancetype)initWithDelegate:(id<SSJBaseNetworkServiceDelegate>)delegate {
    if (self = [super initWithDelegate:delegate]) {
        _pn=1;
        _ps=10;
        _tempData=[[NSMutableArray alloc]init];
    }
    return self;
}

- (BOOL)isEnd{
    return _pn == self.pageCount;
}

- (void)loadService:(NSString *)api Params:(NSDictionary *)dict FromTop:(BOOL)fromTop ShowIndicator:(BOOL)show{
    if (fromTop) {
        _pn = 1;
    }else{
        if ([self isEnd]) {
            return;
        }
        _pn =_pn +1;
    }
    _loadFromTop=fromTop;
    if (!dict) {
        dict=@{};
    }
    NSMutableDictionary *pdict=[dict mutableCopy];
    NSString *pn=[NSString stringWithFormat:@"%ld",(long)_pn];
    NSString *ps=[NSString stringWithFormat:@"%ld",(long)_ps];
    [pdict setObject:pn forKey:@"pn"];
    [pdict setObject:ps forKey:@"ps"];
    self.showLodingIndicator=show;
    [self request:SSJURLWithAPI(api) params:pdict];
}

- (void)requestDidFinish:(NSDictionary *)rootElement {
    if ([self.returnCode isEqualToString:@"1"]) {
        NSDictionary *results = rootElement[@"results"];
        if (results && [results isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *pageDict=[results objectForKey:@"page"];
            _page =[SSJPageModel objectWithKeyValues:pageDict];
            _pn=[_page.pn intValue];
            self.pageCount = [_page.tp intValue];
            _allDataCount = _page.tr;
            if (!self.loadFromTop) {
                if ([self.tempData.lastObject isKindOfClass:[SSJLoadMoreItem class]]) {
                    [self.tempData removeLastObject];
                }
            }else{
                [self.tempData removeAllObjects];
            }
            NSArray *arr=[results objectForKey:@"data"];
            Class class = [self itemClass];
            if ([self mappingTable]) {
                [class setupReplacedKeyFromPropertyName:^NSDictionary *{
                    return [self mappingTable];
                }];
            }
            [_tempData addObjectsFromArray:[class objectArrayWithKeyValuesArray:arr]];
            if (_pn < self.pageCount){
                [_tempData addObject:[SSJLoadMoreItem itemWithTitle:@"加载更多"]];
            }
            if (_datas) {
                _datas=nil;
            }
            _datas=[NSArray arrayWithArray:_tempData];
        }
    }
}

- (Class)itemClass {
    return Nil;
}

- (NSDictionary *)mappingTable {
    return nil;
}

@end
