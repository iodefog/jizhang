//
//  SSJRecordMakingBillTypeSelectionView.h
//  SSRecordMakingDemo
//
//  Created by old lang on 16/4/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJRecordMakingBillTypeSelectionCellItem.h"

@interface SSJRecordMakingBillTypeSelectionView : UIView

@property (nonatomic, strong) NSArray <SSJRecordMakingBillTypeSelectionCellItem *> *items;

- (void)endEditing;

@end
