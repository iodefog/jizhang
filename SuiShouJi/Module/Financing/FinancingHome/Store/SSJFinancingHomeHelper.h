//
//  SSJFinancingHomeHelper.h
//  SuiShouJi
//
//  Created by ricky on 16/3/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJFinancingHomeitem.h"

@interface SSJFinancingHomeHelper : NSObject
/**
 *  查询所有的资金列表
 *
 *  @param success 查询成功的回调
 *  @param failure 查询失败的回调
 */
+ (void)queryForFundingListWithSuccess:(void(^)(NSArray<SSJFinancingHomeitem *> *result))success failure:(void (^)(NSError *error))failure;

+ (void)SaveFundingOderWithItems:(NSArray <SSJFinancingHomeitem *> *)items error:(NSError **)error;


/**
 删除某个账户

 @param item    要删除的item
 @param type    删除的类型(0为不删除流水,1为删除流水)
 @param success 删除成功的回调
 @param failure 删除失败的回调
 */
+ (void)deleteFundingWithFundingItem:(SSJBaseCellItem *)item
                          deleteType:(BOOL)type
                             Success:(void(^)())success
                             failure:(void (^)(NSError *error))failure;


+ (NSString *)fundParentNameForFundingParent:(NSString *)parent;

@end
