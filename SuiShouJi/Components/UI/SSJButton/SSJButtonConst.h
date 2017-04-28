//
//  SSJButtonConst.h
//  SuiShouJi
//
//  Created by old lang on 17/3/19.
//  Copyright © 2017年 MZL. All rights reserved.
//

#ifndef SSJButtonConst_h
#define SSJButtonConst_h

typedef NS_ENUM(NSInteger, SSJButtonLayoutStyle) {
    SSJButtonLayoutStyleImageAndTitleCenter = 0,
    SSJButtonLayoutStyleImageLeftTitleRight,
    SSJButtonLayoutStyleImageRightTitleLeft,
    SSJButtonLayoutStyleImageTopTitleBottom,
    SSJButtonLayoutStyleImageBottomTitleTop,
    SSJButtonLayoutStyleCustom
};

typedef NS_ENUM(NSInteger, SSJButtonState) {
    SSJButtonStateNormal = 0,
    SSJButtonStateHighlighted,
    SSJButtonStateDisabled,
    SSJButtonStateSelected,
};


#endif /* SSJButtonConst_h */
