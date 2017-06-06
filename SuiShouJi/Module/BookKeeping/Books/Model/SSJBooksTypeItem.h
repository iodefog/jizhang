//
//  SSJBooksTypeItem.h
//  SuiShouJi
//
//  Created by ricky on 16/5/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"
#import "SSJFinancingGradientColorItem.h"
#import "SSJBooksItem.h"

@interface SSJBooksTypeItem : SSJBaseCellItem<SSJBooksItemProtocol>

@property(nonatomic, strong) NSString *userId;

@property(nonatomic) BOOL editeModel;

/**<#注释#>*/
@property (nonatomic, copy) NSString *operatorType;

+ (NSDictionary *)propertyMapping;

@end
