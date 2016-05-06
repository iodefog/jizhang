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

/**
 *  询问代理者是否应该进入编辑状态，只能由用户长按触发
 *
 *  @param collectionView
 *  @param indexPath 长按的cell的indexpath
 *
 *  @return (BOOL) 是否应该进入编辑状态
 */
- (BOOL)collectionView:(SSJEditableCollectionView *)collectionView shouldBeginEditingWhenPressAtIndexPath:(NSIndexPath *)indexPath;

//- (void)collectionView:(SSJEditableCollectionView *)collectionView willBeginEditingWhenPressAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  已经进入编辑状态，可由用户长按触发或调用beginEditing触发
 *
 *  @param collectionView 要保存的图片
 *  @param indexPath 如果由用户长按触发则传入用户长按的cell的indexpath，如果是调用beginEditing触发，则传nil
 *
 *  @return (void)
 */
- (void)collectionView:(SSJEditableCollectionView *)collectionView didBeginEditingWhenPressAtIndexPath:(NSIndexPath *)indexPath;

//- (void)collectionView:(SSJEditableCollectionView *)collectionView willMoveCellAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  询问代理者是否应该交换两个cell
 *
 *  @param collectionView
 *  @param indexPath
 *  @param anotherIndexPath
 *
 *  @return (void)
 */
- (BOOL)collectionView:(SSJEditableCollectionView *)collectionView shouldExchangeCellsWithIndexPath:(NSIndexPath *)indexPath anotherIndexPath:(NSIndexPath *)anotherIndexPath;

/**
 *  已经交换了两个cell
 *
 *  @param collectionView
 *  @param indexPath
 *  @param anotherIndexPath
 *
 *  @return (void)
 */
- (void)collectionView:(SSJEditableCollectionView *)collectionView didExchangeCellsWithIndexPath:(NSIndexPath *)indexPath anotherIndexPath:(NSIndexPath *)anotherIndexPath;

/**
 *  询问代理者是否应该结束编辑状态；在编辑状态下用户手动点击collectionView触发，调用endEditing不会触发此方法
 *
 *  @param collectionView
 *
 *  @return (BOOL) 是否应该结束编辑状态
 */
- (BOOL)shouldCollectionViewEndEditingWhenUserTapped:(SSJEditableCollectionView *)collectionView;

/**
 *  已经结束编辑状态，此方法可能由用户手动点击collectionView触发，或者调用endEditing触发
 *
 *  @param collectionView
 *
 *  @return (void)
 */
- (void)collectionViewDidEndEditing:(SSJEditableCollectionView *)collectionView;

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
@property (nonatomic) CGRect exchangeCellRegion;

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

/**
 *  开始编辑
 */
- (void)beginEditing;

/**
 *  结束编辑
 */
- (void)endEditing;

@end
