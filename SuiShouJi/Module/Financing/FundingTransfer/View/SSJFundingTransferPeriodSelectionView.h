//
//  SSJFundingTransferPeriodSelectionView.h
//  SuiShouJi
//
//  Created by old lang on 17/2/8.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJFundingTransferPeriodSelectionView : UIControl

@property (nonatomic) SSJCyclePeriodType selectedType;

- (void)show;

- (void)dismiss;

- (void)updateAppearanceAccordingToTheme;

@end
