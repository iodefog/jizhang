//
//  SSJPersonalDetailUserSignatureCell.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/4.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJPersonalDetailUserSignatureCell : SSJBaseTableViewCell
@end

@interface SSJPersonalDetailUserSignatureCellItem : SSJBaseCellItem

@property (nonatomic) NSUInteger signatureLimit;

@property (nonatomic, copy) NSString *signature;

@property (nonatomic, copy) NSString *titleStr;

@property (nonatomic, copy) NSString *placeholder;

+ (instancetype)itemWithSignatureLimit:(NSUInteger)signatureLimit signature:(NSString *)signature title:(NSString *)title placeholder:(NSString *)placeholder;



@end
