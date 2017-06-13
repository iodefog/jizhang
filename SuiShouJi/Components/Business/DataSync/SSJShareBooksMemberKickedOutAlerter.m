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

@property (nonatomic, copy) NSString *booksName;

@property (nonatomic, strong) NSDate *date;

@end

@implementation SSJShareBooksMemberKickedOutAlerterModel

+ (instancetype)modelWithBooksName:(NSString *)booksName date:(NSDate *)date {
    SSJShareBooksMemberKickedOutAlerterModel *model = [[SSJShareBooksMemberKickedOutAlerterModel alloc] init];
    model.booksName = booksName;
    model.date = date;
    return model;
}

//- (BOOL)isEqual:(id)object {
//    if (![object isKindOfClass:[self class]]) {
//        return NO;
//    }
//    
//    SSJShareBooksMemberKickedOutAlerterModel *anotherModel = object;
//    return [anotherModel.memberId isEqualToString:self.memberId] && [anotherModel.booksId isEqualToString:self.booksId];
//}

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

- (void)recordWithMemberId:(NSString *)memberId booksId:(NSString *)booksId date:(NSDate *)date inDatabase:(SSJDatabase *)db error:(NSError **)error {
    FMResultSet *rs = [db executeQuery:@"select sb.cbooksname from bk_share_books as sb, bk_share_books_friends_mark as sm where sb.cbooksid = sm.cbooksid and sb.cadmin = sm.cfriendid and sm.cuserid = ? and sm.cbooksid = ?", memberId, booksId];
    if (!rs) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    NSString *booksName = nil;
    while ([rs next]) {
        booksName = [rs stringForColumn:@"cbooksname"];
    }
    [rs close];
    
    NSMutableArray *records = self.membersInfo[memberId];
    if (!records) {
        records = [NSMutableArray array];
        self.membersInfo[memberId] = records;
    }
    
    SSJShareBooksMemberKickedOutAlerterModel *model = [SSJShareBooksMemberKickedOutAlerterModel modelWithBooksName:booksName date:date];
//    [records removeObject:model];
    [records addObject:model];
}

- (void)showAlertIfNeededWithMemberId:(NSString *)memberId {
    NSMutableArray *records = self.membersInfo[memberId];
    [records sortUsingComparator:^NSComparisonResult(SSJShareBooksMemberKickedOutAlerterModel *obj1, SSJShareBooksMemberKickedOutAlerterModel *obj2) {
        return [obj1.date compare:obj2.date];
    }];
    
    [self showAlertWithModels:records];
}

- (void)showAlertWithModels:(NSMutableArray<SSJShareBooksMemberKickedOutAlerterModel *> *)models {
    if (models.count <= 0) {
        return;
    }
    
    SSJShareBooksMemberKickedOutAlerterModel *model = [models firstObject];
    [models ssj_removeFirstObject];
    SSJDispatchMainAsync(^{
        [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:[NSString stringWithFormat:@"您已被管理员移出共享账本［%@］", model.booksName] action:[SSJAlertViewAction actionWithTitle:@"知道了" handler:^(SSJAlertViewAction *action){
            [self showAlertWithModels:models];
        }], nil];
    });
}

@end
