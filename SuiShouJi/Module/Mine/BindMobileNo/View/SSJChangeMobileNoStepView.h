//
//  SSJChangeMobileNoStepView.h
//  SuiShouJi
//
//  Created by old lang on 2017/6/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJChangeMobileNoStepView : UIView

@property (nonatomic, readonly) NSInteger step;

@property (nonatomic) NSInteger currentStep;

- (instancetype)initWithStep:(NSInteger)step;

@end
