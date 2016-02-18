//
//  SSJPercentCircleAdditionNodeItem.h
//  SuiShouJi
//
//  Created by old lang on 16/2/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SSJPercentCircleAdditionNodeOrientation) {
    SSJPercentCircleAdditionNodeOrientationTopRight,
    SSJPercentCircleAdditionNodeOrientationBottomRight,
    SSJPercentCircleAdditionNodeOrientationBottomLeft,
    SSJPercentCircleAdditionNodeOrientationTopLeft
};

@interface SSJPercentCircleAdditionNodeItem : NSObject

@property (nonatomic) CGPoint startPoint;

@property (nonatomic) CGPoint turnPoint;

@property (nonatomic) CGPoint endPoint;

@property (nonatomic, copy) NSString *imageName;

@property (nonatomic) CGFloat imageRadius;

@property (nonatomic, copy) NSString *borderColorValue;

@property (nonatomic) CGFloat gapBetweenImageAndText;

@property (nonatomic, copy) NSString *text;

@property (nonatomic) CGFloat textSize;

@property (nonatomic, copy) NSString *textColorValue;

@property (nonatomic) SSJPercentCircleAdditionNodeOrientation orientation;

@end

NS_ASSUME_NONNULL_END
