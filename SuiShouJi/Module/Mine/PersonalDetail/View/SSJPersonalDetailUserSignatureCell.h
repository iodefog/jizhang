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

+ (instancetype)itemWithSignatureLimit:(NSUInteger)signatureLimit signature:(NSString *)signature;

@end
