//
//  SSJNewCreditCardViewController.h
//  SuiShouJi
//
//  Created by ricky on 16/8/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "SSJFinancingHomeitem.h"

@interface SSJNewCreditCardViewController : SSJBaseViewController

@property(nonatomic, strong) SSJFinancingHomeitem *financingItem;

typedef void (^addNewCardBlock)(SSJFinancingHomeitem *newCardItem);

@property(nonatomic,copy) addNewCardBlock addNewCardBlock;

@property(nonatomic, strong) NSString *selectParent;

@property(nonatomic) SSJCrediteCardType cardType;

@end
