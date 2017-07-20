//
//  SSJBooksColorAndIconSelectView.h
//  SuiShouJi
//
//  Created by ricky on 16/11/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJCategoryEditableCollectionView.h"

SSJ_DEPRECATED
@interface SSJBooksColorAndIconSelectView : UIView

@property (nonatomic, strong, readonly) UITextField *textField;

@property (nonatomic, strong) NSArray <NSString *>*images;

@property (nonatomic, strong) NSArray <NSString *>*colors;

@property (nonatomic, strong) NSString *selectedImage;

@property (nonatomic, strong) NSString *selectedColor;

@property (nonatomic) CGFloat displayColorRowCount;

@property (nonatomic, copy) void (^selectImageAction)(SSJBooksColorAndIconSelectView *view);

@property (nonatomic, copy) void (^selectColorAction)(SSJBooksColorAndIconSelectView *view);

@property (nonatomic, strong) SSJCategoryEditableCollectionView *imageSelectionView;

@property(nonatomic) NSInteger booksParent;

- (void)updateAppearance;


@end
