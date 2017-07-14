//
//  CDAutoHideMessageHUD.m
//  CDAppDemo
//
//  Created by Cheng on 15/9/5.
//  Copyright (c) 2015年 Cheng. All rights reserved.
//

#import "CDAutoHideMessageHUD.h"
#import <objc/runtime.h>

#define ANIMATION_DURATION_SEC 0.5
#define AUTOHIDEVIEW_MIN_WIDTH 60.0
#define AUTOHIDEVIEW_MIN_HEIGHT 30.0
#define AUTOHIDEVIEW_MAX_WIDTH 260.0
#define AUTOHIDEVIEW_MAX_HEIGHT 120.0

@interface CDNewLabel : UILabel

@end

@implementation CDNewLabel

- (void)drawTextInRect:(CGRect)rect{
    [super drawTextInRect:CGRectMake(10, 10, self.width-20, self.height-20)];
}

@end

static void * CDAutoHideMessageHUDKey = (void *)@"CDAutoHideMessageHUDKey";

@implementation CDAutoHideMessageHUD

+ (void)showMessage:(NSString *)msg{
    [CDAutoHideMessageHUD showMessage:msg inView:[UIApplication sharedApplication].keyWindow];
}

+ (void)showMessage:(NSString *)msg inView:(UIView *)view{
    [CDAutoHideMessageHUD showMessage:msg inView:view duration:1.0f];
}

+ (void)showMessage:(NSString *)msg inView:(UIView *)view duration:(NSTimeInterval)duration{
    if(view && msg && duration > 0){
        CDNewLabel *label=(CDNewLabel *)objc_getAssociatedObject(view, CDAutoHideMessageHUDKey);
        if (label==nil) {
            label = [[CDNewLabel alloc]init];
            label.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.75f];
            label.textColor=[UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.layer.cornerRadius=5;
            label.clipsToBounds=YES;
            label.font=[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
            label.numberOfLines=0;
            label.lineBreakMode=NSLineBreakByWordWrapping;
            label.alpha=0;
            [view addSubview:label];
            objc_setAssociatedObject(view, CDAutoHideMessageHUDKey, label, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        [view bringSubviewToFront:label];
        
        CGSize vwSize = view.bounds.size;
        NSDictionary *dict = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14]};
        CGRect rect = [msg boundingRectWithSize:CGSizeMake(AUTOHIDEVIEW_MAX_WIDTH, AUTOHIDEVIEW_MAX_HEIGHT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
        CGSize lbSize=CGSizeMake(ceilf(CGRectGetWidth(rect)),ceilf(CGRectGetHeight(rect)));
        lbSize.width += 20;
//        lbSize.width = MIN(AUTOHIDEVIEW_MAX_WIDTH, MAX(AUTOHIDEVIEW_MIN_WIDTH, lbSize.width+ 20.0f));
        lbSize.height = MIN(AUTOHIDEVIEW_MAX_HEIGHT, MAX(AUTOHIDEVIEW_MIN_HEIGHT, lbSize.height + 20.0f));
        label.bounds = CGRectMake(0, 0, lbSize.width, lbSize.height);
        label.center = CGPointMake(vwSize.width * 0.5f, vwSize.height * 0.5f);
        label.text = msg;
        
        __weak __typeof(UILabel *) weakLabel=label;
        [UIView animateWithDuration:ANIMATION_DURATION_SEC animations:^{
            weakLabel.alpha=1;
        } completion:^(BOOL finished){
            double delayInSeconds = duration;
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds*NSEC_PER_SEC));
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:ANIMATION_DURATION_SEC animations:^{
                    weakLabel.alpha=0;
                } completion:^(BOOL finished) {
                    [weakLabel removeFromSuperview];
                    objc_setAssociatedObject(view, CDAutoHideMessageHUDKey, nil, OBJC_ASSOCIATION_RETAIN);
                }];
            });
        }];
    }
}


@end

@implementation CDAutoHideMessageHUD (Error)

+ (void)showError:(NSError *)error {
    if ([error.domain isEqualToString:RACCommandErrorDomain]) {
        return;
    }
    
    [self showMessage:error.localizedDescription.length ? error.localizedDescription : SSJ_ERROR_MESSAGE];
}

@end
