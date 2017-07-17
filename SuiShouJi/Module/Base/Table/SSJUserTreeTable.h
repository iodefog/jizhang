//
//  SSJUserTreeTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJUserTreeTable : NSObject <WCTTableCoding>

@property (nonatomic, retain) NSString* userId;

@property (nonatomic, assign) int signIn;

@property (nonatomic, retain) NSString* signInDate;

@property (nonatomic, assign) int hasShaked;

@property (nonatomic, retain) NSString* treeImgUrl;

@property (nonatomic, retain) NSString* treeGifUrl;


WCDB_PROPERTY(userId)
WCDB_PROPERTY(signIn)
WCDB_PROPERTY(signInDate)
WCDB_PROPERTY(hasShaked)
WCDB_PROPERTY(treeImgUrl)
WCDB_PROPERTY(treeGifUrl)

@end
