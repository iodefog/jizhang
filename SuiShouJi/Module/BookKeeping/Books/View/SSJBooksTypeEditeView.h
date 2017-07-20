//
//  SSJBooksTypeEditeView.h
//  SuiShouJi
//
//  Created by ricky on 16/5/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJBooksTypeItem.h"

SSJ_DEPRECATED
@interface SSJBooksTypeEditeView : UIView<UITextFieldDelegate>
@property(nonatomic, strong) SSJBooksTypeItem *item;

- (void)show;

- (void)dismiss;

typedef void (^comfirmButtonClickedBlock)(SSJBooksTypeItem *item);

@property(nonatomic,copy) comfirmButtonClickedBlock comfirmButtonClickedBlock;

typedef void (^deleteButtonClickedBlock)(SSJBooksTypeItem *item);

@property(nonatomic,copy) deleteButtonClickedBlock deleteButtonClickedBlock;

typedef void (^editeViewDismissBlock)();

@property(nonatomic,copy) editeViewDismissBlock editeViewDismissBlock;
@end
