/*
 Navicat Premium Data Transfer

 Source Server         : Mysql
 Source Server Type    : MySQL
 Source Server Version : 80026
 Source Host           : localhost:3306
 Source Schema         : py_jiuidankefang

 Target Server Type    : MySQL
 Target Server Version : 80026
 File Encoding         : 65001

 Date: 22/06/2026 18:05:08
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for attendance
-- ----------------------------
DROP TABLE IF EXISTS `attendance`;
CREATE TABLE `attendance`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `employee_id` int(0) NOT NULL,
  `date` date NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_at` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `employee_id`(`employee_id`) USING BTREE,
  CONSTRAINT `attendance_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of attendance
-- ----------------------------
INSERT INTO `attendance` VALUES (1, 2, '2026-06-20', 'normal', '2026-06-22 17:33:14');
INSERT INTO `attendance` VALUES (2, 2, '2026-06-21', 'late', '2026-06-22 17:33:14');
INSERT INTO `attendance` VALUES (3, 3, '2026-06-20', 'normal', '2026-06-22 17:33:14');

-- ----------------------------
-- Table structure for carousels
-- ----------------------------
DROP TABLE IF EXISTS `carousels`;
CREATE TABLE `carousels`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `image_url` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `link_url` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sort_order` int(0) NULL DEFAULT NULL,
  `created_at` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of carousels
-- ----------------------------
INSERT INTO `carousels` VALUES (1, '暑期特惠', '/static/images/banner1.svg', NULL, 1, '2026-06-22 17:33:14');
INSERT INTO `carousels` VALUES (2, '商务出行首选', '/static/images/banner2.svg', NULL, 2, '2026-06-22 17:33:14');

-- ----------------------------
-- Table structure for check_ins
-- ----------------------------
DROP TABLE IF EXISTS `check_ins`;
CREATE TABLE `check_ins`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `order_id` int(0) NOT NULL,
  `actual_check_in_time` datetime(0) NULL DEFAULT NULL,
  `id_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `id_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_at` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `order_id`(`order_id`) USING BTREE,
  CONSTRAINT `check_ins_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of check_ins
-- ----------------------------
INSERT INTO `check_ins` VALUES (1, 1, '2026-06-25 14:00:00', '身份证', '310101199001010001', '2026-06-22 17:33:14');
INSERT INTO `check_ins` VALUES (2, 2, '2026-06-22 17:50:12', '身份证', '12442314', '2026-06-22 17:50:12');

-- ----------------------------
-- Table structure for check_outs
-- ----------------------------
DROP TABLE IF EXISTS `check_outs`;
CREATE TABLE `check_outs`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `check_in_id` int(0) NOT NULL,
  `check_out_time` datetime(0) NULL DEFAULT NULL,
  `total_fee` decimal(10, 2) NULL DEFAULT NULL,
  `deposit_refunded` decimal(10, 2) NULL DEFAULT NULL,
  `created_at` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `check_in_id`(`check_in_id`) USING BTREE,
  CONSTRAINT `check_outs_ibfk_1` FOREIGN KEY (`check_in_id`) REFERENCES `check_ins` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of check_outs
-- ----------------------------
INSERT INTO `check_outs` VALUES (1, 2, '2026-06-22 17:50:21', 1288.00, 100.00, '2026-06-22 17:50:21');

-- ----------------------------
-- Table structure for complaints
-- ----------------------------
DROP TABLE IF EXISTS `complaints`;
CREATE TABLE `complaints`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `user_id` int(0) NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `reply` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_at` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id`(`user_id`) USING BTREE,
  CONSTRAINT `complaints_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of complaints
-- ----------------------------
INSERT INTO `complaints` VALUES (1, 1, '空调制冷效果不好', NULL, 'pending', '2026-06-22 17:33:14');
INSERT INTO `complaints` VALUES (2, 2, 'asdfghjk', NULL, 'pending', '2026-06-22 17:50:36');

-- ----------------------------
-- Table structure for deposits
-- ----------------------------
DROP TABLE IF EXISTS `deposits`;
CREATE TABLE `deposits`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `order_id` int(0) NOT NULL,
  `amount` decimal(10, 2) NULL DEFAULT NULL,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_at` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `order_id`(`order_id`) USING BTREE,
  CONSTRAINT `deposits_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of deposits
-- ----------------------------
INSERT INTO `deposits` VALUES (1, 1, 500.00, 'pay', 'completed', '2026-06-22 17:33:14');
INSERT INTO `deposits` VALUES (2, 2, 100.00, 'pay', 'completed', '2026-06-22 17:50:05');

-- ----------------------------
-- Table structure for employees
-- ----------------------------
DROP TABLE IF EXISTS `employees`;
CREATE TABLE `employees`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password_hash` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `position` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_at` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of employees
-- ----------------------------
INSERT INTO `employees` VALUES (1, 'admin', '123456', '系统管理员', NULL, 'admin', '总经理', '2026-06-22 17:33:14');
INSERT INTO `employees` VALUES (2, 'staff01', '123456', '张三', NULL, 'staff', '前台', '2026-06-22 17:33:14');
INSERT INTO `employees` VALUES (3, 'staff02', '123456', '李四', NULL, 'staff', '客房服务', '2026-06-22 17:33:14');

-- ----------------------------
-- Table structure for favorites
-- ----------------------------
DROP TABLE IF EXISTS `favorites`;
CREATE TABLE `favorites`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `user_id` int(0) NOT NULL,
  `room_id` int(0) NOT NULL,
  `created_at` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_user_room`(`user_id`, `room_id`) USING BTREE,
  INDEX `room_id`(`room_id`) USING BTREE,
  CONSTRAINT `favorites_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `favorites_ibfk_2` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of favorites
-- ----------------------------
INSERT INTO `favorites` VALUES (1, 1, 2, '2026-06-22 17:33:14');
INSERT INTO `favorites` VALUES (2, 1, 4, '2026-06-22 17:33:14');
INSERT INTO `favorites` VALUES (3, 2, 7, '2026-06-22 17:36:29');
INSERT INTO `favorites` VALUES (6, 2, 3, '2026-06-22 17:36:41');
INSERT INTO `favorites` VALUES (8, 2, 2, '2026-06-22 17:49:52');

-- ----------------------------
-- Table structure for hotels
-- ----------------------------
DROP TABLE IF EXISTS `hotels`;
CREATE TABLE `hotels`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `name` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `address` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `star` int(0) NULL DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `image` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_at` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 74 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hotels
-- ----------------------------
INSERT INTO `hotels` VALUES (1, '悦海国际大酒店', '上海市浦东新区陆家嘴金融贸易区世纪大道100号', 5, '五星级豪华商务酒店，坐落于陆家嘴核心地段，拥有无敌江景。', '/static/images/default-hotel.svg', '2026-06-22 17:33:14');
INSERT INTO `hotels` VALUES (2, '西湖湖畔度假酒店', '杭州市西湖区北山路78号', 4, '紧邻西湖，环境优雅，是休闲度假的理想之选。', '/static/images/default-hotel.svg', '2026-06-22 17:33:14');
INSERT INTO `hotels` VALUES (3, '京城阳光快捷酒店', '北京市朝阳区建国路88号', 3, '经济实惠的商务快捷酒店，交通便利性价比高。', '/static/images/default-hotel.svg', '2026-06-22 17:33:14');
INSERT INTO `hotels` VALUES (4, '武汉天河机场假日酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (5, '广州海航威斯汀酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (6, '青岛胶东国际机场华美达酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (7, '清远狮子湖喜来登度假酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (8, '杭州萧山国际机场智选假日酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (9, 'Park Hotel', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (10, '贵阳机场假日酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (11, '北京明豪华美达酒店（原北京明豪戴斯酒店）', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (12, '长春万达美华酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (13, '济南临空智选假日酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (14, '武汉帝盛酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (15, '北京大兴机场万枫酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (16, 'Nostalgia S Hotel Kunming D ong feng Square', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (17, 'Huazhu Luxury Yangshuo Deshe Homestay Yulong River Ten Mile Gallery Branch', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (18, '北京大兴国际机场木棉花酒店， 凯悦臻选品牌旗下', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (19, '上海高铁东站希尔顿花园酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (20, '青岛国际机场君廷酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (21, '济南高新希尔顿花园酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (22, '全季郑州中原万达西三环地铁站酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (23, '安途·苍穹｜穹霄隐墟Sanctuary·海景民宿', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (24, '乌镇记忆年华客栈', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (25, '院中院丨墨林丨咖啡畅饮丨供氧庭院', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (26, '泉州中心智选假日酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (27, 'Longsheng Xichuangyue B&B Hotel', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (28, '广州白云机场T2航站楼智选假日酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (29, '忆泊酒店（杭州西湖店）', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (30, '杭州萧山国际机场凯悦嘉轩酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:22');
INSERT INTO `hotels` VALUES (31, '全季酒店（郑州正弘城科技市场智汇城店）', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (32, '济南CBD山东港口大厦亚朵S酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (33, '上海浦东机场假日酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (34, 'Beijing Feng Rong Jun Hua Airport T3 Beijing', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (35, 'Radisson Blu Hotel Nanchang', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (36, '兴城希尔顿惠庭酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (37, '北京大兴国际机场希尔顿花园酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (38, '上海海上铂悦酒店（免费提供浦东机场和迪士尼班车接送）', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (39, '全季酒店（郑州中原万达广场二砂地铁站店）', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (40, '花筑奢九华山陌上星空互见酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (41, '花筑奢牛首隐岚民宿', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (42, '昆明空港希尔顿逸林酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (43, '广州白云机场诺富特酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (44, 'EVEN Hotel 中山中心逸衡酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (45, '丰荣君华首都机场新国展店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (46, '长沙高铁南站智选假日酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (47, '上海浦东机场智选假日酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (48, '湖州东吴银泰凤凰路轻居酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (49, '全季酒店（无锡太科园店）', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (50, '沈阳中街故宫文化博物馆亚朵S酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (51, '美宿悦致酒店岳阳平江店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (52, '连云港福朋喜来登酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (53, 'Wenzhou City Center All-Day Hotel First Bridge Branch Adjacent to Wuma Street, Zhongshan Park, Jiangxinyu, Gym, Laundry Service, Free Breakfast, Coffee, Afternoon Tea, Daily Necessities, Full Wireless Coverage, Tourist Attractions, Food and Specialty Reco', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (54, '三里田秘境丨咖啡畅饮丨供氧观景酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (55, 'Bor Manju Vacation guesthouse--Near the Ticket Gate--service in Chinese and English', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (56, 'BaoFeng Lake Narrative Light Retreat-Chinese Style-Pick-up-ZhangjiajieTickets-LocalGuideService', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (57, 'Zhangjiajie Fantasy Valley Resort Customized travel itineraries free shuttle service to the North and West Gates of the National Forest Park, and complimentary traditional ethnic costume try-on', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (58, '康铂酒店深圳国际会展中心店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (59, '桔子酒店（北京天坛东门店）', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (60, '南京老门东家墅会别墅精品酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (61, 'The Yard Boutique Hotel Shanghai 一隅酒店上海虹桥漕河泾店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (62, '凯里酒店上海浦东机场店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (63, '洛阳龙门智选假日酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (64, 'Wangxian Valley Qingchuanxingguan - Wangxian Valley Scenic Area', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (65, '龙胜云漫田间观景酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (66, '济南泉城广场智选假日酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (67, '南昌方大智选假日酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (68, 'Zhangjiajie Lijing Boutique Hotel-Superior Class-Entrance of Baofeng Lake-English Support-Self-Service Laundry-Expansive Breakfast Buffet', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (69, '丽江且亭酒店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (70, '青泥8号酒店公寓（大连火车站中山广场店）', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (71, '维也纳酒店江苏扬州瘦西湖文昌阁店', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (72, '夏朗酒店 Xialang Hotel&Free ShuttleBus to Guangzhou BaiyunInternational Airpor', '上海市', 4, '', NULL, '2026-06-22 18:00:23');
INSERT INTO `hotels` VALUES (73, 'Phonenix Perches Holiday Inn - Wuyi Avenue-Adjacent Changsha Railway Station', '上海市', 4, '', NULL, '2026-06-22 18:00:23');

-- ----------------------------
-- Table structure for news
-- ----------------------------
DROP TABLE IF EXISTS `news`;
CREATE TABLE `news`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `category_id` int(0) NULL DEFAULT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `image` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_at` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `category_id`(`category_id`) USING BTREE,
  CONSTRAINT `news_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `news_categories` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of news
-- ----------------------------
INSERT INTO `news` VALUES (1, 1, '悦海国际荣获2026年度最佳商务酒店奖', '经过激烈评选，悦海国际大酒店凭借卓越服务荣获年度大奖...', NULL, '2026-06-22 17:33:14');
INSERT INTO `news` VALUES (2, 2, '暑期家庭套房8折优惠', '即日起至2026年8月31日，预订家庭套房享8折优惠...', NULL, '2026-06-22 17:33:14');

-- ----------------------------
-- Table structure for news_categories
-- ----------------------------
DROP TABLE IF EXISTS `news_categories`;
CREATE TABLE `news_categories`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_at` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of news_categories
-- ----------------------------
INSERT INTO `news_categories` VALUES (1, '酒店动态', '2026-06-22 17:33:14');
INSERT INTO `news_categories` VALUES (2, '优惠活动', '2026-06-22 17:33:14');

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `user_id` int(0) NOT NULL,
  `room_id` int(0) NOT NULL,
  `guest_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `guest_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `check_in_date` date NULL DEFAULT NULL,
  `check_out_date` date NULL DEFAULT NULL,
  `total_price` decimal(10, 2) NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_at` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id`(`user_id`) USING BTREE,
  INDEX `room_id`(`room_id`) USING BTREE,
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of orders
-- ----------------------------
INSERT INTO `orders` VALUES (1, 1, 1, '测试用户', '13800000001', '2026-06-25', '2026-06-28', 8664.00, 'checked_in', '2026-06-22 17:33:14');
INSERT INTO `orders` VALUES (2, 2, 2, 'qwe', '213', '2026-06-22', '2026-06-24', 1288.00, 'checked_out', '2026-06-22 17:50:03');

-- ----------------------------
-- Table structure for rooms
-- ----------------------------
DROP TABLE IF EXISTS `rooms`;
CREATE TABLE `rooms`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `hotel_id` int(0) NOT NULL,
  `room_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `room_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `price` decimal(10, 2) NULL DEFAULT NULL,
  `area` decimal(6, 2) NULL DEFAULT NULL,
  `bed_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `floor` int(0) NULL DEFAULT NULL,
  `has_breakfast` tinyint(1) NULL DEFAULT NULL,
  `rating` decimal(3, 2) NULL DEFAULT NULL,
  `facilities` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `feature_vector` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `image` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `created_at` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `hotel_id`(`hotel_id`) USING BTREE,
  CONSTRAINT `rooms_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 80 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of rooms
-- ----------------------------
INSERT INTO `rooms` VALUES (1, 1, '1801', '豪华套房', 2888.00, 80.00, '特大床', 18, 1, 4.90, 'WiFi,空调,电视,冰箱,浴缸,阳台,办公桌,沙发', NULL, 'available', NULL, '180平米豪华江景套房，带独立书房和按摩浴缸', '2026-06-22 17:33:14');
INSERT INTO `rooms` VALUES (2, 1, '1205', '大床房', 1288.00, 45.00, '大床', 12, 1, 4.70, 'WiFi,空调,电视,冰箱', NULL, 'available', NULL, '朝南观景大床房，40寸智能电视', '2026-06-22 17:33:14');
INSERT INTO `rooms` VALUES (3, 1, '805', '标准间', 888.00, 30.00, '双人床', 8, 0, 4.30, 'WiFi,空调,电视', NULL, 'available', NULL, '舒适标准间，含独立卫浴', '2026-06-22 17:33:14');
INSERT INTO `rooms` VALUES (4, 2, '301', '套房', 1688.00, 65.00, '大床', 3, 1, 4.80, 'WiFi,空调,电视,冰箱,浴缸,阳台,办公桌', NULL, 'available', NULL, '湖景套房，带露台花园', '2026-06-22 17:33:14');
INSERT INTO `rooms` VALUES (5, 2, '205', '双床房', 788.00, 35.00, '单人床', 2, 1, 4.50, 'WiFi,空调,电视', NULL, 'available', NULL, '精致双床房，园林景观窗', '2026-06-22 17:33:14');
INSERT INTO `rooms` VALUES (6, 2, '101', '大床房', 588.00, 28.00, '双人床', 1, 0, 4.20, 'WiFi,空调,电视', NULL, 'available', NULL, '经济大床房，温馨舒适', '2026-06-22 17:33:14');
INSERT INTO `rooms` VALUES (7, 3, '501', '标准间', 388.00, 22.00, '单人床', 5, 0, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '经济标准间，干净整洁', '2026-06-22 17:33:14');
INSERT INTO `rooms` VALUES (8, 3, '302', '大床房', 488.00, 26.00, '大床', 3, 0, 4.10, 'WiFi,空调,电视,办公桌', NULL, 'available', NULL, '商务大床房，配备办公桌', '2026-06-22 17:33:14');
INSERT INTO `rooms` VALUES (9, 3, '201', '家庭房', 688.00, 40.00, '双人床', 2, 1, 4.30, 'WiFi,空调,电视,冰箱,洗衣机', NULL, 'available', NULL, '家庭套房，可加婴儿床', '2026-06-22 17:33:14');
INSERT INTO `rooms` VALUES (10, 4, '303', '大床房', 307.00, 31.00, '特大床', 13, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (11, 5, '231', '大床房', 700.00, 50.00, '特大床', 7, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (12, 6, '521', '双床房', 300.00, 35.00, '单人床', 2, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '双床房客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (13, 7, '477', '大床房', 470.00, 52.00, '大床', 2, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '花园景观', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (14, 8, '689', '大床房', 277.00, 33.00, '大床', 4, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (15, 9, '644', '标准间', 283.00, 25.00, '双人床', 4, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '独立卫浴', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (16, 10, '224', '标准间', 314.00, 35.00, '双人床', 9, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '标准间客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (17, 11, '777', '标准间', 338.00, 19.00, '双人床', 14, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '标准间客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (18, 12, '311', '双床房', 424.00, 32.00, '单人床', 2, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '双床房客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (19, 13, '806', '大床房', 238.00, 25.00, '大床', 3, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (20, 14, '314', '标准间', 287.00, 23.00, '双人床', 9, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '标准间客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (21, 15, '501', '大床房', 387.00, 30.00, '大床', 5, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (22, 16, '391', '大床房', 219.00, 22.00, '大床', 5, 1, 4.00, 'WiFi,空调,电视,零压床垫,智能客控', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (23, 17, '470', '标准间', 309.00, 45.00, '双人床', 10, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '标准间客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (24, 18, '664', '双床房', 850.00, 35.00, '单人床', 4, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '双床房客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (25, 19, '137', '双床房', 360.00, 30.00, '单人床', 9, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '双床房客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (26, 20, '141', '双床房', 459.00, 38.00, '单人床', 8, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '双床房客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (27, 21, '334', '双床房', 325.00, 32.00, '单人床', 5, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '双床房客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (28, 22, '609', '标准间', 352.00, 28.00, '双人床', 4, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '标准间客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (29, 23, '362', '套房', 1480.00, 60.00, '双人床', 11, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '海景', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (30, 24, '500', '大床房', 145.00, 15.00, '大床', 16, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (31, 25, '909', '双床房', 399.00, 35.00, '单人床', 3, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '双床房客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (32, 26, '772', '大床房', 314.00, 20.00, '大床', 2, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (33, 27, '213', '大床房', 391.00, 35.00, '大床', 16, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (34, 28, '506', '双床房', 296.00, 30.00, '单人床', 16, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '双床房客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (35, 29, '789', '大床房', 492.00, 28.00, '大床', 2, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (36, 30, '721', '双床房', 410.00, 35.00, '单人床', 15, 1, 4.00, 'WiFi,空调,电视,沙发', NULL, 'available', NULL, '带沙发', '2026-06-22 18:00:22');
INSERT INTO `rooms` VALUES (37, 31, '215', '双床房', 362.00, 30.00, '单人床', 15, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '双床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (38, 32, '717', '双床房', 427.00, 27.00, '单人床', 2, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '双床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (39, 33, '956', '双床房', 954.00, 30.00, '单人床', 9, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '双床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (40, 34, '380', '双床房', 405.00, 15.00, '单人床', 4, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '双床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (41, 35, '428', '标准间', 398.00, 48.00, '双人床', 3, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '标准间客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (42, 36, '337', '双床房', 448.00, 30.00, '单人床', 12, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '山景', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (43, 37, '402', '双床房', 357.00, 30.00, '单人床', 2, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '双床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (44, 38, '990', '大床房', 290.00, 26.00, '大床', 11, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (45, 39, '787', '大床房', 480.00, 23.00, '大床', 2, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (46, 40, '620', '标准间', 281.00, 50.00, '双人床', 8, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '标准间客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (47, 41, '902', '标准间', 576.00, 30.00, '双人床', 6, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '标准间客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (48, 42, '687', '双床房', 418.00, 39.00, '单人床', 9, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '双床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (49, 43, '491', '双床房', 624.00, 28.00, '单人床', 13, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '双床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (50, 44, '199', '双床房', 394.00, 28.00, '单人床', 11, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '双床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (51, 45, '472', '双床房', 426.00, 28.00, '单人床', 4, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '双床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (52, 46, '276', '大床房', 260.00, 35.00, '特大床', 4, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '空间宽敞', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (53, 47, '201', '大床房', 414.00, 21.00, '大床', 3, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (54, 48, '544', '双床房', 287.00, 21.00, '单人床', 3, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '双床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (55, 49, '284', '大床房', 362.00, 26.00, '大床', 12, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (56, 50, '100', '大床房', 594.00, 24.00, '大床', 3, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (57, 51, '997', '标准间', 259.00, 25.00, '双人床', 12, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '标准间客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (58, 52, '816', '大床房', 574.00, 38.00, '大床', 11, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (59, 53, '251', '大床房', 290.00, 26.00, '特大床', 7, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (60, 54, '144', '双床房', 362.00, 35.00, '单人床', 15, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '花园景观', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (61, 55, '274', '标准间', 372.00, 35.00, '双人床', 5, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '独立卫浴', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (62, 56, '672', '标准间', 268.00, 30.00, '双人床', 13, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '标准间客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (63, 57, '445', '标准间', 560.00, 60.00, '双人床', 11, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '山景', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (64, 58, '382', '标准间', 178.00, 35.00, '双人床', 16, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '标准间客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (65, 59, '363', '大床房', 558.00, 25.00, '大床', 12, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (66, 60, '358', '标准间', 252.00, 25.00, '双人床', 11, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '标准间客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (67, 61, '548', '标准间', 376.00, 20.00, '双人床', 12, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '标准间客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (68, 62, '759', '双床房', 233.00, 26.00, '单人床', 15, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '双床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (69, 63, '960', '双床房', 258.00, 25.00, '单人床', 2, 1, 4.00, 'WiFi,空调,电视,无窗', NULL, 'available', NULL, '无窗', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (70, 64, '115', '标准间', 214.00, 21.00, '双人床', 16, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '独立卫浴', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (71, 65, '932', '双床房', 377.00, 30.00, '单人床', 12, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '山景', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (72, 66, '409', '大床房', 320.00, 20.00, '特大床', 7, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (73, 67, '710', '大床房', 220.00, 33.00, '大床', 11, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '空间宽敞', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (74, 68, '507', '双床房', 342.00, 38.00, '单人床', 4, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '山景', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (75, 69, '678', '大床房', 175.00, 30.00, '大床', 12, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (76, 70, '141', '大床房', 216.00, 35.00, '大床', 15, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (77, 71, '320', '标准间', 192.00, 15.00, '双人床', 15, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '标准间客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (78, 72, '673', '大床房', 277.00, 25.00, '大床', 4, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:23');
INSERT INTO `rooms` VALUES (79, 73, '960', '大床房', 284.00, 24.00, '大床', 2, 1, 4.00, 'WiFi,空调,电视', NULL, 'available', NULL, '大床房客房', '2026-06-22 18:00:23');

-- ----------------------------
-- Table structure for salaries
-- ----------------------------
DROP TABLE IF EXISTS `salaries`;
CREATE TABLE `salaries`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `employee_id` int(0) NOT NULL,
  `month` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `basic_salary` decimal(10, 2) NULL DEFAULT NULL,
  `overtime_pay` decimal(10, 2) NULL DEFAULT NULL,
  `bonus` decimal(10, 2) NULL DEFAULT NULL,
  `total` decimal(10, 2) NULL DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_at` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `employee_id`(`employee_id`) USING BTREE,
  CONSTRAINT `salaries_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of salaries
-- ----------------------------
INSERT INTO `salaries` VALUES (1, 2, '2026-06', 5000.00, 300.00, 500.00, 5800.00, 'paid', '2026-06-22 17:33:14');
INSERT INTO `salaries` VALUES (2, 3, '2026-06', 4500.00, 0.00, 200.00, 4700.00, 'pending', '2026-06-22 17:33:14');

-- ----------------------------
-- Table structure for services
-- ----------------------------
DROP TABLE IF EXISTS `services`;
CREATE TABLE `services`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `check_in_id` int(0) NOT NULL,
  `service_type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_at` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `check_in_id`(`check_in_id`) USING BTREE,
  CONSTRAINT `services_ibfk_1` FOREIGN KEY (`check_in_id`) REFERENCES `check_ins` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of services
-- ----------------------------
INSERT INTO `services` VALUES (1, 2, 'cleaning', '申请保洁服务', 'pending', '2026-06-22 17:50:14');

-- ----------------------------
-- Table structure for system_config
-- ----------------------------
DROP TABLE IF EXISTS `system_config`;
CREATE TABLE `system_config`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `config_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `config_key`(`config_key`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of system_config
-- ----------------------------
INSERT INTO `system_config` VALUES (1, 'about_us', '本系统是基于KNN推荐算法的酒店客房管理平台，致力于为用户提供个性化酒店推荐服务。');
INSERT INTO `system_config` VALUES (2, 'system_intro', '欢迎使用智能酒店客房管理系统，支持客房浏览、在线预订、个性化推荐、到店入住等一站式服务。');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password_hash` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `avatar` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `created_at` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'testuser', '123456', '测试用户', '13800000001', NULL, '2026-06-22 17:33:14');
INSERT INTO `user` VALUES (2, 'wangwu', '123456', '王五', '13800000002', '/static/uploads/avatars/c8cf4dfdb5954a34bdb42081240eef71.jpg', '2026-06-22 17:33:14');
INSERT INTO `user` VALUES (3, 'admin', '123456', '管理员用户', '13900000000', NULL, '2026-06-22 17:52:33');

SET FOREIGN_KEY_CHECKS = 1;
