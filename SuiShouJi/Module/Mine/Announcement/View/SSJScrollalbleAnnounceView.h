//
//  SSJScrollalbleAnnounceView.h
//  SuiShouJi
//
//  Created by ricky on 2017/2/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJAnnoucementItem.h"

@interface SSJScrollalbleAnnounceView : UIView

@property(nonatomic, strong) NSArray <SSJAnnoucementItem *> *items;

@property (nonatomic, copy) void (^announceClickedBlock)(SSJAnnoucementItem *item);

@end
