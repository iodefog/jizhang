//
//  SSJCodeEnterBooksService.h
//  SuiShouJi
//
//  Created by ricky on 2017/5/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseNetworkService.h"

@interface SSJCodeEnterBooksService : SSJBaseNetworkService

- (void)enterBooksWithCode:(NSString *)code;

@property(nonatomic, strong) NSMutableDictionary *shareBooksTableInfo;

@property(nonatomic, strong) NSArray *shareMemberTableInfo;

@property(nonatomic, strong) NSArray *userChargeTableInfo;

@property(nonatomic, strong) NSArray *shareFriendMarkTableInfo;


@end
