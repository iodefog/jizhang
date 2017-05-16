//
//  SSJDatabaseVersion3.m
//  SuiShouJi
//
//  Created by old lang on 16/5/12.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDatabaseVersion3.h"
#import "FMDB.h"

@implementation SSJDatabaseVersion3

+ (NSString *)dbVersion {
    return @"unknown";
}

+ (NSError *)startUpgradeInDatabase:(FMDatabase *)db {
    NSError *error = [self upgradeBillTypeTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self upgradeUserBillTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self upgradeUserTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    error = [self upgradeFundInfoTableWithDatabase:db];
    if (error) {
        return error;
    }
    
    return nil;
}

+ (NSError *)upgradeBillTypeTableWithDatabase:(FMDatabase *)db {
    if (![db executeUpdate:@"delete from bk_bill_type"]) {
        return [db lastError];
    }
    
    if (![db columnExists:@"icustom" inTableWithName:@"bk_bill_type"]) {
        if (![db executeUpdate:@"alter table bk_bill_type add icustom integer"]) {
            return [db lastError];
        }
    }
    
    if (![db columnExists:@"cparent" inTableWithName:@"bk_bill_type"]) {
        if (![db executeUpdate:@"alter table bk_bill_type add cparent text"]) {
            return [db lastError];
        }
    }
    
    if (![db columnExists:@"defaultOrder" inTableWithName:@"bk_bill_type"]) {
        if (![db executeUpdate:@"alter table bk_bill_type add defaultOrder integer"]) {
            return [db lastError];
        }
    }
    
    for (NSString *sqlStr in [self insertSqlArray]) {
        if (![db executeUpdate:sqlStr]) {
            return [db lastError];
        }
    }
    
    return nil;
}

+ (NSError *)upgradeUserBillTableWithDatabase:(FMDatabase *)db {
    if (![db columnExists:@"iorder" inTableWithName:@"bk_user_bill"]) {
        if (![db executeUpdate:@"alter table bk_user_bill add iorder integer"]) {
            return [db lastError];
        }
    }
    
    // 更新排序字段
    if (![db executeUpdate:@"update bk_user_bill set iorder = (select defaultOrder from bk_bill_type where bk_user_bill.cbillId = bk_bill_type.id)"]) {
        return [db lastError];
    }
    
    return nil;
}

+ (NSError *)upgradeUserTableWithDatabase:(FMDatabase *)db {
    if (![db columnExists:@"cmotionPwdTrackState" inTableWithName:@"bk_user"]) {
        if (![db executeUpdate:@"alter table bk_user add cmotionPwdTrackState integer default 1"]) {
            return [db lastError];
        }
    }
    
    if (![db columnExists:@"cfingerPrintState" inTableWithName:@"bk_user"]) {
        if (![db executeUpdate:@"alter table bk_user add cfingerPrintState integer default 1"]) {
            return [db lastError];
        }
    }
    
    return nil;
}

+ (NSError *)upgradeFundInfoTableWithDatabase:(FMDatabase *)db {
    if (![db columnExists:@"iorder" inTableWithName:@"bk_fund_info"]) {
        if (![db executeUpdate:@"alter table bk_fund_info add iorder integer"]) {
            return [db lastError];
        }
    }
    return nil;
}

+ (NSArray *)insertSqlArray {
    return  @[@"INSERT INTO `BK_BILL_TYPE` VALUES ('1000','餐饮',1,NULL,'bt_food','#ee9d29',1,0,NULL,2)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1001','烟酒茶',1,NULL,'bt_tobacco','#4f8ed5',1,0,NULL,12)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1002','交通',1,NULL,'bt_traffic','#379647',1,0,NULL,3)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1003','购物',1,NULL,'bt_shopping','#d56335',1,0,NULL,4)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1004','娱乐',1,NULL,'bt_entertainment','#647ede',1,0,NULL,16)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1005','投资亏损',1,NULL,'bt_deficit','#408637',1,0,NULL,22)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1006','生活服务',1,NULL,'bt_service','#d13e3e',0,0,NULL,24)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1007','话费',1,NULL,'bt_recharge','#465a9b',1,0,NULL,20)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1008','医药',1,NULL,'bt_medicine','#f25c5c',0,0,NULL,42)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1009','住房',1,NULL,'bt_house','#b05c5c',1,0,NULL,18)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1010','水电煤',1,NULL,'bt_water','#a66e16',1,0,NULL,19)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1011','食材',1,NULL,'bt_shicai','#f86e3c',0,0,NULL,25)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1012','水果',1,NULL,'bt_fruit','#66b34a',1,0,NULL,8)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1013','零食',1,NULL,'bt_snack','#d969ba',1,0,NULL,9)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1014','汽车',1,NULL,'bt_car','#83aa3f',0,0,NULL,36)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1015','家居',1,NULL,'bt_furniture','#2793cb',0,0,NULL,33)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1016','服饰',1,NULL,'bt_clothes','#ff8bc4',1,0,NULL,11)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1017','美容美发',1,NULL,'bt_meirong','#fc7f58',0,0,NULL,43)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1018','旅行',1,NULL,'bt_tourism','#78a354',0,0,NULL,26)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1019','礼金',1,NULL,'bt_gift','#c62f2f',1,0,NULL,23)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1020','家用',1,NULL,'bt_jiayong','#be7330',1,0,NULL,21)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1021','育婴',1,NULL,'bt_baby','#d96cb4',1,0,NULL,13)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1022','教育',1,NULL,'bt_education','#278f38',0,0,NULL,45)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1023','健身',1,NULL,'bt_sport','#07a1c2',0,0,NULL,39)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1024','结婚',1,NULL,'bt_marry','#e15534',0,0,NULL,46)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1025','维修',1,NULL,'bt_repair','#478e98',0,0,NULL,47)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1026','养宠',1,NULL,'bt_pet','#ab9444',0,0,NULL,38)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1027','清洁',1,NULL,'bt_clean','#359dc8',0,0,NULL,48)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1028','数码',1,NULL,'bt_digital','#2c53ab',0,0,NULL,34)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1029','邮费',1,NULL,'bt_youfei','#6b883c',0,0,NULL,32)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1030','利息',1,NULL,'bt_interest','#408637',0,0,NULL,53)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1031','还钱',1,NULL,'bt_huankuan','#7b529b',0,0,NULL,31)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1032','交税',1,NULL,'bt_jiaoshui','#e16b6b',0,0,NULL,54)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1033','其他',1,NULL,'bt_others','#626262',0,0,NULL,56)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2001','工资',0,NULL,'bt_wages','#e1861b',1,0,NULL,2)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2002','奖金',0,NULL,'bt_bouns','#66b34a',1,0,NULL,3)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2003','福利',0,NULL,'bt_fuli','#2bbeb2',1,0,NULL,4)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2004','投资收益',0,NULL,'bt_invest','#d44f4f',1,0,NULL,5)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2005','收红包',0,NULL,'bt_hongbao','#e15534',1,0,NULL,6)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2006','兼职',0,NULL,'bt_jianzhi','#78a543',1,0,NULL,7)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2007','生活费',0,NULL,'bt_shenghuofei','#be7330',1,0,NULL,8)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2008','报销',0,NULL,'bt_baoxiao','#6691e9',1,0,NULL,9)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2009','退款',0,NULL,'bt_tuikuan','#68b58a',1,0,NULL,10)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2010','公积金',0,NULL,'bt_gongjijin','#766bc8',1,0,NULL,13)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2011','社保金',0,NULL,'bt_shebao','#359dc8',1,0,NULL,14)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2012','礼金',0,NULL,'bt_gift','#c62f2f',1,0,NULL,11)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2013','收款',0,NULL,'bt_shouzhai','#63671a',0,0,NULL,15)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2014','贷款',0,NULL,'bt_daikuan','#b47100',0,0,NULL,16)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2015','营业',0,NULL,'bt_yingye','#00a2f2',0,0,NULL,17)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2017','其他',0,NULL,'bt_others','#626262',0,0,NULL,25)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1','平账收入',0,NULL,'bt_pignzhangshouru','#9382ad',2,0,NULL,NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2','平账支出',1,NULL,'bt_pingzhangzhichu','#5889c5',2,0,NULL,NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3','转入',0,NULL,'bt_zhuanchu','#993f84',2,0,NULL,NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4','转出',1,NULL,'bt_zhuanru','#4a8984',2,0,NULL,NULL)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1034','发红包',1,'','bt_hongbao','#d44f4f',1,0,NULL,5)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1035','日用品',1,'','bt_riyong','#11a4d4',1,0,NULL,6)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1036','买菜',1,'','bt_maicai','#27a26f',1,0,NULL,7)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1037','护肤美妆',1,'','bt_meizhuang','#de4266',1,0,NULL,10)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1038','奶粉',1,'','bt_naifen','#b4a81e',1,0,NULL,14)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1039','尿布',1,'','bt_niaobu','#958a3c',1,0,NULL,15)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1040','电影',1,'','bt_dianying','#5f6cb9',1,0,NULL,17)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1042','花钱',1,'','bt_huaqian','#f26d49',1,0,NULL,1)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1043','酒店',1,'','bt_jiudian','#766bc8',0,0,NULL,28)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1044','机票',1,'','bt_jipiao','#3c81ce',0,0,NULL,29)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1045','生意',1,'','bt_shengyi','#ad492b',0,0,NULL,30)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1046','电器',1,'','bt_dianqi','#e16b6b',0,0,NULL,35)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1047','小孩零用',1,'','bt_lingyong','#9f5c1b',0,0,NULL,37)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1048','KTV',1,'','bt_ktv','#9c4141',0,0,NULL,40)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1049','游园',1,'','bt_youyuan','#6691e9',0,0,NULL,41)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1050','装修',1,'','bt_zhaungxiu','#e1861b',0,0,NULL,44)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1051','平账差额',1,'','bt_chae','#917636',0,0,NULL,50)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1052','手续费',1,'','bt_shouxufei','#d4ba28',0,0,NULL,51)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1053','佣金',1,'','bt_yongjin','#68b58a',0,0,NULL,52)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1056','借出款',1,'','bt_jiechu','#b84848',0,0,NULL,55)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2018','赚钱',0,'','bt_zhuanqian','#f25c5c',1,0,NULL,1)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2020','借入款',0,'','bt_jiechu','#b84848',1,0,NULL,12)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2021','零花钱',0,'','bt_lingyong','#9f5c1b',0,0,NULL,19)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2022','租金',0,'','bt_zujin','#b05c5c',0,0,NULL,20)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2023','中奖',0,'','bt_zhongjiang','#de4266',0,0,NULL,21)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2024','佣金提成',0,'','bt_yongjin','#68b58a',0,0,NULL,22)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2025','利息',0,'','bt_interest','#408637',0,0,NULL,23)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2026','分红',0,'','bt_fenhong','#ad492b',0,0,NULL,24)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1041','出差',1,NULL,'bt_chuchai','#426ab2',0,0,NULL,27)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('1057','保姆',1,NULL,'bt_baomu','#b3852b',0,0,NULL,49)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('2016','意外收入',0,NULL,'bt_yiwai','#004cb6',0,0,NULL,18)",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3001','',1,'','bt_chi','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3002','',1,'','bt_car','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3003','',1,'','bt_house','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3004','',1,'','bt_child','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3005','',1,'','bt_ren','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3006','',1,'','bt_xie','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3007','',1,'','bt_gouwu','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3008','',1,'','bt_qiu','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3009','',1,'','bt_chong','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3010','',1,'','bt_qian','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3011','',1,'','bt_feiji','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3012','',1,'','bt_shu','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3013','',1,'','bt_zhaungxiu','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3014','',1,'','bt_money','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3015','',1,'','bt_dian','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3016','',1,'','bt_caizhi','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3017','',1,'','bt_hezi','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3018','',1,'','bt_baozhuang','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3019','',1,'','bt_qianbao','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3020','',1,'','bt_taobao','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3021','',1,'','bt_youxi','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3022','',1,'','bt_wenju','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3023','',1,'','bt_wanju','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3024','',1,'','bt_menpiao','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3025','',1,'','bt_dangao','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3026','',1,'','bt_food','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3027','',1,'','bt_traffic','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3028','',1,'','bt_shopping','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3029','',1,'','bt_snack','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3030','',1,'','bt_meizhuang','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3031','',1,'','bt_riyong','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3032','',1,'','bt_maicai','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3033','',1,'','bt_fruit','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3034','',1,'','bt_luobo','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3035','',1,'','bt_shui','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3036','',1,'','bt_clothes','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3037','',1,'','bt_entertainment','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3038','',1,'','bt_deficit','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3039','',1,'','bt_recharge','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3040','',1,'','bt_service','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3041','',1,'','bt_shicai','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3042','',1,'','bt_tourism','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3043','',1,'','bt_chuchai','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3044','',1,'','bt_jiudian','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3045','',1,'','bt_meirong','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3046','',1,'','bt_shengyi','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3047','',1,'','bt_jiaoshui','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3048','',1,'','bt_youfei','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3049','',1,'','bt_furniture','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3050','',1,'','bt_clean','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3051','',1,'','bt_sport','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3052','',1,'','bt_ktv','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3053','',1,'','bt_youyuan','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3054','',1,'','bt_medicine','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3055','',1,'','bt_repair','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3056','',1,'','bt_education','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3057','',1,'','bt_marry','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3058','',1,'','bt_baomu','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3059','',1,'','bt_chae','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3060','',1,'','bt_interest','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3061','',1,'','bt_shouxufei','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3062','',1,'','bt_yongjin','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3063','',1,'','bt_huankuan','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('3064','',1,'','bt_jiechu','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4001','',0,'','bt_yingye','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4002','',0,'','bt_wages','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4003','',0,'','bt_jianzhi','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4004','',0,'','bt_gift','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4005','',0,'','bt_fuli','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4006','',0,'','bt_zujin','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4007','',0,'','bt_daikuan','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4008','',0,'','bt_chaopiao','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4009','',0,'','bt_interest','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4010','',0,'','bt_fenhong','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4011','',0,'','bt_bouns','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4012','',0,'','bt_invest','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4013','',0,'','bt_shenghuofei','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4014','',0,'','bt_baoxiao','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4015','',0,'','bt_tuikuan','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4016','',0,'','bt_gift','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4017','',0,'','bt_jiechu','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4018','',0,'','bt_shebao','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4019','',0,'','bt_gongjijin','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4020','',0,'','bt_lingyong','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4021','',0,'','bt_daikuan','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4022','',0,'','bt_shouzhai','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4023','',0,'','bt_yiwai','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4024','',0,'','bt_zhongjiang','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4025','',0,'','bt_interest','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4026','',0,'','bt_yongjin','',NULL,NULL,'root','')",
              @"INSERT INTO `BK_BILL_TYPE` VALUES ('4027','',0,'','bt_huaqian','',NULL,NULL,'root','')"];
}

@end
