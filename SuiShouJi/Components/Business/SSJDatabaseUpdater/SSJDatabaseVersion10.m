//
//  SSJDatabaseVersion10.m
//  SuiShouJi
//
//  Created by ricky on 16/10/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion10.h"
#import "FMDB.h"

static NSString *const kBillIdKey = @"kBillIdKey";
static NSString *const kUserIdKey = @"kUserIdKey";
static NSString *const kParentTypeKey = @"kParentTypeKey";
static NSString *const kDefualtOrderKey = @"kDefualtOrderKey";

@implementation SSJDatabaseVersion10

+ (NSString *)dbVersion {
    return @"1.9.0";
}

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    NSError *error = [self updateBooksTypeTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateBillTypeTableWithDatabase:db];
    if (error) {
        return error;
    }

    error = [self updateUserBillTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updateLoanTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self updatePeriodChargeConfigTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)updateBooksTypeTableWithDatabase:(FMDatabase *)db {
    NSString *cwriteDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    // bk_books_type增加记账类型父类字段
    if (![db columnExists:@"iparenttype" inTableWithName:@"bk_books_type"]) {
        if (![db executeUpdate:@"alter table bk_books_type add iparenttype text"]) {
            return [db lastError];
        }
    }
    
    if (![db executeUpdate:@"update bk_books_type set iparenttype = case when length(cbooksid) != length(cuserid) and cbooksid like cuserid || '%' then substr(cbooksid, length(cuserid) + 2, length(cbooksid) - length(cuserid) - 1) else '0' end ,iversion = ? ,cwritedate = ?",@(SSJSyncVersion()),cwriteDate]) {
        return [db lastError];
    }
    
    return nil;
}

+ (NSError *)updateBillTypeTableWithDatabase:(FMDatabase *)db {
    
    // 首先给BILL_TYPE删除cbooksid字段
    // 创建临时表
    if (![db executeUpdate:@"create temporary table TMP_BILL_TYPE (ID TEXT, CNAME TEXT, ITYPE INTEGER,  CCOIN TEXT, CCOLOR TEXT, ISTATE INTEGER , ICUSTOM INTEGER, CPARENT TEXT, DEFAULTORDER INTEGER, PRIMARY KEY(ID))"]) {
        return [db lastError];
    }
    
    // 将原来表中的纪录插入到临时表中
    if (![db executeUpdate:@"insert into TMP_BILL_TYPE select ID, CNAME, ITYPE, CCOIN, CCOLOR, ISTATE , ICUSTOM , CPARENT , DEFAULTORDER from BK_BILL_TYPE"]) {
        return [db lastError];
    }
    
    // 删除原来的表
    if (![db executeUpdate:@"drop table BK_BILL_TYPE"]) {
        return [db lastError];
    }
    
    // 新建表
    if (![db executeUpdate:@"create table BK_BILL_TYPE (ID TEXT, CNAME TEXT, ITYPE INTEGER,  CCOIN TEXT, CCOLOR TEXT, ISTATE INTEGER , ICUSTOM INTEGER, CPARENT TEXT, DEFAULTORDER INTEGER ,PRIMARY KEY(ID))"]) {
        return [db lastError];
    }
    
    // 将临时表数据插入新表
    if (![db executeUpdate:@"insert into BK_BILL_TYPE select * from TMP_BILL_TYPE"]) {
        return [db lastError];
    }
    
    if (![db columnExists:@"ibookstype" inTableWithName:@"BK_BILL_TYPE"]) {
        if (![db executeUpdate:@"alter table BK_BILL_TYPE add ibookstype text"]) {
            return [db lastError];
        }
    }
    
    // 删除bill_type所有默认数据,并重新插入新的数据
    if (![db executeUpdate:@"delete from bk_bill_type where icustom <> 1 or icustom is null"]) {
        return [db lastError];
    }
    
    for (NSString *sqlStr in [self insertSqlArray]) {
        if (![db executeUpdate:sqlStr]) {
            return [db lastError];
        }
    }
    
    return nil;
}

