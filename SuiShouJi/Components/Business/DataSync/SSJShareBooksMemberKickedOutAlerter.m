//
//  SSJShareBooksMemberAlerter.m
//  SuiShouJi
//
//  Created by old lang on 17/6/8.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksMemberKickedOutAlerter.h"
#import "SSJDatabaseQueue.h"

@interface SSJShareBooksMemberKickedOutAlerterModel : NSObject

@property (nonatomic, copy) NSString *memberId;

@property (nonatomic, copy) NSString *booksId;

@property (nonatomic, strong) NSDate *date;

@end

@implementation SSJShareBooksMemberKickedOutAlerterModel

+ (instancetype)modelWithMemberId:(NSString *)memberId booksId:(NSString *)booksId date:(NSDate *)date {
    SSJShareBooksMemberKickedOutAlerterModel *model = [[SSJShareBooksMemberKickedOutAlerterModel alloc] init];
    model.memberId = memberId;
    model.booksId = booksId;
    model.date = date;
    return model;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    SSJShareBooksMemberKickedOutAlerterModel *anotherModel = object;
    return [anotherModel.memberId isEqualToString:self.memberId] && [anotherModel.booksId isEqualToString:self.booksId];
}

@end

@interface SSJShareBooksMemberKickedOutAlerter ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<SSJShareBooksMemberKickedOutAlerterModel *> *> *membersInfo;

@end

@implementation SSJShareBooksMemberKickedOutAlerter

+ (instancetype)alerter {
    static SSJShareBooksMemberKickedOutAlerter *alerter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alerter = [[SSJShareBooksMemberKickedOutAlerter alloc] init];
    });
    return alerter;
}

- (instancetype)init {
    if (self = [super init]) {
        self.membersInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)recordWithMemberId:(NSString *)memberId booksId:(NSString *)booksId date:(NSDate *)date {
    NSMutableArray *records = self.membersInfo[memberId];
    if (!records) {
        records = [NSMutableArray array];
    }
    
    SSJShareBooksMemberKickedOutAlerterModel *model = [SSJShareBooksMemberKickedOutAlerterModel modelWithMemberId:memberId booksId:booksId date:date];
    [records removeObject:model];
    [records addObject:model];
}

- (void)showAlertIfNeededWithMemberId:(NSString *)memberId {
    NSArray *records = self.membersInfo[memberId];
    NSArray *sortedRecords = [records sortedArrayUsingComparator:^NSComparisonResult(SSJShareBooksMemberKickedOutAlerterModel *obj1, SSJShareBooksMemberKickedOutAlerterModel *obj2) {
        return [obj1.date compare:obj2.date];
    }];
    
    [self showAlertWithModels:sortedRecords index:0];
}

- (void)showAlertWithModels:(NSArray<SSJShareBooksMemberKickedOutAlerterModel *> *)models index:(int)index {
    if (models.count <= index) {
        return;
    }
    
    SSJShareBooksMemberKickedOutAlerterModel *model = models[index];
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select sb.cbooksname, sm.cmark from bk_share_books as sb, bk_share_books_friends_mark as sm where sb.cbooksid = sm.cbooksid and sb.cadmin = sm.cfriendid and sm.cuserid = ? and sm.cbooksid = ?", model.memberId, model.booksId];
        if (!rs) {
            [SSJAlertViewAdapter showError:[db lastError]];
            return;
        }
        
        NSString *booksName = nil;
        NSString *adminName = nil;
        while ([rs next]) {
            booksName = [rs stringForColumn:@"cbooksname"];
            adminName = [rs stringForColumn:@"cmark"];
        }
        [rs close];
        
        SSJDispatchMainAsync(^{
            [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:[NSString stringWithFormat:@"您已被%@移出共享账本［%@］", adminName, booksName] action:[SSJAlertViewAction actionWithTitle:@"知道了" handler:^(SSJAlertViewAction *action){
                [self showAlertWithModels:models index:(index + 1)];
            }], nil];
        });
    }];
}

@end
