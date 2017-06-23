//
//  SSJNewCreditCardViewController.h
//  SuiShouJi
//
//  Created by ricky on 16/8/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "SSJCreditCardItem.h"

@interface SSJNewCreditCardViewController : SSJBaseViewController

@property(nonatomic, strong) NSString *cardId;

typedef void (^addNewCardBlock)(SSJCreditCardItem *newCardItem);

@property(nonatomic,copy) addNewCardBlock addNewCardBlock;

@property(nonatomic) SSJCrediteCardType cardType;

@end