+ (NSError *)updateUserBillTableWithDatabase:(FMDatabase *)db {
    NSString *cwriteDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    // 首先给user_bill添加新的cbooksid主键
    // 创建临时表
    if (![db executeUpdate:@"create temporary table TMP_USER_BILL (CUSERID TEXT, CBILLID TEXT, ISTATE INTEGER, CWRITEDATE TEXT, IVERSION INTEGER , OPERATORTYPE INTEGER , IORDER INTEGER, CBOOKSID TEXT , PRIMARY KEY(CBILLID, CUSERID, CBOOKSID))"]) {
        return [db lastError];
    }
    
    // 将原来表中的纪录插入到临时表中
    if (![db executeUpdate:@"insert into TMP_USER_BILL select CUSERID, CBILLID, ISTATE, CWRITEDATE, IVERSION , OPERATORTYPE , IORDER , '' from BK_USER_BILL"]) {
        return [db lastError];
    }
    
    // 删除原来的表
    if (![db executeUpdate:@"drop table BK_USER_BILL"]) {
        return [db lastError];
    }
    
    // 新建表
    if (![db executeUpdate:@"create table BK_USER_BILL (CUSERID TEXT, CBILLID TEXT, ISTATE INTEGER, CWRITEDATE TEXT, IVERSION INTEGER, OPERATORTYPE INTEGER, IORDER INTEGER, CBOOKSID TEXT, PRIMARY KEY(CBILLID, CUSERID, CBOOKSID))"]) {
        return [db lastError];
    }
    
    // 将临时表数据插入新表
    if (![db executeUpdate:@"insert into BK_USER_BILL select * from TMP_USER_BILL"]) {
        return [db lastError];
    }
    
    if (![db executeUpdate:@"update bk_user_bill set cbooksid = cuserid"]) {
        return [db lastError];
    }
    
    // 首先给每个默认账本加入默认的独有的记账类型
    if (![db executeUpdate:@"insert into bk_user_bill select a.cuserid ,b.id , 1, ?, ?, 0, b.defaultorder, a.cbooksid from bk_books_type a, bk_bill_type b where a.iparenttype = b.ibookstype and a.cbooksid <> a.cuserid and length(b.ibookstype) = 1 and a.cbooksid like a.cuserid || '%'",cwriteDate,@(SSJSyncVersion())]) {
        return [db lastError];
    }
    
    FMResultSet *result = [db executeQuery:@"select id ,defaultorder ,ibookstype from bk_bill_type where length(ibookstype) > 1"];
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    
    while ([result next]) {
        NSString *cbillid = [result stringForColumn:@"id"];
        NSString *defualtOrder = [result stringForColumn:@"defaultorder"];
        NSString *iparenttype = [result stringForColumn:@"ibookstype"];
        NSDictionary *dic = @{kBillIdKey:cbillid,
                              kDefualtOrderKey:defualtOrder,
                              kParentTypeKey:iparenttype};
        [tempArr addObject:dic];
    };
    
    for (NSDictionary *dict in tempArr) {
        NSString *cbillid = [dict objectForKey:kBillIdKey];
        NSString *defualtOrder = [dict objectForKey:kDefualtOrderKey];
        NSString *iparenttype = [dict objectForKey:kParentTypeKey];
        NSArray *parentArr = [iparenttype componentsSeparatedByString:@","];
            for (NSString *parenttype in parentArr) {
            if ([parenttype integerValue]) {
                if (![db executeUpdate:@"insert into bk_user_bill select cuserid ,? , 1, ?, ?, 1, ?, cbooksid from bk_books_type where iparenttype = ? and operatortype <> 2",cbillid,cwriteDate,@(SSJSyncVersion()),defualtOrder,parenttype]) {
                    return [db lastError];
                }
            }
        }
    }
    
    // 给每个自定义账本添加日常账本中所有类型
    if (![db executeUpdate:@"insert into bk_user_bill select b.cuserid ,b.cbillid , b.istate, ?, ?, 0, b.iorder, a.cbooksid from bk_books_type a, bk_user_bill b where b.operatortype <> 2 and a.cbooksid not like a.cuserid || '%' and b.cbooksid = a.cuserid and length(b.cbillid) < 10",cwriteDate,@(SSJSyncVersion())]) {
        return [db lastError];
    }
    
    // 给自定义账本添加已经使用过的自定义记账类型
    if (![db executeUpdate:@"insert into bk_user_bill select distinct a.cuserid , a.ibillid, 1, ?, ?, 0, 0, a.cbooksid from bk_user_charge a, bk_user_bill b where a.ibillid = b.cbillid and a.operatortype <> 2 and b.operatortype <> 2 and length(b.cbillid) > 10 and a.cbooksid not like a.cuserid || '%'",cwriteDate,@(SSJSyncVersion())]) {
        return [db lastError];
    }
    
    // 给非自定义账本账本添加之前版本已经用过的记账类型
    if (![db executeUpdate:@"insert into bk_user_bill select distinct a.cuserid , a.ibillid, 1, ?, ?, 0, 0, a.cbooksid from bk_user_charge a, bk_user_bill b where a.ibillid = b.cbillid and a.operatortype <> 2 and b.operatortype <> 2 and a.cbooksid <> a.cuserid and a.cbooksid like a.cuserid || '%' and not exists (select * from bk_user_bill where cbooksid = a.cbooksid and cbillid = a.ibillid)",cwriteDate,@(SSJSyncVersion())]) {
        return [db lastError];
    }
    
    return nil;
}

