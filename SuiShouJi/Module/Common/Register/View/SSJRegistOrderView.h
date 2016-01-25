//
//  SSJRegistOrderView.h
//  SuiShouJi
//
//  Created by old lang on 16/1/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SSJRegistOrderType) {
    SSJRegistOrderTypeInputPhoneNo,
    SSJRegistOrderTypeInputAuthCode,
    SSJRegistOrderTypeSetPassword
};

@interface SSJRegistOrderView : UIView

- (instancetype)initWithFrame:(CGRect)frame withOrderType:(SSJRegistOrderType)order;

@end
