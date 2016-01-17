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

@interface SSJGuideContentView : UIView

// 图片名称
@property (nonatomic, copy) NSString *imageName;

@end
