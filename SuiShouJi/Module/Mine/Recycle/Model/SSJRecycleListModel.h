//
//  SSJRecycleListModel.h
//  SuiShouJi
//
//  Created by old lang on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJRecycleListCellItem;

@interface SSJRecycleListModel : NSObject

@property (nonatomic, copy) NSString *dateStr;

@property (nonatomic, strong) NSMutableArray<SSJBaseCellItem *> *cellItems;

@end
