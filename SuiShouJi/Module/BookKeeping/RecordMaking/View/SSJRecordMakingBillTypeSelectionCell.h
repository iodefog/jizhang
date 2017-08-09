//
//  SSJRecordMakingBillTypeSelectionCell.h
//  SSRecordMakingDemo
//
//  Created by old lang on 16/4/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGSize SSJRMBTSCBoderSize;
extern const CGFloat SSJRMBTSCBoderCenterYScale;

@class SSJRecordMakingBillTypeSelectionCellItem;

@interface SSJRecordMakingBillTypeSelectionCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *pencil;

@property (nonatomic, strong) SSJRecordMakingBillTypeSelectionCellItem *item;

@end
