//
//  SSJLoanDateSelectionView.h
//  SuiShouJi
//
//  Created by old lang on 16/8/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SSJLoanDateSelectionButtonItem;

@interface SSJLoanDateSelectionView : UIView

@property (nonatomic, copy, nullable) NSString *title;

@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, copy) BOOL (^shouldSelectDateAction)(SSJLoanDateSelectionView *view, NSDate *date);

@property (nonatomic, copy) void (^selectDateAction)(SSJLoanDateSelectionView *view);

// 自定义左侧按钮，如果有值，就取代默认的取消按钮
@property (nonatomic, strong, nullable) SSJLoanDateSelectionButtonItem *leftButtonItem;

// 自定义右侧按钮，如果有值，就取代默认的确认按钮
@property (nonatomic, strong, nullable) SSJLoanDateSelectionButtonItem *rightButtonItem;

- (void)show;

- (void)dismiss;

@end

typedef void(^SSJLoanDateSelectionButtonItemAction)();

@interface SSJLoanDateSelectionButtonItem : NSObject

@property (nonatomic, copy, nullable) NSString *title;

@property (nonatomic, strong, nullable) UIImage *image;

@property (nonatomic, strong, nullable) UIColor *color;

@property (nonatomic, copy) SSJLoanDateSelectionButtonItemAction action;

+ (instancetype)buttonItemWithTitle:(nullable NSString *)title
                              image:(nullable UIImage *)image
                              color:(nullable UIColor *)color
                             action:(SSJLoanDateSelectionButtonItemAction)action;

@end


NS_ASSUME_NONNULL_END
