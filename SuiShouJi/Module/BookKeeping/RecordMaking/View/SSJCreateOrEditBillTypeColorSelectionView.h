//
//  SSJCreateOrEditBillTypeColorSelectionView.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSJCreateOrEditBillTypeColorSelectionView : UIView

@property (nonatomic, copy) NSArray<UIColor *> *colors;

/**
 如果>=0选中指定下标的cell，如果<0取消所有选中的cell
 */
@property (nonatomic) NSInteger selectedIndex;

@property (nonatomic, copy) void(^selectColorAction)(SSJCreateOrEditBillTypeColorSelectionView *view);

@property (nonatomic, readonly) BOOL showed;

- (void)show;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
