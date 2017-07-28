//
//  SSJRecordMakingBillTypeSelectionView.h
//  SSRecordMakingDemo
//
//  Created by old lang on 16/4/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSJRecordMakingBillTypeSelectionCellItem;

@interface SSJRecordMakingBillTypeSelectionView : UIView

@property (nonatomic, strong) NSArray<SSJRecordMakingBillTypeSelectionCellItem *> *items;

@property (nonatomic, copy) BOOL (^shouldDeleteAction)(SSJRecordMakingBillTypeSelectionView *, SSJRecordMakingBillTypeSelectionCellItem *);

@property (nonatomic, copy) void (^editAction)(SSJRecordMakingBillTypeSelectionView *, SSJRecordMakingBillTypeSelectionCellItem *);

@property (nonatomic, copy) void (^deleteAction)(SSJRecordMakingBillTypeSelectionView *, SSJRecordMakingBillTypeSelectionCellItem *);

@property (nonatomic, copy) void (^selectAction)(SSJRecordMakingBillTypeSelectionView *, SSJRecordMakingBillTypeSelectionCellItem *);

@property (nonatomic, copy) void (^addAction)(SSJRecordMakingBillTypeSelectionView *);

@property (nonatomic, copy) void (^dragAction)(SSJRecordMakingBillTypeSelectionView *, BOOL isDragUp);

@property (nonatomic, copy) void (^beginEditingAction)(SSJRecordMakingBillTypeSelectionView *);

@property (nonatomic, copy) void (^endEditingAction)(SSJRecordMakingBillTypeSelectionView *);

@property (nonatomic) UIEdgeInsets contentInsets;

@property (nonatomic) BOOL editing;

- (BOOL)deleteItem:(SSJRecordMakingBillTypeSelectionCellItem *)item;

- (void)scrollToSelectedItem;

- (SSJRecordMakingBillTypeSelectionCellItem *)selectedItem;

@end
