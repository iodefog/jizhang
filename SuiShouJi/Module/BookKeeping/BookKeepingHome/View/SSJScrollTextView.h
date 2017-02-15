//
//  SSJScrollTextView.h
//  SuiShouJi
//
//  Created by ricky on 16/4/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJScrollTextView : UIView
//显示的文字
@property(nonatomic, strong) NSString *string;

//字体大小(默认15)
@property(nonatomic) int textFont;

//字体颜色(默认黑色)
@property(nonatomic, strong) UIColor *textColor;

//文字滚动时间(默认为1)
@property(nonatomic) float totalAnimationDuration;

//是否需要滚动(默认为NO)
@property(nonatomic) BOOL scrollAble;

- (void)ajustFontWithSize:(CGSize)size;
@end