+ (NSError *)updateLoanTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table BK_LOAN add INTERESTTYPE INTEGER DEFAULT 0"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSError *)updatePeriodChargeConfigTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"alter table BK_CHARGE_PERIOD_CONFIG add CBILLDATEEND TEXT"]) {
        return [db lastError];
    }
    return nil;
}

+ (NSArray *)insertSqlArray {
    return  @[@"INSERT INTO `BK_BILL_TYPE` VALUES ('1000','餐饮',1,'bt_food','#ee9d29',1,0,NULL,2,'0,3,4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1001','烟酒茶',1,'bt_tobacco','#4f8ed5',1,0,NULL,12,'0,2')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1002','交通',1,'bt_traffic','#379647',1,0,NULL,3,'0,3,4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1003','购物',1,'bt_shopping','#d56335',1,0,NULL,4,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1004','娱乐',1,'bt_entertainment','#647ede',1,0,NULL,16,'0,4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1005','投资亏损',1,'bt_deficit','#408637',1,0,NULL,22,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1006','生活服务',1,'bt_service','#d13e3e',0,0,NULL,24,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1007','话费',1,'bt_recharge','#465a9b',1,0,NULL,20,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1008','医药',1,'bt_medicine','#f25c5c',0,0,NULL,42,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1009','住房',1,'bt_house','#b05c5c',1,0,NULL,18,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1010','水电煤',1,'bt_water','#a66e16',1,0,NULL,19,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1011','食材',1,'bt_shicai','#f86e3c',0,0,NULL,25,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1012','水果',1,'bt_fruit','#66b34a',1,0,NULL,8,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1013','零食',1,'bt_snack','#d969ba',1,0,NULL,9,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1014','汽车',1,'bt_car','#83aa3f',0,0,NULL,36,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1015','家居',1,'bt_furniture','#2793cb',0,0,NULL,33,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1016','服饰',1,'bt_clothes','#ff8b4c',1,0,NULL,11,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1017','美容美发',1,'bt_meirong','#fc7f58',0,0,NULL,43,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1018','旅行',1,'bt_tourism','#78a354',0,0,NULL,26,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1019','礼金',1,'bt_gift','#c62f2f',1,0,NULL,23,'0,2')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1020','家用',1,'bt_jiayong','#be7330',1,0,NULL,21,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1021','育婴',1,'bt_baby','#d44f4f',1,0,NULL,13,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1022','教育',1,'bt_education','#278f38',0,0,NULL,45,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1023','健身',1,'bt_sport','#07a1c2',0,0,NULL,39,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1024','结婚',1,'bt_marry','#e15534',0,0,NULL,46,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1025','维修',1,'bt_repair','#478e98',0,0,NULL,47,'0,1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1026','养宠',1,'bt_pet','#ab9444',0,0,NULL,38,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1027','清洁',1,'bt_clean','#359dc8',0,0,NULL,48,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1028','数码',1,'bt_digital','#2c53ab',0,0,NULL,34,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1029','邮费',1,'bt_youfei','#6b883c',0,0,NULL,32,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1030','利息',1,'bt_interest','#408637',0,0,NULL,53,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1031','还钱',1,'bt_huankuan','#7b529b',0,0,NULL,54,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1032','交税',1,'bt_jiaoshui','#e16b6b',0,0,NULL,31,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1033','其它',1,'bt_others','#626262',0,0,NULL,56,'0,1,2,3,4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2001','工资',0,'bt_wages','#e1861b',1,0,NULL,2,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2002','奖金',0,'bt_bouns','#66b34a',1,0,NULL,3,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2003','福利',0,'bt_fuli','#2bbeb2',1,0,NULL,4,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2004','投资收益',0,'bt_invest','#d44f4f',1,0,NULL,6,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2005','收红包',0,'bt_hongbao','#e15534',1,0,NULL,5,'0,4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2006','兼职',0,'bt_jianzhi','#78a543',1,0,NULL,7,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2007','生活费',0,'bt_shenghuofei','#be7330',1,0,NULL,8,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2008','报销',0,'bt_baoxiao','#6691e9',1,0,NULL,9,'0,1,4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2009','退款',0,'bt_tuikuan','#68b58a',1,0,NULL,10,'0,2,3,4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2010','公积金',0,'bt_gongjijin','#766bc8',1,0,NULL,14,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2011','社保金',0,'bt_shebao','#359dc8',1,0,NULL,13,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2012','礼金',0,'bt_gift','#c62f2f',1,0,NULL,11,'0,2,3')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2013','收款',0,'bt_shouzhai','#63671a',0,0,NULL,15,'0,3,4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2014','贷款',0,'bt_daikuan','#b47100',0,0,NULL,16,'0,1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2015','营业',0,'bt_yingye','#00a2f2',0,0,NULL,17,'0,1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2017','其它',0,'bt_others','#626262',0,0,NULL,25,'0,1,2,3,4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1','平账收入',0,'bt_pignzhangshouru','#9382ad',2,0,NULL,NULL,NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2','平账支出',1,'bt_pingzhangzhichu','#5889c5',2,0,NULL,'',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3','转入',0,'bt_zhuanru','#993f84',2,0,NULL,NULL,NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4','转出',1,'bt_zhuanchu','#4a8984',2,0,NULL,NULL,NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1034','发红包',1,'bt_hongbao','#d44f4f',1,0,NULL,5,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1035','日用品',1,'bt_riyong','#11a4d4',1,0,NULL,6,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1036','买菜',1,'bt_maicai','#27a26f',1,0,NULL,7,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1037','护肤美妆',1,'bt_meizhuang','#de4266',1,0,NULL,10,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1038','奶粉',1,'bt_naifen','#b4a81e',1,0,NULL,14,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1039','尿布',1,'bt_niaobu','#958a3c',1,0,NULL,15,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1040','电影',1,'bt_dianying','#5f6cb9',1,0,NULL,17,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1042','花钱',1,'bt_huaqian','#f26d49',1,0,NULL,1,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1043','酒店',1,'bt_jiudian','#766bc8',0,0,NULL,28,'0,2,4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1044','机票',1,'bt_jipiao','#3c81ce',0,0,NULL,29,'0,4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1045','生意',1,'bt_shengyi','#ad492b',0,0,NULL,30,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1046','电器',1,'bt_dianqi','#2bbeb2',0,0,NULL,35,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1047','小孩零用',1,'bt_lingyong','#9f5c1b',0,0,NULL,37,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1048','KTV',1,'bt_ktv','#9c4141',0,0,NULL,40,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1049','游园',1,'bt_youyuan','#6691e9',0,0,NULL,41,'0,4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1050','装修',1,'bt_zhaungxiu','#e1861b',0,0,NULL,44,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1051','平账差额',1,'bt_chae','#917636',0,0,NULL,50,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1052','手续费',1,'bt_shouxufei','#d4ba28',0,0,NULL,51,'0,1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1053','佣金',1,'bt_yongjin','#68b58a',0,0,NULL,52,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1056','借出款',1,'bt_jiechu','#b84848',0,0,NULL,55,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2018','赚钱',0,'bt_zhuanqian','#f25c5c',1,0,NULL,1,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2020','借入款',0,'bt_jiechu','#b84848',1,0,NULL,12,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2021','零花钱',0,'bt_lingyong','#9f5c1b',0,0,NULL,19,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2022','租金',0,'bt_zujin','#b05c5c',0,0,NULL,20,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2023','中奖',0,'bt_zhongjiang','#de4266',0,0,NULL,21,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2024','佣金提成',0,'bt_yongjin','#68b58a',0,0,NULL,22,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2025','利息',0,'bt_interest','#408637',0,0,NULL,23,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2026','分红',0,'bt_fenhong','#ad492b',0,0,NULL,24,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1041','出差',1,'bt_chuchai','#426ab2',0,0,NULL,27,'0,1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1057','保姆',1,'bt_baomu','#b3852b',0,0,NULL,49,'0')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2016','意外收入',0,'bt_yiwai','#004cb6',0,0,NULL,18,'0,2,3,4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3001','',1,'bt_chi','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3002','',1,'bt_car','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3003','',1,'bt_house','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3004','',1,'bt_child','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3005','',1,'bt_ren','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3006','',1,'bt_xie','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3007','',1,'bt_gouwu','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3008','',1,'bt_qiu','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3009','',1,'bt_chong','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3010','',1,'bt_qian','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3011','',1,'bt_feiji','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3012','',1,'bt_shu','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3013','',1,'bt_zhaungxiu','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3014','',1,'bt_money','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3015','',1,'bt_dian','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3016','',1,'bt_caizhi','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3017','',1,'bt_hezi','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3018','',1,'bt_baozhuang','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3019','',1,'bt_qianbao','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3020','',1,'bt_taobao','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3021','',1,'bt_youxi','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3022','',1,'bt_wenju','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3023','',1,'bt_wanju','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3024','',1,'bt_menpiao','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3025','',1,'bt_dangao','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3026','',1,'bt_food','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3027','',1,'bt_traffic','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3028','',1,'bt_shopping','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3029','',1,'bt_snack','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3030','',1,'bt_meizhuang','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3031','',1,'bt_riyong','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3032','',1,'bt_maicai','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3033','',1,'bt_fruit','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3034','',1,'bt_luobo','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3035','',1,'bt_shui','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3036','',1,'bt_clothes','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3037','',1,'bt_entertainment','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3038','',1,'bt_deficit','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3039','',1,'bt_recharge','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3040','',1,'bt_service','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3041','',1,'bt_shicai','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3042','',1,'bt_tourism','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3043','',1,'bt_chuchai','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3044','',1,'bt_jiudian','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3045','',1,'bt_meirong','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3046','',1,'bt_shengyi','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3047','',1,'bt_jiaoshui','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3048','',1,'bt_youfei','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3049','',1,'bt_furniture','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3050','',1,'bt_clean','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3051','',1,'bt_sport','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3052','',1,'bt_ktv','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3053','',1,'bt_youyuan','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3054','',1,'bt_medicine','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3055','',1,'bt_repair','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3056','',1,'bt_education','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3057','',1,'bt_marry','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3058','',1,'bt_baomu','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3059','',1,'bt_chae','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3060','',1,'bt_interest','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3061','',1,'bt_shouxufei','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3062','',1,'bt_yongjin','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3063','',1,'bt_huankuan','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3064','',1,'bt_jiechu','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4001','',0,'bt_yingye','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4002','',0,'bt_wages','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4003','',0,'bt_jianzhi','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4004','',0,'bt_gift','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4005','',0,'bt_fuli','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4006','',0,'bt_zujin','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4007','',0,'bt_daikuan','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4008','',0,'bt_chaopiao','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4009','',0,'bt_interest','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4010','',0,'bt_fenhong','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4011','',0,'bt_bouns','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4012','',0,'bt_invest','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4013','',0,'bt_shenghuofei','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4014','',0,'bt_baoxiao','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4015','',0,'bt_tuikuan','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4016','',0,'bt_gift','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4017','',0,'bt_jiechu','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4018','',0,'bt_shebao','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4019','',0,'bt_gongjijin','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4020','',0,'bt_lingyong','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4021','',0,'bt_daikuan','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4022','',0,'bt_shouzhai','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4023','',0,'bt_yiwai','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4024','',0,'bt_zhongjiang','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4025','',0,'bt_interest','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4026','',0,'bt_yongjin','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4027','',0,'bt_huaqian','',NULL,NULL,'root','',NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('5','借贷利息收入',0,'bt_interest','#408637',2,0,'',NULL,NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('6','借贷利息支出',1,'bt_interest','#408637',2,0,'',NULL,NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1058','进货',1,'bt_jinhuo','#ee9f2c',1,0,'',1,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1059','材料费',1,'bt_cailiao','#379647',1,0,'',2,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1060','运输费',1,'bt_yunshu','#d56335',1,0,'',3,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1061','营销推广',1,'bt_tuiguang','#d44f4f',1,0,'',4,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1062','办公费用',1,'bt_bangong','#2dafd9',1,0,'',5,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1063','租金',1,'bt_zuchangdi','#b05c5c',1,0,'',6,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1064','人工薪资',1,'bt_xinzi','#d969ba',1,0,'',7,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1065','买方退货',1,'bt_maifangtuihuo','#e0866b',1,0,'',8,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1066','买方退款',1,'bt_maifangtuikuan','#b5a922',1,0,'',9,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1067','通信费',1,'bt_tongxin','#958a3c',1,0,'',10,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1068','生产设备',1,'bt_shebei','#6e86e0',1,0,'',11,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1071','税费',1,'bt_shuifei','#e16d6d',1,0,'',14,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1072','坏账',1,'bt_huaizhang','#468a3d',1,0,'',15,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1074','保险',1,'bt_baoxian','#d13e3e',1,0,'',17,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1075','罚款',1,'bt_fakuan','#f8703f',1,0,'',18,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1077','结婚照',1,'bt_jiehunzhao','#d56335',1,0,'',1,'2')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1078','装饰家具',1,'bt_furniture','#2793cb',1,0,'',2,'2')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1080','聘礼',1,'bt_pinli','#d44f4f',1,0,'',4,'2')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1081','婚礼',1,'bt_hunli','#11a4d4',1,0,'',5,'2')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1082','礼服',1,'bt_lifu','#27a26f',1,0,'',6,'2')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1083','酒席',1,'bt_jiuxi','#66b34a',1,0,'',7,'2')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1085','喜贴喜糖',1,'bt_xitang','#de4266',1,0,'',9,'2')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1086','回客礼',1,'bt_huikeli','#ff8b4c',1,0,'',10,'2')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1087','婚庆服务',1,'bt_hunqing','#d96c4b',1,0,'',11,'2')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1088','结婚蛋糕',1,'bt_hunli_dangao','#647ede',1,0,'',12,'2')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1089','司仪费',1,'bt_siyi','#5f6cb9',1,0,'',13,'2')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1090','租场地',1,'bt_zuchangdi','#b05c5c',1,0,'',14,'2')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1091','布置费',1,'bt_buzhi','#b4a81e',1,0,'',15,'2')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1092','造型化妆',1,'bt_zaoxing','#be7330',1,0,'',16,'2')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1095','家装建材',1,'bt_jiancai','#d56335',1,0,'',1,'3')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1096','地板地砖',1,'bt_diban','#d44f4f',1,0,'',2,'3')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1097','灯具照明',1,'bt_dengju','#11a4d4',1,0,'',3,'3')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1098','厨房卫浴',1,'bt_weiyu','#35a879',1,0,'',4,'3')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1099','家具',1,'bt_furniture','#2793cb',1,0,'',5,'3')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1100','家用装饰',1,'bt_buzhi','#b4a81e',1,0,'',6,'3')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1101','门窗',1,'bt_menchuang','#d969ba',1,0,'',7,'3')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1102','窗帘',1,'bt_changlian','#de4266',1,0,'',8,'3')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1103','室内设计费',1,'bt_sheji','#4f8ed5',1,0,'',9,'3')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1104','人工费',1,'bt_rengong','#d96c4b',1,0,'',10,'3')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1105','水电工',1,'bt_diangong','#647ede',1,0,'',11,'3')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1106','管理费',1,'bt_guanli','#5f6cb9',1,0,'',12,'3')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1109','家电',1,'bt_jiadian','#2ab5a9',1,0,'',15,'3')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1110','杂费',1,'bt_zafei','#b05c5c',1,0,'',16,'3')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1114','参团费',1,'bt_cantuan','#d56335',1,0,'',3,'4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1117','小吃',1,'bt_xiaochi','#d44f4f',1,0,'',6,'4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1119','纪念品',1,'bt_jinianpin','#11a4d4',1,0,'',8,'4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1121','火车',1,'bt_huoche','#27a26f',1,0,'',10,'4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1122','的士',1,'bt_dishi','#66b34a',1,0,'',11,'4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1123','旅行装备',1,'bt_lvxing','#ff8b4c',1,0,'',12,'4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1124','数码装备',1,'bt_shuma','#2a509f',1,0,'',13,'4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1125','租赁费',1,'bt_zuchangdi','#b05c5c',1,0,'',14,'4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1126','导游费',1,'bt_daoyou','#be7330',1,0,'',15,'4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2028','应收款',0,'bt_yingshou','#66b34a',1,0,'',2,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2029','销售额',0,'bt_xiaoshoue','#2bbeb2',1,0,'',3,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2031','卖方退货',0,'bt_maifangtuihuo','#e0866b',1,0,'',5,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2032','卖方退款',0,'bt_maifangtuikuan','#b5a922',1,0,'',6,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2033','退税',0,'bt_shuifei','#e16d6d',1,0,'',7,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2034','投资',0,'bt_touzi','#d44f4f',1,0,'',8,'1')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2039','赞助费',0,'bt_zanzhu','#66b34a',1,0,'',3,'2')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2045','赞助费',0,'bt_zanzhu','#66b34a',1,0,'',4,'3')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2049','赞助费',0,'bt_zanzhu','#66b34a',1,0,'',2,'4')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('7','借贷变更收入',0,NULL,'#993f84',2,0,NULL,NULL,NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('8','借贷变更支出',1,NULL,'#4a8984',2,0,NULL,NULL,NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('9','借贷余额转入',0,NULL,NULL,2,0,NULL,NULL,NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('10','借贷余额转出',1,NULL,NULL,2,0,NULL,NULL,NULL)"];
}


@end
