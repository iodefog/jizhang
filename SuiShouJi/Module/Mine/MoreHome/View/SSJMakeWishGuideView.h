//
//  SSJMakeWishGuideView.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJMakeWishGuideView : UIView
/**img*/
@property (nonatomic, copy) NSString *image;

@property (nonatomic, copy) NSString *title;

- (void)updateAppearance;

- (void)show;
- (void)dismiss;
@end
