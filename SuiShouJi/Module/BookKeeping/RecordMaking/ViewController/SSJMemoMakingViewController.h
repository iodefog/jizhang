//
//  SSJMemoMakingViewController.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/2/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCollectionViewController.h"

@interface SSJMemoMakingViewController : SSJBaseCollectionViewController

//旧的备注(修改必传)
@property (nonatomic,strong) NSString *oldMemo;

/**
 *  添加备注的回调
 *
 *  @param newMemo 新的备注
 */
typedef void (^MemoMakingBlock)(NSString *newMemo);


@property (nonatomic, copy) MemoMakingBlock MemoMakingBlock;

@end
