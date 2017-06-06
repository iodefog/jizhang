//
//  SSJGuideContentView.h
//  MoneyMore
//
//  Created by old lang on 15-5-7.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSJGuideContentView;

typedef void(^SSJGuideBeginButtonClick)(SSJGuideContentView *contentView);

typedef NS_ENUM(NSInteger, SSJGuideContentViewType) {
    SSJGuideContentViewTypeNormal = 0,
    SSJGuideContentViewTypeLottie = 1
};


@interface SSJGuideContentView : UIView

- (instancetype)initWithFrame:(CGRect)frame withType:(SSJGuideContentViewType)type imageName:(NSString *)imageName;

- (void)play;

@end
