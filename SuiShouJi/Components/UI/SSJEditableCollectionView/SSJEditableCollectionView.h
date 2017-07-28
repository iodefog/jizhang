//
//  SSJEditCollectionView.h
//  SSRecordMakingDemo
//
//  Created by old lang on 16/5/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SSJEditableCollectionViewDataSource <UICollectionViewDataSource>

@end

@class SSJEditableCollectionView;

@protocol SSJEditableCollectionViewDelegate <UICollectionViewDelegate>

@optional
/**
 询问代理者是否开始移动指定位置的cell；在整个移动过程中只触发一次

 @param collectionView <#collectionView description#>
 @param indexPath <#indexPath description#>
 @return <#return value description#>
 */
- (BOOL)collectionView:(SSJEditableCollectionView *)collectionView shouldBeginMovingCellAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  询问代理者是否应该把cell移动到指定的位置；在整个移动过程中可触发多次，只要有其他的cell和当前移动的cell相交的话，就会触发此方法
 *
 *  @param collectionView
 *  @param fromIndexPath
 *  @param toIndexPath
 *
 *  @return (void)
 */
- (BOOL)collectionView:(SSJEditableCollectionView *)collectionView shouldMoveCellAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

/**
 *  已经把cell移动到指定的位置；在整个移动过程中可触发多次，只要方法collectionView:shouldMoveCellAtIndexPath:toIndexPath:返回YES就会触发此方法
 *
 *  @param collectionView
 *  @param fromIndexPath
 *  @param toIndexPath
 *
 *  @return (void)
 */
- (void)collectionView:(SSJEditableCollectionView *)collectionView didMoveCellAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

/**
 *  已经把cell移动到指定的位置；在整个移动过程中指挥触发一次，从长按事件开始到结束，如果开始位置和结束位置不同，就会触发此方法
 *
 *  @param collectionView
 *  @param fromIndexPath
 *  @param toIndexPath
 *
 *  @return (void)
 */
- (void)collectionView:(SSJEditableCollectionView *)collectionView didEndMovingCellFromIndexPath:(NSIndexPath *)fromIndexPath toTargetIndexPath:(NSIndexPath *)toIndexPath;

@end

@interface SSJEditableCollectionView : UICollectionView

/**
 *  数据源代理对象，只能设置此数据源代理属性，不能设置dataSource属性，否则可能会出现奇怪的问题;
 *  对象实现<SSJEditableCollectionViewDataSource>协议就不需要实现<UICollectionViewDataSource>
 */
@property (nonatomic, weak) id<SSJEditableCollectionViewDataSource> editDataSource;

/**
 *  代理对象，设置此代理属性，不需要设置原delegate属性了；
 *  对象实现<SSJEditableCollectionViewDelegate>协议就不需要实现<UICollectionViewDelegate>
 */
@property (nonatomic, weak) id<SSJEditableCollectionViewDelegate> editDelegate;

/**
 *  交换cell的碰撞区域
 */
@property (nonatomic) UIEdgeInsets exchangeCellRegion;

/**
 *  长按事件开始，移动的cell的放大比例，最小为0
 */
@property (nonatomic) CGFloat movedCellScale;

/**
 *  将当前移动的cell保持在屏幕可视范围内;editDelegate需要在scrollViewDidScroll方法中调用此方法
 */
- (void)keepCurrentMovedCellVisible;

/**
 *  检测是否有相交的cell，如果有就交换它们的位置；
 *  此方法会触发collectionView:shouldExchangeCellsWithIndexPath:anotherIndexPath和
 *  collectionView:didExchangeCellsWithIndexPath:anotherIndexPath
 */
- (void)checkIfHasIntersectantCells;

@end
