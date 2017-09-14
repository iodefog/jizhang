//
//  SSJRecycleDataDeletionAlertView.h
//  SuiShouJi
//
//  Created by old lang on 2017/9/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SSJRecycleDataDeletionType) {
    SSJRecycleDataDeletionTypeBook,
    SSJRecycleDataDeletionTypeFund
};

@interface SSJRecycleDataDeletionAlertor : NSObject

+ (void)showAlert:(SSJRecycleDataDeletionType)type;

@end


@interface SSJRecycleDataDeletionAlertView : UIView

@property (nonatomic, copy) NSString *message;

+ (instancetype)alertView;

- (void)show;

- (void)dismiss;

@end
