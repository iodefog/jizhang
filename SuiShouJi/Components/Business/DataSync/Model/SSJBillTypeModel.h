//
//  SSJBillTypeModel.h
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

//  收支类型模型

#import "SSJDataSyncModel.h"

@interface SSJBillTypeModel : SSJDataSyncModel

//  收支类型id
@property (nonatomic, copy) NSString *CBILLID;

//  0不启用 1启用
@property (nonatomic) int ISTATE;

@end
