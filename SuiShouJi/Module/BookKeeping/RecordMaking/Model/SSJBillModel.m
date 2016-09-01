//
//  SSJBillModel.m
//  SuiShouJi
//
//  Created by old lang on 16/8/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBillModel.h"

@implementation SSJBillModel

- (instancetype)copyWithZone:(NSZone *)zone {
    SSJBillModel *model = [[SSJBillModel alloc] init];
    model.ID = _ID;
    model.userID = _userID;
    model.name = _name;
    model.icon = _icon;
    model.color = _color;
    model.state = _state;
    model.order = _order;
    model.type = _type;
    model.custom = _custom;
    model.operatorType = _operatorType;
    return model;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, @{@"ID":(_ID ?: [NSNull null]),
                                                        @"userID":(_userID ?: [NSNull null]),
                                                        @"name":(_name ?: [NSNull null]),
                                                        @"icon":(_icon ?: [NSNull null]),
                                                        @"color":(_color ?: [NSNull null]),
                                                        @"state":@(_state),
                                                        @"order":@(_order),
                                                        @"type":@(_type),
                                                        @"custom":@(_custom),
                                                        @"operatorType":@(_operatorType)}];
}

@end
