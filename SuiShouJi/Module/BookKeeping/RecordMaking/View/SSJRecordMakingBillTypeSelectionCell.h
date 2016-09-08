//
//  SSJRecordMakingBillTypeSelectionCell.h
//  SSRecordMakingDemo
//
//  Created by old lang on 16/4/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSJRecordMakingBillTypeSelectionCellItem;

@interface SSJRecordMakingBillTypeSelectionCell : UICollectionViewCell

@property (nonatomic, strong) SSJRecordMakingBillTypeSelectionCellItem *item;

@property (nonatomic, copy) void (^deleteAction)(SSJRecordMakingBillTypeSelectionCell *);

@property (nonatomic, copy) BOOL (^shouldDeleteAction)(SSJRecordMakingBillTypeSelectionCell *);

@end
