/*
 Navicat Premium Data Transfer

 Source Server         : MySql测试数据库
 Source Server Type    : MySQL
 Source Server Version : 80036 (8.0.36)
 Source Host           : localhost:3306
 Source Schema         : cashiersystem

 Target Server Type    : MySQL
 Target Server Version : 80036 (8.0.36)
 File Encoding         : 65001

 Date: 30/08/2025 17:34:01
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for sys_bill
-- ----------------------------
DROP TABLE IF EXISTS `sys_bill`;
CREATE TABLE `sys_bill`  (
  `bill_id` bigint NOT NULL AUTO_INCREMENT COMMENT '账单ID（主键）',
  `order_id` bigint NOT NULL COMMENT '主订单ID',
  `bill_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '账单编号',
  `parent_bill_id` bigint NOT NULL DEFAULT 0 COMMENT '父账单ID（分单时用，主单为0）',
  `total_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '总金额',
  `discount_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '优惠金额',
  `service_fee` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '服务费',
  `payable_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '应付金额',
  `paid_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '已付金额',
  `bill_type` tinyint NOT NULL COMMENT '类型（1-正常账单；2-分单账单；3-宴会账单）',
  `print_status` tinyint NOT NULL DEFAULT 0 COMMENT '打印状态（0-未打印；1-已打印）',
  `close_time` datetime NOT NULL COMMENT '结账时间',
  `invoice_status` tinyint NOT NULL DEFAULT 0 COMMENT '发票状态（0-未开；1-已开电子发票）',
  `invoice_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '电子发票号码（可空）',
  PRIMARY KEY (`bill_id`) USING BTREE,
  UNIQUE INDEX `uk_bill_no`(`bill_no` ASC) USING BTREE,
  INDEX `idx_bill_order`(`order_id` ASC) USING BTREE,
  INDEX `idx_bill_parent`(`parent_bill_id` ASC) USING BTREE,
  INDEX `idx_bill_type`(`bill_type` ASC) USING BTREE,
  INDEX `idx_bill_close_time`(`close_time` ASC) USING BTREE,
  INDEX `idx_bill_invoice`(`invoice_status` ASC) USING BTREE,
  CONSTRAINT `fk_bill_order` FOREIGN KEY (`order_id`) REFERENCES `sys_order` (`order_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '账单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_bill
-- ----------------------------

-- ----------------------------
-- Table structure for sys_coupon
-- ----------------------------
DROP TABLE IF EXISTS `sys_coupon`;
CREATE TABLE `sys_coupon`  (
  `coupon_id` bigint NOT NULL AUTO_INCREMENT COMMENT '优惠券ID（主键）',
  `store_id` bigint NOT NULL COMMENT '适用门店ID（0-全门店）',
  `coupon_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '优惠券编号',
  `coupon_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '优惠券名称',
  `type` tinyint NOT NULL COMMENT '类型（1-满减券；2-折扣券；3-单品券）',
  `value` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '面值（满减金额/折扣率）',
  `min_consumption` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '最低消费（满减券用）',
  `valid_start` datetime NOT NULL COMMENT '生效时间',
  `valid_end` datetime NOT NULL COMMENT '失效时间',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态（1-可用；0-过期/禁用）',
  `applicable_dishes` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '适用菜品ID（逗号分隔，空为全菜品）',
  PRIMARY KEY (`coupon_id`) USING BTREE,
  UNIQUE INDEX `uk_coupon_no`(`coupon_no` ASC) USING BTREE,
  INDEX `idx_coupon_store`(`store_id` ASC) USING BTREE,
  INDEX `idx_coupon_type`(`type` ASC) USING BTREE,
  INDEX `idx_coupon_status`(`status` ASC) USING BTREE,
  INDEX `idx_coupon_valid`(`valid_start` ASC, `valid_end` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '优惠券表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_coupon
-- ----------------------------
INSERT INTO `sys_coupon` VALUES (1, 2, '', '111111', 0, 200.00, 1000.00, '2025-08-29 00:00:00', '2025-09-19 00:00:00', 1, '');

-- ----------------------------
-- Table structure for sys_dish
-- ----------------------------
DROP TABLE IF EXISTS `sys_dish`;
CREATE TABLE `sys_dish`  (
  `dish_id` bigint NOT NULL AUTO_INCREMENT COMMENT '菜品ID（主键）',
  `category_id` bigint NOT NULL COMMENT '所属分类ID',
  `store_id` bigint NULL DEFAULT NULL COMMENT '所属门店ID（支持单店特色菜）',
  `dish_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '菜品名称',
  `price` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '售价',
  `member_price` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '会员价',
  `is_recommend` tinyint NOT NULL DEFAULT 0 COMMENT '是否推荐（1-是；0-否）',
  `is_temporary` tinyint NOT NULL DEFAULT 0 COMMENT '是否临时菜品（1-是；0-否）',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '菜品描述（用料/做法）',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '菜品图片URL',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态（1-在售；0-下架）',
  `cooking_time` int NOT NULL DEFAULT 0 COMMENT '预估制作时间（分钟）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `kitchen_id` int NOT NULL COMMENT '制作厨房',
  PRIMARY KEY (`dish_id`) USING BTREE,
  INDEX `idx_dish_category`(`category_id` ASC) USING BTREE,
  INDEX `idx_dish_name`(`dish_name` ASC) USING BTREE,
  INDEX `idx_dish_status`(`status` ASC) USING BTREE,
  INDEX `idx_dish_recommend`(`is_recommend` ASC) USING BTREE,
  INDEX `idx_dish_temporary`(`is_temporary` ASC) USING BTREE,
  CONSTRAINT `fk_dish_category` FOREIGN KEY (`category_id`) REFERENCES `sys_dish_category` (`category_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dish
-- ----------------------------
INSERT INTO `sys_dish` VALUES (2, 2, NULL, '烧鸭', 45.00, 45.00, 1, 0, '招牌特色菜', 'https://localhost:7092/20250816/a8e35a05-72e4-459e-9cf7-35c37c0289a2.png', 1, 60, '2025-08-16 14:09:20', '2025-08-16 14:09:20', 0);
INSERT INTO `sys_dish` VALUES (3, 1, 2, '油麦菜', 15.00, 10.00, 1, 1, '季节菜', 'https://localhost:7092/20250816/b4f5b2bb-e207-44fc-a2b1-835f8c0958d2.jpg', 1, 0, '2025-08-16 14:13:30', '2025-08-16 14:13:30', 0);

-- ----------------------------
-- Table structure for sys_dish_category
-- ----------------------------
DROP TABLE IF EXISTS `sys_dish_category`;
CREATE TABLE `sys_dish_category`  (
  `category_id` bigint NOT NULL AUTO_INCREMENT COMMENT '分类ID（主键）',
  `store_id` bigint NULL DEFAULT NULL COMMENT '所属门店ID（支持单店特色分类）',
  `category_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分类名称',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序序号（小在前）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态（1-启用；0-禁用）',
  PRIMARY KEY (`category_id`) USING BTREE,
  INDEX `idx_category_store`(`store_id` ASC) USING BTREE,
  CONSTRAINT `fk_category_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品分类表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dish_category
-- ----------------------------
INSERT INTO `sys_dish_category` VALUES (1, 2, '凉菜', 1, 1);
INSERT INTO `sys_dish_category` VALUES (2, NULL, '热菜', 2, 1);

-- ----------------------------
-- Table structure for sys_dish_formula
-- ----------------------------
DROP TABLE IF EXISTS `sys_dish_formula`;
CREATE TABLE `sys_dish_formula`  (
  `formula_id` bigint NOT NULL AUTO_INCREMENT COMMENT '配方ID（主键）',
  `dish_id` bigint NOT NULL COMMENT '菜品ID',
  `spec_id` bigint NULL DEFAULT NULL COMMENT '规格ID（可空，不同规格消耗不同）',
  `material_id` bigint NOT NULL COMMENT '原材料ID',
  `consumption` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '消耗数量（如\"200g\"）',
  `loss_rate` decimal(5, 2) NOT NULL DEFAULT 0.00 COMMENT '损耗率（如0.05=5%）',
  PRIMARY KEY (`formula_id`) USING BTREE,
  INDEX `idx_formula_dish`(`dish_id` ASC) USING BTREE,
  INDEX `idx_formula_material`(`material_id` ASC) USING BTREE,
  INDEX `fk_formula_spec`(`spec_id` ASC) USING BTREE,
  CONSTRAINT `fk_formula_dish` FOREIGN KEY (`dish_id`) REFERENCES `sys_dish` (`dish_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_formula_material` FOREIGN KEY (`material_id`) REFERENCES `sys_raw_material` (`material_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_formula_spec` FOREIGN KEY (`spec_id`) REFERENCES `sys_dish_spec` (`spec_id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品配方表（原材料消耗规则）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dish_formula
-- ----------------------------

-- ----------------------------
-- Table structure for sys_dish_spec
-- ----------------------------
DROP TABLE IF EXISTS `sys_dish_spec`;
CREATE TABLE `sys_dish_spec`  (
  `spec_id` bigint NOT NULL AUTO_INCREMENT COMMENT '规格ID（主键）',
  `dish_id` bigint NOT NULL COMMENT '所属菜品ID',
  `spec_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '规格名称（如\"大份/中份/小份\"）',
  `spec_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '规格类型（分量/辣度/做法）',
  `price_diff` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '价格',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序序号',
  PRIMARY KEY (`spec_id`) USING BTREE,
  INDEX `idx_spec_dish`(`dish_id` ASC) USING BTREE,
  CONSTRAINT `fk_spec_dish` FOREIGN KEY (`dish_id`) REFERENCES `sys_dish` (`dish_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品规格表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dish_spec
-- ----------------------------
INSERT INTO `sys_dish_spec` VALUES (1, 2, '小份', '分量', 30.00, 1);
INSERT INTO `sys_dish_spec` VALUES (2, 2, '中份', '分量', 50.00, 2);

-- ----------------------------
-- Table structure for sys_inventory
-- ----------------------------
DROP TABLE IF EXISTS `sys_inventory`;
CREATE TABLE `sys_inventory`  (
  `inventory_id` bigint NOT NULL AUTO_INCREMENT COMMENT '库存ID（主键）',
  `store_id` bigint NOT NULL COMMENT '门店ID',
  `material_id` bigint NOT NULL COMMENT '原材料ID',
  `batch_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '批次号',
  `quantity` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '当前库存数量',
  `in_quantity` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '入库数量',
  `out_quantity` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '出库数量',
  `purchase_time` datetime NOT NULL COMMENT '采购日期',
  `expiry_date` datetime NOT NULL COMMENT '保质期到期日',
  `supplier_id` bigint NOT NULL COMMENT '供应商ID',
  `lock_quantity` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '锁定数量（已下单未出库）',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  PRIMARY KEY (`inventory_id`) USING BTREE,
  INDEX `idx_inventory_store`(`store_id` ASC) USING BTREE,
  INDEX `idx_inventory_material`(`material_id` ASC) USING BTREE,
  INDEX `idx_inventory_batch`(`batch_no` ASC) USING BTREE,
  INDEX `idx_inventory_purchase`(`purchase_time` ASC) USING BTREE,
  INDEX `idx_inventory_expiry`(`expiry_date` ASC) USING BTREE,
  INDEX `idx_inventory_supplier`(`supplier_id` ASC) USING BTREE,
  INDEX `idx_material_expiry`(`material_id` ASC, `expiry_date` ASC) USING BTREE,
  CONSTRAINT `fk_inventory_material` FOREIGN KEY (`material_id`) REFERENCES `sys_raw_material` (`material_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_inventory_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '库存表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_inventory
-- ----------------------------

-- ----------------------------
-- Table structure for sys_inventory_loss
-- ----------------------------
DROP TABLE IF EXISTS `sys_inventory_loss`;
CREATE TABLE `sys_inventory_loss`  (
  `loss_id` bigint NOT NULL AUTO_INCREMENT COMMENT '损耗ID（主键）',
  `store_id` bigint NOT NULL COMMENT '门店ID',
  `material_id` bigint NOT NULL COMMENT '原材料ID',
  `batch_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '批次号',
  `loss_quantity` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '损耗数量',
  `loss_type` tinyint NOT NULL COMMENT '类型（1-变质；2-加工损耗；3-其他）',
  `loss_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '损耗原因',
  `loss_time` datetime NOT NULL COMMENT '登记时间',
  `operator_id` bigint NOT NULL COMMENT '操作员工ID',
  PRIMARY KEY (`loss_id`) USING BTREE,
  INDEX `idx_loss_store`(`store_id` ASC) USING BTREE,
  INDEX `idx_loss_material`(`material_id` ASC) USING BTREE,
  INDEX `idx_loss_batch`(`batch_no` ASC) USING BTREE,
  INDEX `idx_loss_type`(`loss_type` ASC) USING BTREE,
  INDEX `idx_loss_time`(`loss_time` ASC) USING BTREE,
  CONSTRAINT `fk_loss_material` FOREIGN KEY (`material_id`) REFERENCES `sys_raw_material` (`material_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_loss_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '库存损耗表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_inventory_loss
-- ----------------------------

-- ----------------------------
-- Table structure for sys_kitchen
-- ----------------------------
DROP TABLE IF EXISTS `sys_kitchen`;
CREATE TABLE `sys_kitchen`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `kitchen_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '厨房名称',
  `kitchen_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '厨房类型',
  `kitchen_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `store_id` bigint NULL DEFAULT NULL COMMENT '所属门店',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '厨房管理表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_kitchen
-- ----------------------------
INSERT INTO `sys_kitchen` VALUES (1, '热菜厨房', '热菜厨房', '111', 0);
INSERT INTO `sys_kitchen` VALUES (2, '凉菜厨房', '凉菜厨房', '', 0);
INSERT INTO `sys_kitchen` VALUES (3, '饮料厨房', '饮料厨房', '', 0);

-- ----------------------------
-- Table structure for sys_kitchen_order
-- ----------------------------
DROP TABLE IF EXISTS `sys_kitchen_order`;
CREATE TABLE `sys_kitchen_order`  (
  `kitchen_id` bigint NOT NULL AUTO_INCREMENT COMMENT '厨房订单ID（主键）',
  `item_id` bigint NOT NULL COMMENT '关联订单明细ID',
  `store_id` bigint NOT NULL COMMENT '门店ID',
  `table_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '桌台编号（冗余，方便打印）',
  `dish_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '菜品名称（冗余）',
  `spec_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '规格名称（冗余）',
  `quantity` int NOT NULL DEFAULT 1 COMMENT '数量',
  `cooking_require` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '烹饪要求',
  `kitchen_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '目标厨房（热菜/凉菜/饮品）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态（1-待制作；2-制作中；3-已完成；4-已取餐；5-已退菜）',
  `create_time` datetime NOT NULL COMMENT '派单时间',
  `finish_time` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `pick_time` datetime NULL DEFAULT NULL COMMENT '取餐时间',
  `overtime_warn` tinyint NOT NULL DEFAULT 0 COMMENT '超时预警（0-未预警；1-已预警）',
  `cook_id` bigint NULL DEFAULT NULL COMMENT '厨师ID（可空）',
  `picker_id` bigint NULL DEFAULT NULL COMMENT '取餐员ID（可空）',
  PRIMARY KEY (`kitchen_id`) USING BTREE,
  UNIQUE INDEX `uk_kitchen_item`(`item_id` ASC) USING BTREE,
  INDEX `idx_kitchen_store`(`store_id` ASC) USING BTREE,
  INDEX `idx_kitchen_type`(`kitchen_type` ASC) USING BTREE,
  INDEX `idx_kitchen_status`(`status` ASC) USING BTREE,
  INDEX `idx_kitchen_time`(`create_time` ASC) USING BTREE,
  INDEX `idx_kitchen_overtime`(`overtime_warn` ASC) USING BTREE,
  INDEX `idx_store_kitchen_status_time`(`store_id` ASC, `kitchen_type` ASC, `status` ASC, `create_time` ASC) USING BTREE,
  CONSTRAINT `fk_kitchen_item` FOREIGN KEY (`item_id`) REFERENCES `sys_order_item` (`item_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_kitchen_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '厨房订单表（KDS系统同步）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_kitchen_order
-- ----------------------------
INSERT INTO `sys_kitchen_order` VALUES (4, 4, 2, 'A01', '烧鸭', NULL, 1, NULL, '热菜', 1, '2025-08-19 14:29:03', NULL, NULL, 0, NULL, NULL);
INSERT INTO `sys_kitchen_order` VALUES (6, 6, 2, 'A01', '油麦菜', NULL, 1, NULL, '热菜', 1, '2025-08-19 15:21:18', NULL, NULL, 0, NULL, NULL);

-- ----------------------------
-- Table structure for sys_member
-- ----------------------------
DROP TABLE IF EXISTS `sys_member`;
CREATE TABLE `sys_member`  (
  `member_id` bigint NOT NULL AUTO_INCREMENT COMMENT '会员ID（主键）',
  `member_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '会员编号',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '手机号（登录账号）',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '姓名',
  `birthday` date NULL DEFAULT NULL COMMENT '生日',
  `register_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态（1-正常；0-冻结）',
  `total_points` int NOT NULL DEFAULT 0 COMMENT '总积分',
  `referrer_id` bigint NULL DEFAULT NULL COMMENT '推荐人会员ID（老带新用）',
  `balance` decimal(10, 2) NULL DEFAULT NULL,
  PRIMARY KEY (`member_id`) USING BTREE,
  UNIQUE INDEX `uk_member_no`(`member_no` ASC) USING BTREE,
  UNIQUE INDEX `uk_member_phone`(`phone` ASC) USING BTREE,
  INDEX `idx_member_status`(`status` ASC) USING BTREE,
  INDEX `idx_member_register`(`register_time` ASC) USING BTREE,
  INDEX `idx_member_birthday`(`birthday` ASC) USING BTREE,
  INDEX `idx_member_referrer`(`referrer_id` ASC) USING BTREE,
  CONSTRAINT `fk_member_referrer` FOREIGN KEY (`referrer_id`) REFERENCES `sys_member` (`member_id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会员表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_member
-- ----------------------------
INSERT INTO `sys_member` VALUES (1, '202508301047284391139', '15235060638', '张科国', '2025-08-18', '2025-08-30 10:47:27', 1, 0, NULL, NULL);

-- ----------------------------
-- Table structure for sys_member_balance
-- ----------------------------
DROP TABLE IF EXISTS `sys_member_balance`;
CREATE TABLE `sys_member_balance`  (
  `balance_id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID（主键）',
  `member_id` bigint NOT NULL COMMENT '会员ID',
  `balance` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '当前余额',
  `recharge_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '充值金额',
  `give_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '赠送金额（如充500送100）',
  `recharge_time` datetime NOT NULL COMMENT '充值时间',
  `payment_id` bigint NOT NULL COMMENT '关联支付记录ID',
  `operator_id` bigint NOT NULL COMMENT '操作员工ID',
  PRIMARY KEY (`balance_id`) USING BTREE,
  INDEX `idx_balance_member`(`member_id` ASC) USING BTREE,
  INDEX `idx_balance_time`(`recharge_time` ASC) USING BTREE,
  INDEX `fk_balance_payment`(`payment_id` ASC) USING BTREE,
  CONSTRAINT `fk_balance_member` FOREIGN KEY (`member_id`) REFERENCES `sys_member` (`member_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_balance_payment` FOREIGN KEY (`payment_id`) REFERENCES `sys_payment` (`payment_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会员储值记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_member_balance
-- ----------------------------

-- ----------------------------
-- Table structure for sys_operationlog
-- ----------------------------
DROP TABLE IF EXISTS `sys_operationlog`;
CREATE TABLE `sys_operationlog`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `UserId` int NOT NULL COMMENT '操作人',
  `ActionType` int NOT NULL COMMENT '操作类型',
  `ModuleName` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '模块名称',
  `Description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作描述',
  `ActionTime` datetime NOT NULL COMMENT '操作时间',
  `ActionContent` varchar(5000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作内容',
  `OrgId` int NOT NULL COMMENT '服务器Id',
  `AddUserId` int NOT NULL COMMENT '创建人',
  `AddTime` datetime NOT NULL COMMENT '创建时间',
  `UpUserId` int NOT NULL COMMENT '更新人',
  `UpTime` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `index`(`UserId` ASC, `ActionType` ASC, `ModuleName` ASC, `OrgId` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1565 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统操作日志' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_operationlog
-- ----------------------------
INSERT INTO `sys_operationlog` VALUES (1, 0, 3, '系统设置>员工管理', '用户分页查询', '2025-08-11 11:32:17', '{\"User\":{\"staff_id\":0,\"store_id\":0,\"username\":\"admin\",\"password\":\"123456\",\"Salt\":\"string\",\"name\":\"管理员\",\"phone\":\"18433646699\",\"position\":\"管理员\",\"status\":0,\"IsDelete\":0,\"last_login_time\":\"2025-08-11T03:27:06.698Z\",\"staff_role\":{\"id\":0,\"staff_id\":0,\"role_id\":0,\"role\":{\"role_id\":0,\"role_name\":\"string\",\"description\":\"string\"}}}}', 0, 0, '2025-08-11 11:32:17', 0, '2025-08-11 11:32:17');
INSERT INTO `sys_operationlog` VALUES (2, 0, 3, '系统设置>员工管理', '用户分页查询', '2025-08-11 11:33:17', '{\"User\":{\"staff_id\":0,\"store_id\":0,\"username\":\"admin\",\"password\":\"123456\",\"Salt\":\"string\",\"name\":\"管理员\",\"phone\":\"18433646699\",\"position\":\"管理员\",\"status\":0,\"IsDelete\":0,\"last_login_time\":\"2025-08-11T03:27:06.698Z\",\"staff_role\":{\"id\":0,\"staff_id\":0,\"role_id\":0,\"role\":{\"role_id\":0,\"role_name\":\"string\",\"description\":\"string\"}}}}', 0, 0, '2025-08-11 11:33:17', 0, '2025-08-11 11:33:17');
INSERT INTO `sys_operationlog` VALUES (3, 0, 3, '系统设置>员工管理', '用户分页查询', '2025-08-11 11:34:51', '{\"User\":{\"staff_id\":0,\"store_id\":0,\"username\":\"admin\",\"password\":\"123456\",\"Salt\":\"string\",\"name\":\"管理员\",\"phone\":\"18433646699\",\"position\":\"管理员\",\"status\":0,\"IsDelete\":0,\"last_login_time\":\"2025-08-11T03:27:06.698Z\",\"staff_role\":{\"id\":0,\"staff_id\":0,\"role_id\":0,\"role\":{\"role_id\":0,\"role_name\":\"string\",\"description\":\"string\"}}}}', 0, 0, '2025-08-11 11:34:51', 0, '2025-08-11 11:34:51');
INSERT INTO `sys_operationlog` VALUES (4, 0, 3, '系统设置>员工管理', '用户分页查询', '2025-08-11 11:36:18', '{\"User\":{\"staff_id\":0,\"store_id\":0,\"username\":\"admin\",\"password\":\"DjgxTG61rALaudD4iay5n85WyJjICkhcSA4/HsYo7N4=\",\"Salt\":\"UzTaMP8KpkPVa6X60TvXmA==\",\"name\":\"管理员\",\"phone\":\"18433646699\",\"position\":\"管理员\",\"status\":0,\"IsDelete\":1,\"last_login_time\":\"2025-08-11T03:27:06.698Z\",\"staff_role\":{\"id\":0,\"staff_id\":0,\"role_id\":0,\"role\":{\"role_id\":0,\"role_name\":\"string\",\"description\":\"string\"}}}}', 0, 0, '2025-08-11 11:36:18', 0, '2025-08-11 11:36:18');
INSERT INTO `sys_operationlog` VALUES (5, 0, 3, '系统设置>员工管理', '用户分页查询', '2025-08-11 11:38:10', '{\"User\":{\"staff_id\":0,\"store_id\":1,\"username\":\"admin\",\"password\":\"87yYyL/FpfaAog73mQWkrRaohR6RXvMgHoZLvgTkqrI=\",\"Salt\":\"fcaUL2ziMYrVznCMcKgaNQ==\",\"name\":\"管理员\",\"phone\":\"18433646699\",\"position\":\"管理员\",\"status\":0,\"IsDelete\":1,\"last_login_time\":\"2025-08-11T03:27:06.698Z\",\"staff_role\":{\"id\":0,\"staff_id\":0,\"role_id\":0,\"role\":{\"role_id\":0,\"role_name\":\"string\",\"description\":\"string\"}}}}', 0, 0, '2025-08-11 11:38:10', 0, '2025-08-11 11:38:10');
INSERT INTO `sys_operationlog` VALUES (6, 2, 10, '系统登陆', '人员登陆', '2025-08-11 11:50:35', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 11:50:35', 2, '2025-08-11 11:50:35');
INSERT INTO `sys_operationlog` VALUES (7, 2, 10, '系统登陆', '人员登陆', '2025-08-11 11:50:44', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 11:50:44', 2, '2025-08-11 11:50:44');
INSERT INTO `sys_operationlog` VALUES (8, 2, 10, '系统登陆', '人员登陆', '2025-08-11 11:51:33', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 11:51:33', 2, '2025-08-11 11:51:33');
INSERT INTO `sys_operationlog` VALUES (9, 2, 10, '系统登陆', '人员登陆', '2025-08-11 11:52:28', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 11:52:28', 2, '2025-08-11 11:52:28');
INSERT INTO `sys_operationlog` VALUES (10, 2, 10, '系统登陆', '人员登陆', '2025-08-11 11:53:10', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 11:53:10', 2, '2025-08-11 11:53:10');
INSERT INTO `sys_operationlog` VALUES (11, 2, 10, '系统登陆', '人员登陆', '2025-08-11 11:57:38', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 11:57:38', 2, '2025-08-11 11:57:38');
INSERT INTO `sys_operationlog` VALUES (12, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 13:59:40', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":0}', 1, 2, '2025-08-11 13:59:40', 2, '2025-08-11 13:59:40');
INSERT INTO `sys_operationlog` VALUES (13, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 13:59:46', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":0}', 1, 2, '2025-08-11 13:59:46', 2, '2025-08-11 13:59:46');
INSERT INTO `sys_operationlog` VALUES (14, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 13:59:51', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":0}', 1, 2, '2025-08-11 13:59:51', 2, '2025-08-11 13:59:51');
INSERT INTO `sys_operationlog` VALUES (15, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 13:59:55', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":0}', 1, 2, '2025-08-11 13:59:55', 2, '2025-08-11 13:59:55');
INSERT INTO `sys_operationlog` VALUES (16, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:01:14', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":0}', 1, 2, '2025-08-11 14:01:14', 2, '2025-08-11 14:01:14');
INSERT INTO `sys_operationlog` VALUES (17, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:01:57', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":0}', 1, 2, '2025-08-11 14:01:57', 2, '2025-08-11 14:01:57');
INSERT INTO `sys_operationlog` VALUES (18, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:04:02', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:04:02', 2, '2025-08-11 14:04:02');
INSERT INTO `sys_operationlog` VALUES (19, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:05:50', '{\"StoreName\":\"1\",\"phone\":\"10\",\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:05:50', 2, '2025-08-11 14:05:50');
INSERT INTO `sys_operationlog` VALUES (20, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:05:55', '{\"StoreName\":\"1\",\"phone\":\"10\",\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:05:55', 2, '2025-08-11 14:05:55');
INSERT INTO `sys_operationlog` VALUES (21, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:05:58', '{\"StoreName\":\"1\",\"phone\":\"10\",\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:05:58', 2, '2025-08-11 14:05:58');
INSERT INTO `sys_operationlog` VALUES (22, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:06:02', '{\"StoreName\":\"1\",\"phone\":\"10\",\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:06:02', 2, '2025-08-11 14:06:02');
INSERT INTO `sys_operationlog` VALUES (23, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:09:11', '{\"StoreName\":\"1\",\"phone\":\"10\",\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:09:11', 2, '2025-08-11 14:09:11');
INSERT INTO `sys_operationlog` VALUES (24, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:12:13', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:12:13', 2, '2025-08-11 14:12:13');
INSERT INTO `sys_operationlog` VALUES (25, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:12:43', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:12:43', 2, '2025-08-11 14:12:43');
INSERT INTO `sys_operationlog` VALUES (26, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:12:51', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:12:51', 2, '2025-08-11 14:12:51');
INSERT INTO `sys_operationlog` VALUES (27, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:13:03', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":50}', 1, 2, '2025-08-11 14:13:03', 2, '2025-08-11 14:13:03');
INSERT INTO `sys_operationlog` VALUES (28, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:13:07', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":50}', 1, 2, '2025-08-11 14:13:07', 2, '2025-08-11 14:13:07');
INSERT INTO `sys_operationlog` VALUES (29, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:13:08', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":50}', 1, 2, '2025-08-11 14:13:08', 2, '2025-08-11 14:13:08');
INSERT INTO `sys_operationlog` VALUES (30, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:13:08', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":50}', 1, 2, '2025-08-11 14:13:08', 2, '2025-08-11 14:13:08');
INSERT INTO `sys_operationlog` VALUES (31, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:13:09', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":50}', 1, 2, '2025-08-11 14:13:09', 2, '2025-08-11 14:13:09');
INSERT INTO `sys_operationlog` VALUES (32, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:13:45', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":50}', 1, 2, '2025-08-11 14:13:45', 2, '2025-08-11 14:13:45');
INSERT INTO `sys_operationlog` VALUES (33, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:14:29', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:14:29', 2, '2025-08-11 14:14:29');
INSERT INTO `sys_operationlog` VALUES (34, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:16:54', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:16:54', 2, '2025-08-11 14:16:54');
INSERT INTO `sys_operationlog` VALUES (35, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:17:32', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:17:32', 2, '2025-08-11 14:17:32');
INSERT INTO `sys_operationlog` VALUES (36, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:17:33', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:17:33', 2, '2025-08-11 14:17:33');
INSERT INTO `sys_operationlog` VALUES (37, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:17:38', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:17:38', 2, '2025-08-11 14:17:38');
INSERT INTO `sys_operationlog` VALUES (38, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:18:48', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:18:48', 2, '2025-08-11 14:18:48');
INSERT INTO `sys_operationlog` VALUES (39, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:19:00', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:19:00', 2, '2025-08-11 14:19:00');
INSERT INTO `sys_operationlog` VALUES (40, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:20:02', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:20:02', 2, '2025-08-11 14:20:02');
INSERT INTO `sys_operationlog` VALUES (41, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:20:14', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:20:14', 2, '2025-08-11 14:20:14');
INSERT INTO `sys_operationlog` VALUES (42, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:20:32', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:20:32', 2, '2025-08-11 14:20:32');
INSERT INTO `sys_operationlog` VALUES (43, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:21:07', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:21:07', 2, '2025-08-11 14:21:07');
INSERT INTO `sys_operationlog` VALUES (44, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:21:33', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:21:33', 2, '2025-08-11 14:21:33');
INSERT INTO `sys_operationlog` VALUES (45, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:22:22', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:22:22', 2, '2025-08-11 14:22:22');
INSERT INTO `sys_operationlog` VALUES (46, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:22:27', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:22:27', 2, '2025-08-11 14:22:27');
INSERT INTO `sys_operationlog` VALUES (47, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:23:56', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:23:56', 2, '2025-08-11 14:23:56');
INSERT INTO `sys_operationlog` VALUES (48, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:24:46', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:24:46', 2, '2025-08-11 14:24:46');
INSERT INTO `sys_operationlog` VALUES (49, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:25:27', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:25:27', 2, '2025-08-11 14:25:27');
INSERT INTO `sys_operationlog` VALUES (50, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:31:03', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:31:03', 2, '2025-08-11 14:31:03');
INSERT INTO `sys_operationlog` VALUES (51, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:32:55', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:32:55', 2, '2025-08-11 14:32:55');
INSERT INTO `sys_operationlog` VALUES (52, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:50:55', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:50:55', 2, '2025-08-11 14:50:55');
INSERT INTO `sys_operationlog` VALUES (53, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:51:10', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:51:10', 2, '2025-08-11 14:51:10');
INSERT INTO `sys_operationlog` VALUES (54, 2, 10, '系统登陆', '人员登陆', '2025-08-11 14:57:47', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 14:57:47', 2, '2025-08-11 14:57:47');
INSERT INTO `sys_operationlog` VALUES (55, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:58:08', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:58:08', 2, '2025-08-11 14:58:08');
INSERT INTO `sys_operationlog` VALUES (56, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:58:11', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:58:11', 2, '2025-08-11 14:58:11');
INSERT INTO `sys_operationlog` VALUES (57, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 14:59:41', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 14:59:41', 2, '2025-08-11 14:59:41');
INSERT INTO `sys_operationlog` VALUES (58, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:00:04', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:00:04', 2, '2025-08-11 15:00:04');
INSERT INTO `sys_operationlog` VALUES (59, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:00:16', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:00:16', 2, '2025-08-11 15:00:16');
INSERT INTO `sys_operationlog` VALUES (60, 2, 10, '系统登陆', '人员登陆', '2025-08-11 15:10:36', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 15:10:36', 2, '2025-08-11 15:10:36');
INSERT INTO `sys_operationlog` VALUES (61, 2, 10, '系统登陆', '人员登陆', '2025-08-11 15:10:57', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 15:10:57', 2, '2025-08-11 15:10:57');
INSERT INTO `sys_operationlog` VALUES (62, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:11:03', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:11:03', 2, '2025-08-11 15:11:03');
INSERT INTO `sys_operationlog` VALUES (63, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:12:04', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:12:04', 2, '2025-08-11 15:12:04');
INSERT INTO `sys_operationlog` VALUES (64, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:12:11', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:12:11', 2, '2025-08-11 15:12:11');
INSERT INTO `sys_operationlog` VALUES (65, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:12:12', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:12:12', 2, '2025-08-11 15:12:12');
INSERT INTO `sys_operationlog` VALUES (66, 2, 3, '系统设置>门店设置', '新增门店', '2025-08-11 15:18:36', '{\"sys_Store\":{\"store_id\":null,\"store_name\":\"门店一\",\"address\":\"333\",\"phone\":\"15235060638\",\"business_hours\":\"10:00-22:00\",\"total_tables\":20,\"status\":1,\"created_at\":\"0001-01-01T00:00:00\",\"updated_at\":\"0001-01-01T00:00:00\"}}', 1, 2, '2025-08-11 15:18:36', 2, '2025-08-11 15:18:36');
INSERT INTO `sys_operationlog` VALUES (67, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:18:36', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:18:36', 2, '2025-08-11 15:18:36');
INSERT INTO `sys_operationlog` VALUES (68, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:20:13', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:20:13', 2, '2025-08-11 15:20:13');
INSERT INTO `sys_operationlog` VALUES (69, 2, 1, '系统设置>门店设置', '修改门店信息', '2025-08-11 15:20:29', '{\"sys_Store\":{\"store_id\":2,\"store_name\":\"旗舰店\",\"address\":\"444\",\"phone\":\"111\",\"business_hours\":\"111\",\"total_tables\":20,\"status\":1,\"created_at\":\"0001-01-01T00:00:00\",\"updated_at\":\"0001-01-01T00:00:00\"}}', 1, 2, '2025-08-11 15:20:29', 2, '2025-08-11 15:20:29');
INSERT INTO `sys_operationlog` VALUES (70, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:20:29', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:20:29', 2, '2025-08-11 15:20:29');
INSERT INTO `sys_operationlog` VALUES (71, 2, 1, '系统设置>门店设置', '修改门店信息', '2025-08-11 15:20:45', '{\"sys_Store\":{\"store_id\":2,\"store_name\":\"旗舰店\",\"address\":\"2244\",\"phone\":\"111\",\"business_hours\":\"111\",\"total_tables\":20,\"status\":1,\"created_at\":\"0001-01-01T00:00:00\",\"updated_at\":\"0001-01-01T00:00:00\"}}', 1, 2, '2025-08-11 15:20:45', 2, '2025-08-11 15:20:45');
INSERT INTO `sys_operationlog` VALUES (72, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:20:45', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:20:45', 2, '2025-08-11 15:20:45');
INSERT INTO `sys_operationlog` VALUES (73, 2, 1, '系统设置>门店设置', '修改门店信息', '2025-08-11 15:21:45', '{\"sys_Store\":{\"store_id\":2,\"store_name\":\"旗舰店\",\"address\":\"2244\",\"phone\":\"111\",\"business_hours\":\"111\",\"total_tables\":20,\"status\":1,\"created_at\":\"2025-08-11T15:21:44.8905508+08:00\",\"updated_at\":\"2025-08-11T15:21:44.8905514+08:00\"}}', 1, 2, '2025-08-11 15:21:45', 2, '2025-08-11 15:21:45');
INSERT INTO `sys_operationlog` VALUES (74, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:21:45', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:21:45', 2, '2025-08-11 15:21:45');
INSERT INTO `sys_operationlog` VALUES (75, 2, 1, '系统设置>门店设置', '修改门店信息', '2025-08-11 15:21:48', '{\"sys_Store\":{\"store_id\":13,\"store_name\":\"门店一\",\"address\":\"333\",\"phone\":\"15235060638\",\"business_hours\":\"10:00-22:00\",\"total_tables\":20,\"status\":1,\"created_at\":\"2025-08-11T15:21:47.6599912+08:00\",\"updated_at\":\"2025-08-11T15:21:47.6599915+08:00\"}}', 1, 2, '2025-08-11 15:21:48', 2, '2025-08-11 15:21:48');
INSERT INTO `sys_operationlog` VALUES (76, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:21:48', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:21:48', 2, '2025-08-11 15:21:48');
INSERT INTO `sys_operationlog` VALUES (77, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:21:55', '{}', 1, 2, '2025-08-11 15:21:55', 2, '2025-08-11 15:21:55');
INSERT INTO `sys_operationlog` VALUES (78, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:21:58', '{}', 1, 2, '2025-08-11 15:21:58', 2, '2025-08-11 15:21:58');
INSERT INTO `sys_operationlog` VALUES (79, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:21:59', '{}', 1, 2, '2025-08-11 15:21:59', 2, '2025-08-11 15:21:59');
INSERT INTO `sys_operationlog` VALUES (80, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:22:33', '{}', 1, 2, '2025-08-11 15:22:33', 2, '2025-08-11 15:22:33');
INSERT INTO `sys_operationlog` VALUES (81, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:22:36', '{}', 1, 2, '2025-08-11 15:22:36', 2, '2025-08-11 15:22:36');
INSERT INTO `sys_operationlog` VALUES (82, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:23:23', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:23:23', 2, '2025-08-11 15:23:23');
INSERT INTO `sys_operationlog` VALUES (83, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:23:28', '{}', 1, 2, '2025-08-11 15:23:28', 2, '2025-08-11 15:23:28');
INSERT INTO `sys_operationlog` VALUES (84, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:23:30', '{}', 1, 2, '2025-08-11 15:23:30', 2, '2025-08-11 15:23:30');
INSERT INTO `sys_operationlog` VALUES (85, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:23:31', '{}', 1, 2, '2025-08-11 15:23:31', 2, '2025-08-11 15:23:31');
INSERT INTO `sys_operationlog` VALUES (86, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:23:39', '{}', 1, 2, '2025-08-11 15:23:39', 2, '2025-08-11 15:23:39');
INSERT INTO `sys_operationlog` VALUES (87, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:24:25', '{}', 1, 2, '2025-08-11 15:24:25', 2, '2025-08-11 15:24:25');
INSERT INTO `sys_operationlog` VALUES (88, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:24:25', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:24:25', 2, '2025-08-11 15:24:25');
INSERT INTO `sys_operationlog` VALUES (89, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:24:32', '{}', 1, 2, '2025-08-11 15:24:32', 2, '2025-08-11 15:24:32');
INSERT INTO `sys_operationlog` VALUES (90, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:25:09', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:25:09', 2, '2025-08-11 15:25:09');
INSERT INTO `sys_operationlog` VALUES (91, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:25:10', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:25:10', 2, '2025-08-11 15:25:10');
INSERT INTO `sys_operationlog` VALUES (92, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:25:14', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:25:14', 2, '2025-08-11 15:25:14');
INSERT INTO `sys_operationlog` VALUES (93, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:25:15', '{}', 1, 2, '2025-08-11 15:25:15', 2, '2025-08-11 15:25:15');
INSERT INTO `sys_operationlog` VALUES (94, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:25:49', '{}', 1, 2, '2025-08-11 15:25:49', 2, '2025-08-11 15:25:49');
INSERT INTO `sys_operationlog` VALUES (95, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:25:49', '{}', 1, 2, '2025-08-11 15:25:49', 2, '2025-08-11 15:25:49');
INSERT INTO `sys_operationlog` VALUES (96, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:26:01', '{}', 1, 2, '2025-08-11 15:26:01', 2, '2025-08-11 15:26:01');
INSERT INTO `sys_operationlog` VALUES (97, 2, 10, '系统登陆', '人员登陆', '2025-08-11 15:27:06', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 15:27:06', 2, '2025-08-11 15:27:06');
INSERT INTO `sys_operationlog` VALUES (98, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:27:12', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:27:12', 2, '2025-08-11 15:27:12');
INSERT INTO `sys_operationlog` VALUES (99, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:27:14', '{\"storeId\":2,\"status\":0}', 1, 2, '2025-08-11 15:27:14', 2, '2025-08-11 15:27:14');
INSERT INTO `sys_operationlog` VALUES (100, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:27:20', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:27:20', 2, '2025-08-11 15:27:20');
INSERT INTO `sys_operationlog` VALUES (101, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:27:36', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:27:36', 2, '2025-08-11 15:27:36');
INSERT INTO `sys_operationlog` VALUES (102, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:27:38', '{\"storeId\":2,\"status\":1}', 1, 2, '2025-08-11 15:27:38', 2, '2025-08-11 15:27:38');
INSERT INTO `sys_operationlog` VALUES (103, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:27:38', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:27:38', 2, '2025-08-11 15:27:38');
INSERT INTO `sys_operationlog` VALUES (104, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:27:39', '{\"storeId\":2,\"status\":0}', 1, 2, '2025-08-11 15:27:39', 2, '2025-08-11 15:27:39');
INSERT INTO `sys_operationlog` VALUES (105, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:27:39', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:27:39', 2, '2025-08-11 15:27:39');
INSERT INTO `sys_operationlog` VALUES (106, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:27:40', '{\"storeId\":2,\"status\":1}', 1, 2, '2025-08-11 15:27:40', 2, '2025-08-11 15:27:40');
INSERT INTO `sys_operationlog` VALUES (107, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:27:40', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:27:40', 2, '2025-08-11 15:27:40');
INSERT INTO `sys_operationlog` VALUES (108, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:27:40', '{\"storeId\":2,\"status\":0}', 1, 2, '2025-08-11 15:27:40', 2, '2025-08-11 15:27:40');
INSERT INTO `sys_operationlog` VALUES (109, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:27:40', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:27:40', 2, '2025-08-11 15:27:40');
INSERT INTO `sys_operationlog` VALUES (110, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:27:41', '{\"storeId\":2,\"status\":1}', 1, 2, '2025-08-11 15:27:41', 2, '2025-08-11 15:27:41');
INSERT INTO `sys_operationlog` VALUES (111, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:27:41', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:27:41', 2, '2025-08-11 15:27:41');
INSERT INTO `sys_operationlog` VALUES (112, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:27:41', '{\"storeId\":2,\"status\":0}', 1, 2, '2025-08-11 15:27:41', 2, '2025-08-11 15:27:41');
INSERT INTO `sys_operationlog` VALUES (113, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:27:41', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:27:41', 2, '2025-08-11 15:27:41');
INSERT INTO `sys_operationlog` VALUES (114, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 15:27:41', '{\"storeId\":2,\"status\":1}', 1, 2, '2025-08-11 15:27:41', 2, '2025-08-11 15:27:41');
INSERT INTO `sys_operationlog` VALUES (115, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:27:41', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:27:41', 2, '2025-08-11 15:27:41');
INSERT INTO `sys_operationlog` VALUES (116, 2, 3, '系统设置>门店设置', '新增门店', '2025-08-11 15:28:00', '{\"sys_Store\":{\"store_id\":null,\"store_name\":\"111\",\"address\":\"11\",\"phone\":\"111111111111\",\"business_hours\":\"11\",\"total_tables\":1,\"status\":1,\"created_at\":\"2025-08-11T15:27:53.7191228+08:00\",\"updated_at\":\"2025-08-11T15:27:53.7191233+08:00\"}}', 1, 2, '2025-08-11 15:28:00', 2, '2025-08-11 15:28:00');
INSERT INTO `sys_operationlog` VALUES (117, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:28:01', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:28:01', 2, '2025-08-11 15:28:01');
INSERT INTO `sys_operationlog` VALUES (118, 2, 3, '系统设置>门店设置', '新增门店', '2025-08-11 15:28:13', '{\"sys_Store\":{\"store_id\":null,\"store_name\":\"222\",\"address\":\"222\",\"phone\":\"222\",\"business_hours\":\"222\",\"total_tables\":222,\"status\":1,\"created_at\":\"2025-08-11T15:28:13.0430791+08:00\",\"updated_at\":\"2025-08-11T15:28:13.0430796+08:00\"}}', 1, 2, '2025-08-11 15:28:13', 2, '2025-08-11 15:28:13');
INSERT INTO `sys_operationlog` VALUES (119, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:28:13', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:28:13', 2, '2025-08-11 15:28:13');
INSERT INTO `sys_operationlog` VALUES (120, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:29:26', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:29:26', 2, '2025-08-11 15:29:26');
INSERT INTO `sys_operationlog` VALUES (121, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:30:13', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:30:13', 2, '2025-08-11 15:30:13');
INSERT INTO `sys_operationlog` VALUES (122, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:33:22', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:33:22', 2, '2025-08-11 15:33:22');
INSERT INTO `sys_operationlog` VALUES (123, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:33:23', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:33:23', 2, '2025-08-11 15:33:23');
INSERT INTO `sys_operationlog` VALUES (124, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:34:46', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:34:46', 2, '2025-08-11 15:34:46');
INSERT INTO `sys_operationlog` VALUES (125, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:34:49', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:34:49', 2, '2025-08-11 15:34:49');
INSERT INTO `sys_operationlog` VALUES (126, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:34:54', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:34:54', 2, '2025-08-11 15:34:54');
INSERT INTO `sys_operationlog` VALUES (127, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:34:58', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:34:58', 2, '2025-08-11 15:34:58');
INSERT INTO `sys_operationlog` VALUES (128, 2, 2, '系统设置>门店设置', '删除门店', '2025-08-11 15:35:06', '{\"storeIds\":[15]}', 1, 2, '2025-08-11 15:35:06', 2, '2025-08-11 15:35:06');
INSERT INTO `sys_operationlog` VALUES (129, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:35:06', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:35:06', 2, '2025-08-11 15:35:06');
INSERT INTO `sys_operationlog` VALUES (130, 2, 2, '系统设置>门店设置', '删除门店', '2025-08-11 15:35:17', '{\"storeIds\":[13,14]}', 1, 2, '2025-08-11 15:35:17', 2, '2025-08-11 15:35:17');
INSERT INTO `sys_operationlog` VALUES (131, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 15:35:17', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 15:35:17', 2, '2025-08-11 15:35:17');
INSERT INTO `sys_operationlog` VALUES (132, 2, 10, '系统登陆', '人员登陆', '2025-08-11 16:01:34', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 16:01:34', 2, '2025-08-11 16:01:34');
INSERT INTO `sys_operationlog` VALUES (133, 2, 10, '系统登陆', '人员登陆', '2025-08-11 16:02:43', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 16:02:43', 2, '2025-08-11 16:02:43');
INSERT INTO `sys_operationlog` VALUES (134, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:02:50', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:02:50', 2, '2025-08-11 16:02:50');
INSERT INTO `sys_operationlog` VALUES (135, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:02:58', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:02:58', 2, '2025-08-11 16:02:58');
INSERT INTO `sys_operationlog` VALUES (136, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:03:15', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:03:15', 2, '2025-08-11 16:03:15');
INSERT INTO `sys_operationlog` VALUES (137, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:03:23', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:03:23', 2, '2025-08-11 16:03:23');
INSERT INTO `sys_operationlog` VALUES (138, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:03:29', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:03:29', 2, '2025-08-11 16:03:29');
INSERT INTO `sys_operationlog` VALUES (139, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:04:51', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:04:51', 2, '2025-08-11 16:04:51');
INSERT INTO `sys_operationlog` VALUES (140, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:04:56', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:04:56', 2, '2025-08-11 16:04:56');
INSERT INTO `sys_operationlog` VALUES (141, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:05:17', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:05:17', 2, '2025-08-11 16:05:17');
INSERT INTO `sys_operationlog` VALUES (142, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:06:02', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:06:02', 2, '2025-08-11 16:06:02');
INSERT INTO `sys_operationlog` VALUES (143, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:06:41', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:06:41', 2, '2025-08-11 16:06:41');
INSERT INTO `sys_operationlog` VALUES (144, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:07:12', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:07:12', 2, '2025-08-11 16:07:12');
INSERT INTO `sys_operationlog` VALUES (145, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:07:52', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:07:52', 2, '2025-08-11 16:07:52');
INSERT INTO `sys_operationlog` VALUES (146, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:08:07', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:08:07', 2, '2025-08-11 16:08:07');
INSERT INTO `sys_operationlog` VALUES (147, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:08:32', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:08:32', 2, '2025-08-11 16:08:32');
INSERT INTO `sys_operationlog` VALUES (148, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:09:27', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:09:27', 2, '2025-08-11 16:09:27');
INSERT INTO `sys_operationlog` VALUES (149, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:10:15', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:10:15', 2, '2025-08-11 16:10:15');
INSERT INTO `sys_operationlog` VALUES (150, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:11:06', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:11:06', 2, '2025-08-11 16:11:06');
INSERT INTO `sys_operationlog` VALUES (151, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:11:48', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:11:48', 2, '2025-08-11 16:11:48');
INSERT INTO `sys_operationlog` VALUES (152, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:13:43', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:13:43', 2, '2025-08-11 16:13:43');
INSERT INTO `sys_operationlog` VALUES (153, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:14:49', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:14:49', 2, '2025-08-11 16:14:49');
INSERT INTO `sys_operationlog` VALUES (154, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:16:34', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:16:34', 2, '2025-08-11 16:16:34');
INSERT INTO `sys_operationlog` VALUES (155, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:17:10', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:17:10', 2, '2025-08-11 16:17:10');
INSERT INTO `sys_operationlog` VALUES (156, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:23:04', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:23:04', 2, '2025-08-11 16:23:04');
INSERT INTO `sys_operationlog` VALUES (157, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:23:48', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:23:48', 2, '2025-08-11 16:23:48');
INSERT INTO `sys_operationlog` VALUES (158, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:24:11', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:24:11', 2, '2025-08-11 16:24:11');
INSERT INTO `sys_operationlog` VALUES (159, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:24:20', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:24:20', 2, '2025-08-11 16:24:20');
INSERT INTO `sys_operationlog` VALUES (160, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:25:00', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:25:00', 2, '2025-08-11 16:25:00');
INSERT INTO `sys_operationlog` VALUES (161, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:27:39', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:27:39', 2, '2025-08-11 16:27:39');
INSERT INTO `sys_operationlog` VALUES (162, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:29:04', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:29:04', 2, '2025-08-11 16:29:04');
INSERT INTO `sys_operationlog` VALUES (163, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:29:21', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:29:21', 2, '2025-08-11 16:29:21');
INSERT INTO `sys_operationlog` VALUES (164, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:29:29', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:29:29', 2, '2025-08-11 16:29:29');
INSERT INTO `sys_operationlog` VALUES (165, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:30:56', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:30:56', 2, '2025-08-11 16:30:56');
INSERT INTO `sys_operationlog` VALUES (166, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:31:37', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:31:37', 2, '2025-08-11 16:31:37');
INSERT INTO `sys_operationlog` VALUES (167, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:31:50', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:31:50', 2, '2025-08-11 16:31:50');
INSERT INTO `sys_operationlog` VALUES (168, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:31:57', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:31:57', 2, '2025-08-11 16:31:57');
INSERT INTO `sys_operationlog` VALUES (169, 2, 10, '系统登陆', '人员登陆', '2025-08-11 16:38:37', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 16:38:37', 2, '2025-08-11 16:38:37');
INSERT INTO `sys_operationlog` VALUES (170, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:38:44', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:38:44', 2, '2025-08-11 16:38:44');
INSERT INTO `sys_operationlog` VALUES (171, 2, 10, '系统登陆', '人员登陆', '2025-08-11 16:56:56', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 16:56:56', 2, '2025-08-11 16:56:56');
INSERT INTO `sys_operationlog` VALUES (172, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 16:57:03', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:57:03', 2, '2025-08-11 16:57:03');
INSERT INTO `sys_operationlog` VALUES (173, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 16:57:05', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 16:57:05', 2, '2025-08-11 16:57:05');
INSERT INTO `sys_operationlog` VALUES (174, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:05:51', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:05:51', 2, '2025-08-11 17:05:51');
INSERT INTO `sys_operationlog` VALUES (175, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:06:32', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:06:32', 2, '2025-08-11 17:06:32');
INSERT INTO `sys_operationlog` VALUES (176, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:07:00', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:07:00', 2, '2025-08-11 17:07:00');
INSERT INTO `sys_operationlog` VALUES (177, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:07:40', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:07:40', 2, '2025-08-11 17:07:40');
INSERT INTO `sys_operationlog` VALUES (178, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:10:05', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:10:05', 2, '2025-08-11 17:10:05');
INSERT INTO `sys_operationlog` VALUES (179, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:10:40', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:10:40', 2, '2025-08-11 17:10:40');
INSERT INTO `sys_operationlog` VALUES (180, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:12:12', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:12:12', 2, '2025-08-11 17:12:12');
INSERT INTO `sys_operationlog` VALUES (181, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:12:50', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:12:50', 2, '2025-08-11 17:12:50');
INSERT INTO `sys_operationlog` VALUES (182, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:13:04', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:13:04', 2, '2025-08-11 17:13:04');
INSERT INTO `sys_operationlog` VALUES (183, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-11 17:13:51', '{\"roleId\":1,\"permissionIds\":[]}', 1, 2, '2025-08-11 17:13:51', 2, '2025-08-11 17:13:51');
INSERT INTO `sys_operationlog` VALUES (184, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:14:31', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:14:31', 2, '2025-08-11 17:14:31');
INSERT INTO `sys_operationlog` VALUES (185, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:15:34', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:15:34', 2, '2025-08-11 17:15:34');
INSERT INTO `sys_operationlog` VALUES (186, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:15:56', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:15:56', 2, '2025-08-11 17:15:56');
INSERT INTO `sys_operationlog` VALUES (187, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:16:20', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:16:20', 2, '2025-08-11 17:16:20');
INSERT INTO `sys_operationlog` VALUES (188, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:16:29', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:16:29', 2, '2025-08-11 17:16:29');
INSERT INTO `sys_operationlog` VALUES (189, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:18:49', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:18:49', 2, '2025-08-11 17:18:49');
INSERT INTO `sys_operationlog` VALUES (190, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-11 17:19:06', '{\"roleId\":1,\"permissionIds\":[1,13]}', 1, 2, '2025-08-11 17:19:06', 2, '2025-08-11 17:19:06');
INSERT INTO `sys_operationlog` VALUES (191, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:19:23', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:19:23', 2, '2025-08-11 17:19:23');
INSERT INTO `sys_operationlog` VALUES (192, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:19:29', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:19:29', 2, '2025-08-11 17:19:29');
INSERT INTO `sys_operationlog` VALUES (193, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:22:15', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:22:15', 2, '2025-08-11 17:22:15');
INSERT INTO `sys_operationlog` VALUES (194, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-11 17:22:36', '{\"roleId\":1,\"permissionIds\":[1,13,2,14,15,16,3,18,19,4,20,21,22,23,5,24,25,26,27,6,28,29,7,30,31,32,33,8,34,35,36,37,9,38,39,40,10,41,42,43,11,44,45,46,47,12,48,49,50,51]}', 1, 2, '2025-08-11 17:22:36', 2, '2025-08-11 17:22:36');
INSERT INTO `sys_operationlog` VALUES (195, 2, 1, '系统设置>角色管理', '修改角色', '2025-08-11 17:23:03', '{\"sys_Role\":{\"role_id\":1,\"role_name\":\"管理员1\",\"description\":\"管理所有功能\"}}', 1, 2, '2025-08-11 17:23:03', 2, '2025-08-11 17:23:03');
INSERT INTO `sys_operationlog` VALUES (196, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:23:03', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:23:03', 2, '2025-08-11 17:23:03');
INSERT INTO `sys_operationlog` VALUES (197, 2, 1, '系统设置>角色管理', '修改角色', '2025-08-11 17:23:09', '{\"sys_Role\":{\"role_id\":1,\"role_name\":\"管理员\",\"description\":\"管理所有功能\"}}', 1, 2, '2025-08-11 17:23:09', 2, '2025-08-11 17:23:09');
INSERT INTO `sys_operationlog` VALUES (198, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:23:09', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:23:09', 2, '2025-08-11 17:23:09');
INSERT INTO `sys_operationlog` VALUES (199, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:23:20', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:23:20', 2, '2025-08-11 17:23:20');
INSERT INTO `sys_operationlog` VALUES (200, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:23:24', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:23:24', 2, '2025-08-11 17:23:24');
INSERT INTO `sys_operationlog` VALUES (201, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:26:21', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:26:21', 2, '2025-08-11 17:26:21');
INSERT INTO `sys_operationlog` VALUES (202, 2, 3, '系统设置>角色管理', '新增角色', '2025-08-11 17:26:31', '{\"sys_Role\":{\"role_id\":2,\"role_name\":\"111\",\"description\":\"111\"}}', 1, 2, '2025-08-11 17:26:31', 2, '2025-08-11 17:26:31');
INSERT INTO `sys_operationlog` VALUES (203, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:26:31', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:26:31', 2, '2025-08-11 17:26:31');
INSERT INTO `sys_operationlog` VALUES (204, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 17:28:11', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 17:28:11', 2, '2025-08-11 17:28:11');
INSERT INTO `sys_operationlog` VALUES (205, 2, 10, '系统登陆', '人员登陆', '2025-08-11 20:05:03', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 20:05:03', 2, '2025-08-11 20:05:03');
INSERT INTO `sys_operationlog` VALUES (206, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:05:17', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:05:17', 2, '2025-08-11 20:05:17');
INSERT INTO `sys_operationlog` VALUES (207, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:05:27', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:05:27', 2, '2025-08-11 20:05:27');
INSERT INTO `sys_operationlog` VALUES (208, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:05:31', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:05:31', 2, '2025-08-11 20:05:31');
INSERT INTO `sys_operationlog` VALUES (209, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:05:32', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:05:32', 2, '2025-08-11 20:05:32');
INSERT INTO `sys_operationlog` VALUES (210, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:05:36', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:05:36', 2, '2025-08-11 20:05:36');
INSERT INTO `sys_operationlog` VALUES (211, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:05:40', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:05:40', 2, '2025-08-11 20:05:40');
INSERT INTO `sys_operationlog` VALUES (212, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:05:45', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:05:45', 2, '2025-08-11 20:05:45');
INSERT INTO `sys_operationlog` VALUES (213, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:06:40', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:06:40', 2, '2025-08-11 20:06:40');
INSERT INTO `sys_operationlog` VALUES (214, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:07:13', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:07:13', 2, '2025-08-11 20:07:13');
INSERT INTO `sys_operationlog` VALUES (215, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:07:16', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:07:16', 2, '2025-08-11 20:07:16');
INSERT INTO `sys_operationlog` VALUES (216, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:07:17', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:07:17', 2, '2025-08-11 20:07:17');
INSERT INTO `sys_operationlog` VALUES (217, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:07:19', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:07:19', 2, '2025-08-11 20:07:19');
INSERT INTO `sys_operationlog` VALUES (218, 2, 1, '系统设置>角色管理', '修改角色', '2025-08-11 20:07:39', '{\"sys_Role\":{\"role_id\":2,\"role_name\":\"3333\",\"description\":\"111\"}}', 1, 2, '2025-08-11 20:07:39', 2, '2025-08-11 20:07:39');
INSERT INTO `sys_operationlog` VALUES (219, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:07:39', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:07:39', 2, '2025-08-11 20:07:39');
INSERT INTO `sys_operationlog` VALUES (220, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:08:20', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:08:20', 2, '2025-08-11 20:08:20');
INSERT INTO `sys_operationlog` VALUES (221, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:08:21', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:08:21', 2, '2025-08-11 20:08:21');
INSERT INTO `sys_operationlog` VALUES (222, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:08:22', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:08:22', 2, '2025-08-11 20:08:22');
INSERT INTO `sys_operationlog` VALUES (223, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:10:07', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:10:07', 2, '2025-08-11 20:10:07');
INSERT INTO `sys_operationlog` VALUES (224, 2, 2, '系统设置>角色管理', '删除角色', '2025-08-11 20:10:13', '{\"roleId\":2}', 1, 2, '2025-08-11 20:10:13', 2, '2025-08-11 20:10:13');
INSERT INTO `sys_operationlog` VALUES (225, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:10:13', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:10:13', 2, '2025-08-11 20:10:13');
INSERT INTO `sys_operationlog` VALUES (226, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:10:48', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:10:48', 2, '2025-08-11 20:10:48');
INSERT INTO `sys_operationlog` VALUES (227, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:12:28', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:12:28', 2, '2025-08-11 20:12:28');
INSERT INTO `sys_operationlog` VALUES (228, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:12:32', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":50}', 1, 2, '2025-08-11 20:12:32', 2, '2025-08-11 20:12:32');
INSERT INTO `sys_operationlog` VALUES (229, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:12:37', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:12:37', 2, '2025-08-11 20:12:37');
INSERT INTO `sys_operationlog` VALUES (230, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:13:35', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:13:35', 2, '2025-08-11 20:13:35');
INSERT INTO `sys_operationlog` VALUES (231, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:14:02', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:14:02', 2, '2025-08-11 20:14:02');
INSERT INTO `sys_operationlog` VALUES (232, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:14:03', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:14:03', 2, '2025-08-11 20:14:03');
INSERT INTO `sys_operationlog` VALUES (233, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:14:06', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:14:06', 2, '2025-08-11 20:14:06');
INSERT INTO `sys_operationlog` VALUES (234, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:14:09', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:14:09', 2, '2025-08-11 20:14:09');
INSERT INTO `sys_operationlog` VALUES (235, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:16:21', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:16:21', 2, '2025-08-11 20:16:21');
INSERT INTO `sys_operationlog` VALUES (236, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:18:19', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:18:19', 2, '2025-08-11 20:18:19');
INSERT INTO `sys_operationlog` VALUES (237, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:23:02', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:23:02', 2, '2025-08-11 20:23:02');
INSERT INTO `sys_operationlog` VALUES (238, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:24:10', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:24:10', 2, '2025-08-11 20:24:10');
INSERT INTO `sys_operationlog` VALUES (239, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:24:12', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:24:12', 2, '2025-08-11 20:24:12');
INSERT INTO `sys_operationlog` VALUES (240, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:24:12', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:24:12', 2, '2025-08-11 20:24:12');
INSERT INTO `sys_operationlog` VALUES (241, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:24:13', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:24:13', 2, '2025-08-11 20:24:13');
INSERT INTO `sys_operationlog` VALUES (242, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:25:28', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:25:28', 2, '2025-08-11 20:25:28');
INSERT INTO `sys_operationlog` VALUES (243, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:27:31', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:27:31', 2, '2025-08-11 20:27:31');
INSERT INTO `sys_operationlog` VALUES (244, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:27:32', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:27:32', 2, '2025-08-11 20:27:32');
INSERT INTO `sys_operationlog` VALUES (245, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:27:33', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:27:33', 2, '2025-08-11 20:27:33');
INSERT INTO `sys_operationlog` VALUES (246, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:29:59', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:29:59', 2, '2025-08-11 20:29:59');
INSERT INTO `sys_operationlog` VALUES (247, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:30:54', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:30:54', 2, '2025-08-11 20:30:54');
INSERT INTO `sys_operationlog` VALUES (248, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:30:57', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:30:57', 2, '2025-08-11 20:30:57');
INSERT INTO `sys_operationlog` VALUES (249, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:31:02', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:31:02', 2, '2025-08-11 20:31:02');
INSERT INTO `sys_operationlog` VALUES (250, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:31:35', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:31:35', 2, '2025-08-11 20:31:35');
INSERT INTO `sys_operationlog` VALUES (251, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:31:36', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:31:36', 2, '2025-08-11 20:31:36');
INSERT INTO `sys_operationlog` VALUES (252, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:34:48', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:34:48', 2, '2025-08-11 20:34:48');
INSERT INTO `sys_operationlog` VALUES (253, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:34:51', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:34:51', 2, '2025-08-11 20:34:51');
INSERT INTO `sys_operationlog` VALUES (254, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:34:56', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:34:56', 2, '2025-08-11 20:34:56');
INSERT INTO `sys_operationlog` VALUES (255, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:35:00', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:35:00', 2, '2025-08-11 20:35:00');
INSERT INTO `sys_operationlog` VALUES (256, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:35:04', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:35:04', 2, '2025-08-11 20:35:04');
INSERT INTO `sys_operationlog` VALUES (257, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:35:07', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:35:07', 2, '2025-08-11 20:35:07');
INSERT INTO `sys_operationlog` VALUES (258, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:38:55', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:38:55', 2, '2025-08-11 20:38:55');
INSERT INTO `sys_operationlog` VALUES (259, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:39:31', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:39:31', 2, '2025-08-11 20:39:31');
INSERT INTO `sys_operationlog` VALUES (260, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:39:57', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:39:57', 2, '2025-08-11 20:39:57');
INSERT INTO `sys_operationlog` VALUES (261, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:43:12', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:43:12', 2, '2025-08-11 20:43:12');
INSERT INTO `sys_operationlog` VALUES (262, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:45:53', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:45:53', 2, '2025-08-11 20:45:53');
INSERT INTO `sys_operationlog` VALUES (263, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 20:50:50', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:50:50', 2, '2025-08-11 20:50:50');
INSERT INTO `sys_operationlog` VALUES (264, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 20:50:52', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 20:50:52', 2, '2025-08-11 20:50:52');
INSERT INTO `sys_operationlog` VALUES (265, 0, 3, '系统设置>员工管理', '添加新员工', '2025-08-11 21:09:14', '{\"User\":{\"staff_id\":0,\"store_id\":0,\"username\":\"string\",\"password\":\"0efalrcsot+vdBvixLIzbU5wM2D/SR7FfjNS+MocpUY=\",\"Salt\":\"uUp9GVmFaI1w7kTKePjp1A==\",\"name\":\"string\",\"phone\":\"string\",\"position\":\"string\",\"status\":0,\"IsDelete\":1,\"last_login_time\":\"2025-08-11T13:09:12.597Z\",\"staff_role\":{\"id\":0,\"staff_id\":0,\"role_id\":0,\"role\":{\"role_id\":0,\"role_name\":\"string\",\"description\":\"string\"}}}}', 0, 0, '2025-08-11 21:09:14', 0, '2025-08-11 21:09:14');
INSERT INTO `sys_operationlog` VALUES (266, 2, 10, '系统登陆', '人员登陆', '2025-08-11 21:23:42', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 21:23:42', 2, '2025-08-11 21:23:42');
INSERT INTO `sys_operationlog` VALUES (267, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 21:23:50', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 21:23:50', 2, '2025-08-11 21:23:50');
INSERT INTO `sys_operationlog` VALUES (268, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 21:32:17', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 21:32:17', 2, '2025-08-11 21:32:17');
INSERT INTO `sys_operationlog` VALUES (269, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 21:35:58', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 21:35:58', 2, '2025-08-11 21:35:58');
INSERT INTO `sys_operationlog` VALUES (270, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 21:36:22', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 21:36:22', 2, '2025-08-11 21:36:22');
INSERT INTO `sys_operationlog` VALUES (271, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 21:37:09', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 21:37:09', 2, '2025-08-11 21:37:09');
INSERT INTO `sys_operationlog` VALUES (272, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 21:38:31', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 21:38:31', 2, '2025-08-11 21:38:31');
INSERT INTO `sys_operationlog` VALUES (273, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 21:40:38', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 21:40:38', 2, '2025-08-11 21:40:38');
INSERT INTO `sys_operationlog` VALUES (274, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 21:40:40', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 21:40:40', 2, '2025-08-11 21:40:40');
INSERT INTO `sys_operationlog` VALUES (275, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 21:42:16', '{\"storeId\":2,\"status\":0}', 1, 2, '2025-08-11 21:42:16', 2, '2025-08-11 21:42:16');
INSERT INTO `sys_operationlog` VALUES (276, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 21:42:16', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 21:42:16', 2, '2025-08-11 21:42:16');
INSERT INTO `sys_operationlog` VALUES (277, 2, 1, '系统设置>门店设置', '修改门店状态', '2025-08-11 21:42:17', '{\"storeId\":2,\"status\":1}', 1, 2, '2025-08-11 21:42:17', 2, '2025-08-11 21:42:17');
INSERT INTO `sys_operationlog` VALUES (278, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 21:42:17', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 21:42:17', 2, '2025-08-11 21:42:17');
INSERT INTO `sys_operationlog` VALUES (279, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 21:42:19', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 21:42:19', 2, '2025-08-11 21:42:19');
INSERT INTO `sys_operationlog` VALUES (280, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 21:44:08', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 21:44:08', 2, '2025-08-11 21:44:08');
INSERT INTO `sys_operationlog` VALUES (281, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 21:59:08', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 21:59:08', 2, '2025-08-11 21:59:08');
INSERT INTO `sys_operationlog` VALUES (282, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-11 21:59:13', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 21:59:13', 2, '2025-08-11 21:59:13');
INSERT INTO `sys_operationlog` VALUES (283, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:01:04', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:01:04', 2, '2025-08-11 22:01:04');
INSERT INTO `sys_operationlog` VALUES (284, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:06:35', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:06:35', 2, '2025-08-11 22:06:35');
INSERT INTO `sys_operationlog` VALUES (285, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:06:38', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:06:38', 2, '2025-08-11 22:06:38');
INSERT INTO `sys_operationlog` VALUES (286, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:09:06', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:09:06', 2, '2025-08-11 22:09:06');
INSERT INTO `sys_operationlog` VALUES (287, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:09:09', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:09:09', 2, '2025-08-11 22:09:09');
INSERT INTO `sys_operationlog` VALUES (288, 2, 10, '系统登陆', '人员登陆', '2025-08-11 22:14:18', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 22:14:18', 2, '2025-08-11 22:14:18');
INSERT INTO `sys_operationlog` VALUES (289, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:14:27', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:14:27', 2, '2025-08-11 22:14:27');
INSERT INTO `sys_operationlog` VALUES (290, 2, 10, '系统登陆', '人员登陆', '2025-08-11 22:16:46', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 22:16:46', 2, '2025-08-11 22:16:46');
INSERT INTO `sys_operationlog` VALUES (291, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:16:53', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:16:53', 2, '2025-08-11 22:16:53');
INSERT INTO `sys_operationlog` VALUES (292, 2, 3, '系统设置>员工管理', '添加新员工', '2025-08-11 22:17:12', '{\"User\":{\"staff_id\":0,\"store_id\":2,\"username\":\"111\",\"password\":\"BMZpYSyomGvvjUbr262nOrp7OFfAD5DbDzfHcHXiypM=\",\"Salt\":\"r5QpID9C25QLiY7gtjkdpw==\",\"name\":\"111\",\"phone\":\"11111111111\",\"position\":\"服务员\",\"status\":1,\"IsDelete\":1,\"last_login_time\":null,\"staff_role\":{\"id\":0,\"staff_id\":0,\"role_id\":0,\"role\":{\"role_id\":0,\"role_name\":null,\"description\":null}}}}', 1, 2, '2025-08-11 22:17:12', 2, '2025-08-11 22:17:12');
INSERT INTO `sys_operationlog` VALUES (293, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:17:17', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:17:17', 2, '2025-08-11 22:17:17');
INSERT INTO `sys_operationlog` VALUES (294, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:17:19', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:17:19', 2, '2025-08-11 22:17:19');
INSERT INTO `sys_operationlog` VALUES (295, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:17:23', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:17:23', 2, '2025-08-11 22:17:23');
INSERT INTO `sys_operationlog` VALUES (296, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:17:24', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:17:24', 2, '2025-08-11 22:17:24');
INSERT INTO `sys_operationlog` VALUES (297, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 22:17:28', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:17:28', 2, '2025-08-11 22:17:28');
INSERT INTO `sys_operationlog` VALUES (298, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:17:28', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:17:28', 2, '2025-08-11 22:17:28');
INSERT INTO `sys_operationlog` VALUES (299, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:18:10', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:18:10', 2, '2025-08-11 22:18:10');
INSERT INTO `sys_operationlog` VALUES (300, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:18:10', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:18:10', 2, '2025-08-11 22:18:10');
INSERT INTO `sys_operationlog` VALUES (301, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:18:11', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:18:11', 2, '2025-08-11 22:18:11');
INSERT INTO `sys_operationlog` VALUES (302, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:18:11', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:18:11', 2, '2025-08-11 22:18:11');
INSERT INTO `sys_operationlog` VALUES (303, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:18:12', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:18:12', 2, '2025-08-11 22:18:12');
INSERT INTO `sys_operationlog` VALUES (304, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:18:12', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:18:12', 2, '2025-08-11 22:18:12');
INSERT INTO `sys_operationlog` VALUES (305, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:18:13', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:18:13', 2, '2025-08-11 22:18:13');
INSERT INTO `sys_operationlog` VALUES (306, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:18:33', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:18:33', 2, '2025-08-11 22:18:33');
INSERT INTO `sys_operationlog` VALUES (307, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:18:39', '{\"name\":null,\"username\":null,\"phone\":\"1\",\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:18:39', 2, '2025-08-11 22:18:39');
INSERT INTO `sys_operationlog` VALUES (308, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:18:41', '{\"name\":null,\"username\":null,\"phone\":\"1\",\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:18:41', 2, '2025-08-11 22:18:41');
INSERT INTO `sys_operationlog` VALUES (309, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:18:45', '{\"name\":null,\"username\":null,\"phone\":\"1\",\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:18:45', 2, '2025-08-11 22:18:45');
INSERT INTO `sys_operationlog` VALUES (310, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:22:19', '{\"name\":null,\"username\":null,\"phone\":\"1\",\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:22:19', 2, '2025-08-11 22:22:19');
INSERT INTO `sys_operationlog` VALUES (311, 2, 10, '系统登陆', '人员登陆', '2025-08-11 22:22:49', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 22:22:49', 2, '2025-08-11 22:22:49');
INSERT INTO `sys_operationlog` VALUES (312, 2, 10, '系统登陆', '人员登陆', '2025-08-11 22:23:55', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 22:23:55', 2, '2025-08-11 22:23:55');
INSERT INTO `sys_operationlog` VALUES (313, 2, 10, '系统登陆', '人员登陆', '2025-08-11 22:33:00', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 22:33:00', 2, '2025-08-11 22:33:00');
INSERT INTO `sys_operationlog` VALUES (314, 2, 10, '系统登陆', '人员登陆', '2025-08-11 22:35:08', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 22:35:08', 2, '2025-08-11 22:35:08');
INSERT INTO `sys_operationlog` VALUES (315, 2, 10, '系统登陆', '人员登陆', '2025-08-11 22:35:15', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 22:35:15', 2, '2025-08-11 22:35:15');
INSERT INTO `sys_operationlog` VALUES (316, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:35:35', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:35:35', 2, '2025-08-11 22:35:35');
INSERT INTO `sys_operationlog` VALUES (317, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:35:35', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:35:35', 2, '2025-08-11 22:35:35');
INSERT INTO `sys_operationlog` VALUES (318, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:35:35', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:35:35', 2, '2025-08-11 22:35:35');
INSERT INTO `sys_operationlog` VALUES (319, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:35:35', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:35:35', 2, '2025-08-11 22:35:35');
INSERT INTO `sys_operationlog` VALUES (320, 2, 1, '系统设置>员工管理', '修改员工信息', '2025-08-11 22:36:34', '{\"User\":{\"staff_id\":4,\"store_id\":2,\"username\":\"111\",\"password\":\"\",\"Salt\":null,\"name\":\"22\",\"phone\":\"11111111111\",\"position\":\"服务员\",\"status\":1,\"IsDelete\":0,\"last_login_time\":null,\"staff_role\":null}}', 1, 2, '2025-08-11 22:36:34', 2, '2025-08-11 22:36:34');
INSERT INTO `sys_operationlog` VALUES (321, 2, 1, '系统设置>员工管理', '修改员工信息', '2025-08-11 22:36:35', '{\"User\":{\"staff_id\":4,\"store_id\":2,\"username\":\"111\",\"password\":\"\",\"Salt\":null,\"name\":\"22\",\"phone\":\"11111111111\",\"position\":\"服务员\",\"status\":1,\"IsDelete\":0,\"last_login_time\":null,\"staff_role\":null}}', 1, 2, '2025-08-11 22:36:35', 2, '2025-08-11 22:36:35');
INSERT INTO `sys_operationlog` VALUES (322, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:37:02', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:37:02', 2, '2025-08-11 22:37:02');
INSERT INTO `sys_operationlog` VALUES (323, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:37:03', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:37:03', 2, '2025-08-11 22:37:03');
INSERT INTO `sys_operationlog` VALUES (324, 2, 10, '系统登陆', '人员登陆', '2025-08-11 22:38:53', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 22:38:53', 2, '2025-08-11 22:38:53');
INSERT INTO `sys_operationlog` VALUES (325, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:39:18', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:39:18', 2, '2025-08-11 22:39:18');
INSERT INTO `sys_operationlog` VALUES (326, 2, 1, '系统设置>员工管理', '修改员工信息', '2025-08-11 22:39:33', '{\"User\":{\"staff_id\":4,\"store_id\":2,\"username\":\"111\",\"password\":\"JK31maMT2/tvhGuf2+k4QqGJNLxPwXjxOLOr6wydUU0=\",\"Salt\":\"ZYz42dlFtKL8JMApFIKZ6w==\",\"name\":\"222\",\"phone\":\"11111111111\",\"position\":\"服务员\",\"status\":1,\"IsDelete\":1,\"last_login_time\":null,\"staff_role\":null}}', 1, 2, '2025-08-11 22:39:33', 2, '2025-08-11 22:39:33');
INSERT INTO `sys_operationlog` VALUES (327, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:39:33', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:39:33', 2, '2025-08-11 22:39:33');
INSERT INTO `sys_operationlog` VALUES (328, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:39:48', '{\"name\":null,\"username\":null,\"phone\":\"11111\",\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:39:48', 2, '2025-08-11 22:39:48');
INSERT INTO `sys_operationlog` VALUES (329, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:40:10', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:40:10', 2, '2025-08-11 22:40:10');
INSERT INTO `sys_operationlog` VALUES (330, 2, 2, '系统设置>员工管理', '删除员工账号', '2025-08-11 22:40:12', '{\"Ids\":[4]}', 1, 2, '2025-08-11 22:40:12', 2, '2025-08-11 22:40:12');
INSERT INTO `sys_operationlog` VALUES (331, 2, 2, '系统设置>员工管理', '删除员工账号', '2025-08-11 22:40:13', '{\"Ids\":[4]}', 1, 2, '2025-08-11 22:40:13', 2, '2025-08-11 22:40:13');
INSERT INTO `sys_operationlog` VALUES (332, 2, 2, '系统设置>员工管理', '删除员工账号', '2025-08-11 22:40:20', '{\"Ids\":[4]}', 1, 2, '2025-08-11 22:40:20', 2, '2025-08-11 22:40:20');
INSERT INTO `sys_operationlog` VALUES (333, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:40:22', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:40:22', 2, '2025-08-11 22:40:22');
INSERT INTO `sys_operationlog` VALUES (334, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:40:26', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:40:26', 2, '2025-08-11 22:40:26');
INSERT INTO `sys_operationlog` VALUES (335, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:41:04', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:41:04', 2, '2025-08-11 22:41:04');
INSERT INTO `sys_operationlog` VALUES (336, 2, 1, '系统设置>员工管理', '修改员工信息', '2025-08-11 22:42:14', '{\"User\":{\"staff_id\":2,\"store_id\":1,\"username\":\"admin\",\"password\":\"zGlQaxeqx81kIMVPN6Kle4MZf5E4ZUczcplZeJfKtd8=\",\"Salt\":\"RizFC5QbIfYdFRWt1QgwgQ==\",\"name\":\"管理员\",\"phone\":\"18433646699\",\"position\":\"店长\",\"status\":1,\"IsDelete\":1,\"last_login_time\":null,\"staff_role\":null}}', 1, 2, '2025-08-11 22:42:14', 2, '2025-08-11 22:42:14');
INSERT INTO `sys_operationlog` VALUES (337, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:42:14', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:42:14', 2, '2025-08-11 22:42:14');
INSERT INTO `sys_operationlog` VALUES (338, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 22:44:17', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 22:44:17', 2, '2025-08-11 22:44:17');
INSERT INTO `sys_operationlog` VALUES (339, 0, 3, '系统设置>员工管理', '添加新员工', '2025-08-11 23:09:02', '{\"User\":{\"staff_id\":0,\"store_id\":1,\"username\":\"111\",\"password\":\"8pgVn7BnedAGOKthCSdIUifitpQsAWfKSDDFoz5R8oM=\",\"Salt\":\"SOMMsmOVbHI38x1hUkWfiQ==\",\"name\":\"111\",\"phone\":\"string\",\"position\":\"string\",\"status\":0,\"IsDelete\":1,\"last_login_time\":\"2025-08-11T15:08:43.32Z\",\"staff_role\":{\"id\":0,\"staff_id\":0,\"role_id\":0,\"role\":{\"role_id\":0,\"role_name\":\"string\",\"description\":\"string\"}}}}', 0, 0, '2025-08-11 23:09:02', 0, '2025-08-11 23:09:02');
INSERT INTO `sys_operationlog` VALUES (340, 2, 10, '系统登陆', '人员登陆', '2025-08-11 23:10:10', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 23:10:10', 2, '2025-08-11 23:10:10');
INSERT INTO `sys_operationlog` VALUES (341, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 23:10:18', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:10:18', 2, '2025-08-11 23:10:18');
INSERT INTO `sys_operationlog` VALUES (342, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-11 23:11:01', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:11:01', 2, '2025-08-11 23:11:01');
INSERT INTO `sys_operationlog` VALUES (343, 2, 10, '系统登陆', '人员登陆', '2025-08-11 23:11:41', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 23:11:41', 2, '2025-08-11 23:11:41');
INSERT INTO `sys_operationlog` VALUES (344, 2, 10, '系统登陆', '人员登陆', '2025-08-11 23:14:54', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 23:14:54', 2, '2025-08-11 23:14:54');
INSERT INTO `sys_operationlog` VALUES (345, 2, 10, '系统登陆', '人员登陆', '2025-08-11 23:28:39', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-11 23:28:39', 2, '2025-08-11 23:28:39');
INSERT INTO `sys_operationlog` VALUES (346, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:31:35', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:31:35', 2, '2025-08-11 23:31:35');
INSERT INTO `sys_operationlog` VALUES (347, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-11 23:31:48', '{\"roleId\":1,\"permissionIds\":[1,13,7,30,31,32,33,8,34,35,36,37,9,38,39,40,10,41,42,43,11,44,45,46,47,12,48,49,50,51]}', 1, 2, '2025-08-11 23:31:48', 2, '2025-08-11 23:31:48');
INSERT INTO `sys_operationlog` VALUES (348, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:31:51', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:31:51', 2, '2025-08-11 23:31:51');
INSERT INTO `sys_operationlog` VALUES (349, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:32:19', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:32:19', 2, '2025-08-11 23:32:19');
INSERT INTO `sys_operationlog` VALUES (350, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-11 23:32:35', '{\"roleId\":1,\"permissionIds\":[1,13,30,31,8,34,35,36,37,9,38,39,40,10,41,42,43,11,44,45,46,47,12,48,49,50,51]}', 1, 2, '2025-08-11 23:32:35', 2, '2025-08-11 23:32:35');
INSERT INTO `sys_operationlog` VALUES (351, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:32:38', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:32:38', 2, '2025-08-11 23:32:38');
INSERT INTO `sys_operationlog` VALUES (352, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:32:45', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:32:45', 2, '2025-08-11 23:32:45');
INSERT INTO `sys_operationlog` VALUES (353, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-11 23:33:02', '{\"roleId\":1,\"permissionIds\":[1,13,32,33,8,34,35,36,37,9,38,39,40,10,41,42,43,11,44,45,46,47,12,48,49,50,51]}', 1, 2, '2025-08-11 23:33:02', 2, '2025-08-11 23:33:02');
INSERT INTO `sys_operationlog` VALUES (354, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:33:05', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:33:05', 2, '2025-08-11 23:33:05');
INSERT INTO `sys_operationlog` VALUES (355, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:33:12', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:33:12', 2, '2025-08-11 23:33:12');
INSERT INTO `sys_operationlog` VALUES (356, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-11 23:35:05', '{\"roleId\":1,\"permissionIds\":[1,13,14,8,34,35,36,37,9,38,39,40,10,41,42,43,11,44,45,46,47,12,48,49,50,51]}', 1, 2, '2025-08-11 23:35:05', 2, '2025-08-11 23:35:05');
INSERT INTO `sys_operationlog` VALUES (357, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:35:26', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:35:26', 2, '2025-08-11 23:35:26');
INSERT INTO `sys_operationlog` VALUES (358, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:36:52', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:36:52', 2, '2025-08-11 23:36:52');
INSERT INTO `sys_operationlog` VALUES (359, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-11 23:37:04', '{\"roleId\":1,\"permissionIds\":[1,13,14,8,34,35,36,37,9,38,39,40,10,41,42,43,11,44,45,46,47,12,48,49,50,51]}', 1, 2, '2025-08-11 23:37:04', 2, '2025-08-11 23:37:04');
INSERT INTO `sys_operationlog` VALUES (360, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:38:14', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:38:14', 2, '2025-08-11 23:38:14');
INSERT INTO `sys_operationlog` VALUES (361, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-11 23:38:26', '{\"roleId\":1,\"permissionIds\":[1,13,14,8,34,35,36,37,9,38,39,40,10,41,42,43,11,44,45,46,47,12,48,49,50,51]}', 1, 2, '2025-08-11 23:38:26', 2, '2025-08-11 23:38:26');
INSERT INTO `sys_operationlog` VALUES (362, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:42:56', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:42:56', 2, '2025-08-11 23:42:56');
INSERT INTO `sys_operationlog` VALUES (363, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:43:03', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:43:03', 2, '2025-08-11 23:43:03');
INSERT INTO `sys_operationlog` VALUES (364, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:43:06', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:43:06', 2, '2025-08-11 23:43:06');
INSERT INTO `sys_operationlog` VALUES (365, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-11 23:43:12', '{\"roleId\":1,\"permissionIds\":[13,14,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51]}', 1, 2, '2025-08-11 23:43:12', 2, '2025-08-11 23:43:12');
INSERT INTO `sys_operationlog` VALUES (366, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:43:15', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:43:15', 2, '2025-08-11 23:43:15');
INSERT INTO `sys_operationlog` VALUES (367, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:46:35', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:46:35', 2, '2025-08-11 23:46:35');
INSERT INTO `sys_operationlog` VALUES (368, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:46:50', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:46:50', 2, '2025-08-11 23:46:50');
INSERT INTO `sys_operationlog` VALUES (369, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-11 23:47:04', '{\"roleId\":1,\"permissionIds\":[1,13,12,48,49,50,51]}', 1, 2, '2025-08-11 23:47:04', 2, '2025-08-11 23:47:04');
INSERT INTO `sys_operationlog` VALUES (370, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:47:06', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:47:06', 2, '2025-08-11 23:47:06');
INSERT INTO `sys_operationlog` VALUES (371, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:47:19', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:47:19', 2, '2025-08-11 23:47:19');
INSERT INTO `sys_operationlog` VALUES (372, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-11 23:47:24', '{\"roleId\":1,\"permissionIds\":[1,13,14,12,48,49,50,51]}', 1, 2, '2025-08-11 23:47:24', 2, '2025-08-11 23:47:24');
INSERT INTO `sys_operationlog` VALUES (373, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:47:26', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:47:26', 2, '2025-08-11 23:47:26');
INSERT INTO `sys_operationlog` VALUES (374, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:51:57', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:51:57', 2, '2025-08-11 23:51:57');
INSERT INTO `sys_operationlog` VALUES (375, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-11 23:52:01', '{\"roleId\":1,\"permissionIds\":[1,13,14,12,48,49,50,51,2]}', 1, 2, '2025-08-11 23:52:01', 2, '2025-08-11 23:52:01');
INSERT INTO `sys_operationlog` VALUES (376, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-11 23:52:04', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-11 23:52:04', 2, '2025-08-11 23:52:04');
INSERT INTO `sys_operationlog` VALUES (377, 2, 10, '系统登陆', '人员登陆', '2025-08-12 15:41:01', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-12 15:41:01', 2, '2025-08-12 15:41:01');
INSERT INTO `sys_operationlog` VALUES (378, 2, 10, '系统登陆', '人员登陆', '2025-08-12 15:42:13', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-12 15:42:13', 2, '2025-08-12 15:42:13');
INSERT INTO `sys_operationlog` VALUES (379, 2, 10, '系统登陆', '人员登陆', '2025-08-12 15:43:30', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-12 15:43:30', 2, '2025-08-12 15:43:30');
INSERT INTO `sys_operationlog` VALUES (380, 2, 11, '账号登出', '人员退出系统', '2025-08-12 15:43:38', '{}', 1, 2, '2025-08-12 15:43:38', 2, '2025-08-12 15:43:38');
INSERT INTO `sys_operationlog` VALUES (381, 2, 10, '系统登陆', '人员登陆', '2025-08-12 15:46:54', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-12 15:46:54', 2, '2025-08-12 15:46:54');
INSERT INTO `sys_operationlog` VALUES (382, 2, 11, '账号登出', '人员退出系统', '2025-08-12 15:47:00', '{}', 1, 2, '2025-08-12 15:47:00', 2, '2025-08-12 15:47:00');
INSERT INTO `sys_operationlog` VALUES (383, 2, 10, '系统登陆', '人员登陆', '2025-08-12 15:50:52', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-12 15:50:52', 2, '2025-08-12 15:50:52');
INSERT INTO `sys_operationlog` VALUES (384, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-12 15:51:35', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-12 15:51:35', 2, '2025-08-12 15:51:35');
INSERT INTO `sys_operationlog` VALUES (385, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-12 15:51:37', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-12 15:51:37', 2, '2025-08-12 15:51:37');
INSERT INTO `sys_operationlog` VALUES (386, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-12 15:51:38', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-12 15:51:38', 2, '2025-08-12 15:51:38');
INSERT INTO `sys_operationlog` VALUES (387, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-12 15:56:19', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-12 15:56:19', 2, '2025-08-12 15:56:19');
INSERT INTO `sys_operationlog` VALUES (388, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-12 15:56:42', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-12 15:56:42', 2, '2025-08-12 15:56:42');
INSERT INTO `sys_operationlog` VALUES (389, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-12 15:56:45', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-12 15:56:45', 2, '2025-08-12 15:56:45');
INSERT INTO `sys_operationlog` VALUES (390, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-12 16:19:56', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-12 16:19:56', 2, '2025-08-12 16:19:56');
INSERT INTO `sys_operationlog` VALUES (391, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-12 17:17:25', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-12 17:17:25', 2, '2025-08-12 17:17:25');
INSERT INTO `sys_operationlog` VALUES (392, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-12 17:17:26', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-12 17:17:26', 2, '2025-08-12 17:17:26');
INSERT INTO `sys_operationlog` VALUES (393, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-12 17:17:28', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-12 17:17:28', 2, '2025-08-12 17:17:28');
INSERT INTO `sys_operationlog` VALUES (394, 2, 10, '系统登陆', '人员登陆', '2025-08-14 15:10:16', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-14 15:10:16', 2, '2025-08-14 15:10:16');
INSERT INTO `sys_operationlog` VALUES (395, 2, 10, '系统登陆', '人员登陆', '2025-08-15 15:36:13', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-15 15:36:13', 2, '2025-08-15 15:36:13');
INSERT INTO `sys_operationlog` VALUES (396, 2, 10, '系统登陆', '人员登陆', '2025-08-16 10:38:55', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-16 10:38:55', 2, '2025-08-16 10:38:55');
INSERT INTO `sys_operationlog` VALUES (397, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-16 10:39:04', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-16 10:39:04', 2, '2025-08-16 10:39:04');
INSERT INTO `sys_operationlog` VALUES (398, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-16 10:39:15', '{\"roleId\":1,\"permissionIds\":[1,13,2,14,15,16,3,18,19,4,20,21,22,23,5,24,25,26,27,6,28,29,7,30,31,32,33,8,34,35,36,37,9,38,39,40,10,41,42,43,11,44,45,46,47,12,48,49,50,51]}', 1, 2, '2025-08-16 10:39:15', 2, '2025-08-16 10:39:15');
INSERT INTO `sys_operationlog` VALUES (399, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-16 10:39:17', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-16 10:39:17', 2, '2025-08-16 10:39:17');
INSERT INTO `sys_operationlog` VALUES (400, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 10:39:22', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 10:39:22', 2, '2025-08-16 10:39:22');
INSERT INTO `sys_operationlog` VALUES (401, 2, 4, '系统设置>角色管理', '菜品分类管理查询', '2025-08-16 10:39:30', '{\"name\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-16 10:39:30', 2, '2025-08-16 10:39:30');
INSERT INTO `sys_operationlog` VALUES (402, 2, 3, '系统设置>角色管理', '新增菜品分类', '2025-08-16 10:39:50', '{\"dishCategory\":{\"category_id\":0,\"store_id\":2,\"category_name\":\"凉菜\",\"sort_order\":1,\"status\":1}}', 1, 2, '2025-08-16 10:39:50', 2, '2025-08-16 10:39:50');
INSERT INTO `sys_operationlog` VALUES (403, 2, 4, '系统设置>角色管理', '菜品分类管理查询', '2025-08-16 10:39:50', '{\"name\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-16 10:39:50', 2, '2025-08-16 10:39:50');
INSERT INTO `sys_operationlog` VALUES (404, 2, 3, '系统设置>角色管理', '新增菜品分类', '2025-08-16 10:40:04', '{\"dishCategory\":{\"category_id\":0,\"store_id\":null,\"category_name\":\"热菜\",\"sort_order\":2,\"status\":1}}', 1, 2, '2025-08-16 10:40:04', 2, '2025-08-16 10:40:04');
INSERT INTO `sys_operationlog` VALUES (405, 2, 4, '系统设置>角色管理', '菜品分类管理查询', '2025-08-16 10:40:04', '{\"name\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-16 10:40:04', 2, '2025-08-16 10:40:04');
INSERT INTO `sys_operationlog` VALUES (406, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 10:40:08', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 10:40:08', 2, '2025-08-16 10:40:08');
INSERT INTO `sys_operationlog` VALUES (407, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 11:51:03', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 11:51:03', 2, '2025-08-16 11:51:03');
INSERT INTO `sys_operationlog` VALUES (408, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 11:51:08', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 11:51:08', 2, '2025-08-16 11:51:08');
INSERT INTO `sys_operationlog` VALUES (409, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 11:59:32', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 11:59:32', 2, '2025-08-16 11:59:32');
INSERT INTO `sys_operationlog` VALUES (410, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 11:59:39', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 11:59:39', 2, '2025-08-16 11:59:39');
INSERT INTO `sys_operationlog` VALUES (411, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 13:52:31', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 13:52:31', 2, '2025-08-16 13:52:31');
INSERT INTO `sys_operationlog` VALUES (412, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 13:53:56', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 13:53:56', 2, '2025-08-16 13:53:56');
INSERT INTO `sys_operationlog` VALUES (413, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 13:56:00', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 13:56:00', 2, '2025-08-16 13:56:00');
INSERT INTO `sys_operationlog` VALUES (414, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 13:58:58', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 13:58:58', 2, '2025-08-16 13:58:58');
INSERT INTO `sys_operationlog` VALUES (415, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 13:59:26', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 13:59:26', 2, '2025-08-16 13:59:26');
INSERT INTO `sys_operationlog` VALUES (416, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 13:59:33', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 13:59:33', 2, '2025-08-16 13:59:33');
INSERT INTO `sys_operationlog` VALUES (417, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:03:35', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:03:35', 2, '2025-08-16 14:03:35');
INSERT INTO `sys_operationlog` VALUES (418, 2, 11, '账号登出', '人员退出系统', '2025-08-16 14:03:38', '{}', 1, 2, '2025-08-16 14:03:38', 2, '2025-08-16 14:03:38');
INSERT INTO `sys_operationlog` VALUES (419, 2, 10, '系统登陆', '人员登陆', '2025-08-16 14:03:47', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-16 14:03:47', 2, '2025-08-16 14:03:47');
INSERT INTO `sys_operationlog` VALUES (420, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:03:54', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:03:54', 2, '2025-08-16 14:03:54');
INSERT INTO `sys_operationlog` VALUES (421, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:04:28', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:04:28', 2, '2025-08-16 14:04:28');
INSERT INTO `sys_operationlog` VALUES (422, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:04:29', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:04:29', 2, '2025-08-16 14:04:29');
INSERT INTO `sys_operationlog` VALUES (423, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:04:30', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:04:30', 2, '2025-08-16 14:04:30');
INSERT INTO `sys_operationlog` VALUES (424, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:04:30', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:04:30', 2, '2025-08-16 14:04:30');
INSERT INTO `sys_operationlog` VALUES (425, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:04:31', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:04:31', 2, '2025-08-16 14:04:31');
INSERT INTO `sys_operationlog` VALUES (426, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:04:31', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:04:31', 2, '2025-08-16 14:04:31');
INSERT INTO `sys_operationlog` VALUES (427, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:04:31', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:04:31', 2, '2025-08-16 14:04:31');
INSERT INTO `sys_operationlog` VALUES (428, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:04:31', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:04:31', 2, '2025-08-16 14:04:31');
INSERT INTO `sys_operationlog` VALUES (429, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:08:18', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:08:18', 2, '2025-08-16 14:08:18');
INSERT INTO `sys_operationlog` VALUES (430, 2, 3, '系统设置>角色管理', '新增菜品', '2025-08-16 14:08:30', '{\"sys_Dish\":{\"dish_id\":0,\"category_id\":1,\"dish_name\":\"1\",\"price\":11.0,\"member_price\":1.0,\"is_recommend\":0,\"is_temporary\":0,\"description\":\"\",\"image_url\":\"\",\"status\":1,\"cooking_time\":0,\"created_at\":\"2025-08-16T14:08:30.3690298+08:00\",\"updated_at\":\"2025-08-16T14:08:30.3690302+08:00\",\"store_id\":null}}', 1, 2, '2025-08-16 14:08:30', 2, '2025-08-16 14:08:30');
INSERT INTO `sys_operationlog` VALUES (431, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:08:30', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:08:30', 2, '2025-08-16 14:08:30');
INSERT INTO `sys_operationlog` VALUES (432, 2, 2, '系统设置>角色管理', '删除菜品', '2025-08-16 14:08:40', '{\"ids\":[1]}', 1, 2, '2025-08-16 14:08:40', 2, '2025-08-16 14:08:40');
INSERT INTO `sys_operationlog` VALUES (433, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:08:40', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:08:40', 2, '2025-08-16 14:08:40');
INSERT INTO `sys_operationlog` VALUES (434, 2, 3, '系统设置>角色管理', '新增菜品', '2025-08-16 14:09:20', '{\"sys_Dish\":{\"dish_id\":0,\"category_id\":2,\"dish_name\":\"烧鸭\",\"price\":45.0,\"member_price\":45.0,\"is_recommend\":1,\"is_temporary\":0,\"description\":\"秘制烧鸭\",\"image_url\":\"https://localhost:7092/20250816/a8e35a05-72e4-459e-9cf7-35c37c0289a2.png\",\"status\":1,\"cooking_time\":60,\"created_at\":\"2025-08-16T14:09:20.0229679+08:00\",\"updated_at\":\"2025-08-16T14:09:20.0229682+08:00\",\"store_id\":null}}', 1, 2, '2025-08-16 14:09:20', 2, '2025-08-16 14:09:20');
INSERT INTO `sys_operationlog` VALUES (435, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:09:20', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:09:20', 2, '2025-08-16 14:09:20');
INSERT INTO `sys_operationlog` VALUES (436, 2, 1, '系统设置>角色管理', '修改菜品', '2025-08-16 14:09:36', '{\"sys_Dish\":{\"dish_id\":2,\"category_id\":2,\"dish_name\":\"烧鸭\",\"price\":45.0,\"member_price\":45.0,\"is_recommend\":1,\"is_temporary\":0,\"description\":\"秘制烧鸭1111111111111111111111111111111111111111111111\",\"image_url\":\"https://localhost:7092/20250816/a8e35a05-72e4-459e-9cf7-35c37c0289a2.png\",\"status\":1,\"cooking_time\":60,\"created_at\":\"2025-08-16T14:09:20\",\"updated_at\":\"2025-08-16T14:09:20\",\"store_id\":null}}', 1, 2, '2025-08-16 14:09:36', 2, '2025-08-16 14:09:36');
INSERT INTO `sys_operationlog` VALUES (437, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:09:36', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:09:36', 2, '2025-08-16 14:09:36');
INSERT INTO `sys_operationlog` VALUES (438, 2, 1, '系统设置>角色管理', '修改菜品', '2025-08-16 14:11:39', '{\"sys_Dish\":{\"dish_id\":2,\"category_id\":2,\"dish_name\":\"烧鸭\",\"price\":45.0,\"member_price\":45.0,\"is_recommend\":1,\"is_temporary\":0,\"description\":\"秘制烧鸭\",\"image_url\":\"https://localhost:7092/20250816/a8e35a05-72e4-459e-9cf7-35c37c0289a2.png\",\"status\":1,\"cooking_time\":60,\"created_at\":\"2025-08-16T14:09:20\",\"updated_at\":\"2025-08-16T14:09:20\",\"store_id\":null}}', 1, 2, '2025-08-16 14:11:39', 2, '2025-08-16 14:11:39');
INSERT INTO `sys_operationlog` VALUES (439, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:11:39', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:11:39', 2, '2025-08-16 14:11:39');
INSERT INTO `sys_operationlog` VALUES (440, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:11:48', '{\"dishname\":null,\"type\":1,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:11:48', 2, '2025-08-16 14:11:48');
INSERT INTO `sys_operationlog` VALUES (441, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:11:52', '{\"dishname\":null,\"type\":2,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:11:52', 2, '2025-08-16 14:11:52');
INSERT INTO `sys_operationlog` VALUES (442, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:11:56', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:11:56', 2, '2025-08-16 14:11:56');
INSERT INTO `sys_operationlog` VALUES (443, 2, 3, '系统设置>角色管理', '新增菜品', '2025-08-16 14:13:30', '{\"sys_Dish\":{\"dish_id\":0,\"category_id\":1,\"dish_name\":\"油麦菜\",\"price\":15.0,\"member_price\":10.0,\"is_recommend\":1,\"is_temporary\":1,\"description\":\"季节菜\",\"image_url\":\"https://localhost:7092/20250816/b4f5b2bb-e207-44fc-a2b1-835f8c0958d2.jpg\",\"status\":1,\"cooking_time\":0,\"created_at\":\"2025-08-16T14:13:29.8862441+08:00\",\"updated_at\":\"2025-08-16T14:13:29.8862451+08:00\",\"store_id\":2}}', 1, 2, '2025-08-16 14:13:30', 2, '2025-08-16 14:13:30');
INSERT INTO `sys_operationlog` VALUES (444, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:13:30', '{\"dishname\":\"其实\",\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:13:30', 2, '2025-08-16 14:13:30');
INSERT INTO `sys_operationlog` VALUES (445, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:13:34', '{\"dishname\":\"其实\",\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:13:34', 2, '2025-08-16 14:13:34');
INSERT INTO `sys_operationlog` VALUES (446, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:13:35', '{\"dishname\":\"其实\",\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:13:35', 2, '2025-08-16 14:13:35');
INSERT INTO `sys_operationlog` VALUES (447, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:13:35', '{\"dishname\":\"其实\",\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:13:35', 2, '2025-08-16 14:13:35');
INSERT INTO `sys_operationlog` VALUES (448, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:14:00', '{\"dishname\":\"其实\",\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:14:00', 2, '2025-08-16 14:14:00');
INSERT INTO `sys_operationlog` VALUES (449, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:14:30', '{\"dishname\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:14:30', 2, '2025-08-16 14:14:30');
INSERT INTO `sys_operationlog` VALUES (450, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:32:31', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:32:31', 2, '2025-08-16 14:32:31');
INSERT INTO `sys_operationlog` VALUES (451, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 14:32:41', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 14:32:41', 2, '2025-08-16 14:32:41');
INSERT INTO `sys_operationlog` VALUES (452, 2, 10, '系统登陆', '人员登陆', '2025-08-16 15:23:32', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-16 15:23:32', 2, '2025-08-16 15:23:32');
INSERT INTO `sys_operationlog` VALUES (453, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-16 15:24:32', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-16 15:24:32', 2, '2025-08-16 15:24:32');
INSERT INTO `sys_operationlog` VALUES (454, 2, 10, '系统登陆', '人员登陆', '2025-08-18 14:06:42', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-18 14:06:42', 2, '2025-08-18 14:06:42');
INSERT INTO `sys_operationlog` VALUES (455, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-18 14:06:50', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-18 14:06:50', 2, '2025-08-18 14:06:50');
INSERT INTO `sys_operationlog` VALUES (456, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-18 14:06:54', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-18 14:06:54', 2, '2025-08-18 14:06:54');
INSERT INTO `sys_operationlog` VALUES (457, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-18 14:07:09', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-18 14:07:09', 2, '2025-08-18 14:07:09');
INSERT INTO `sys_operationlog` VALUES (458, 2, 4, '系统设置>角色管理', '菜品分类管理查询', '2025-08-18 14:07:12', '{\"name\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-18 14:07:12', 2, '2025-08-18 14:07:12');
INSERT INTO `sys_operationlog` VALUES (459, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-18 14:07:16', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-18 14:07:16', 2, '2025-08-18 14:07:16');
INSERT INTO `sys_operationlog` VALUES (460, 2, 3, '系统设置>角色管理', '新增桌台', '2025-08-18 14:07:43', '{\"sys_Table\":{\"table_id\":0,\"store_id\":2,\"table_no\":\"A01\",\"capacity\":4,\"table_type\":null,\"status\":1,\"min_consumption\":0.0,\"created_at\":\"0001-01-01T00:00:00\",\"updated_at\":\"0001-01-01T00:00:00\",\"order_id\":null,\"order\":null}}', 1, 2, '2025-08-18 14:07:43', 2, '2025-08-18 14:07:43');
INSERT INTO `sys_operationlog` VALUES (461, 2, 3, '系统设置>角色管理', '新增桌台', '2025-08-18 14:07:51', '{\"sys_Table\":{\"table_id\":0,\"store_id\":2,\"table_no\":\"A01\",\"capacity\":4,\"table_type\":null,\"status\":1,\"min_consumption\":0.0,\"created_at\":\"0001-01-01T00:00:00\",\"updated_at\":\"0001-01-01T00:00:00\",\"order_id\":null,\"order\":null}}', 1, 2, '2025-08-18 14:07:51', 2, '2025-08-18 14:07:51');
INSERT INTO `sys_operationlog` VALUES (462, 2, 3, '系统设置>角色管理', '新增桌台', '2025-08-18 14:08:13', '{\"sys_Table\":{\"table_id\":0,\"store_id\":2,\"table_no\":\"A01\",\"capacity\":4,\"table_type\":null,\"status\":1,\"min_consumption\":0.0,\"created_at\":\"0001-01-01T00:00:00\",\"updated_at\":\"0001-01-01T00:00:00\",\"order_id\":null,\"order\":null}}', 1, 2, '2025-08-18 14:08:13', 2, '2025-08-18 14:08:13');
INSERT INTO `sys_operationlog` VALUES (463, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-18 14:08:13', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-18 14:08:13', 2, '2025-08-18 14:08:13');
INSERT INTO `sys_operationlog` VALUES (464, 2, 3, '系统设置>角色管理', '新增桌台', '2025-08-18 14:08:27', '{\"sys_Table\":{\"table_id\":0,\"store_id\":2,\"table_no\":\"A02\",\"capacity\":2,\"table_type\":null,\"status\":1,\"min_consumption\":0.0,\"created_at\":\"0001-01-01T00:00:00\",\"updated_at\":\"0001-01-01T00:00:00\",\"order_id\":null,\"order\":null}}', 1, 2, '2025-08-18 14:08:27', 2, '2025-08-18 14:08:27');
INSERT INTO `sys_operationlog` VALUES (465, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-18 14:08:27', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-18 14:08:27', 2, '2025-08-18 14:08:27');
INSERT INTO `sys_operationlog` VALUES (466, 2, 3, '系统设置>角色管理', '新增桌台', '2025-08-18 14:08:44', '{\"sys_Table\":{\"table_id\":0,\"store_id\":2,\"table_no\":\"B01\",\"capacity\":6,\"table_type\":null,\"status\":1,\"min_consumption\":0.0,\"created_at\":\"0001-01-01T00:00:00\",\"updated_at\":\"0001-01-01T00:00:00\",\"order_id\":null,\"order\":null}}', 1, 2, '2025-08-18 14:08:44', 2, '2025-08-18 14:08:44');
INSERT INTO `sys_operationlog` VALUES (467, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-18 14:08:44', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-18 14:08:44', 2, '2025-08-18 14:08:44');
INSERT INTO `sys_operationlog` VALUES (468, 2, 10, '系统登陆', '人员登陆', '2025-08-18 15:40:36', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-18 15:40:36', 2, '2025-08-18 15:40:36');
INSERT INTO `sys_operationlog` VALUES (469, 2, 4, '系统设置>角色管理', '菜品分类管理查询', '2025-08-18 15:40:42', '{\"name\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-18 15:40:42', 2, '2025-08-18 15:40:42');
INSERT INTO `sys_operationlog` VALUES (470, 2, 10, '系统登陆', '人员登陆', '2025-08-18 15:55:02', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-18 15:55:02', 2, '2025-08-18 15:55:02');
INSERT INTO `sys_operationlog` VALUES (471, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-18 15:55:08', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-18 15:55:08', 2, '2025-08-18 15:55:08');
INSERT INTO `sys_operationlog` VALUES (472, 2, 1, '系统设置>角色管理', '修改菜品', '2025-08-18 15:56:21', '{\"sys_Dish\":{\"dish_id\":2,\"category_id\":2,\"dish_name\":\"烧鸭\",\"price\":45.0,\"member_price\":45.0,\"is_recommend\":1,\"is_temporary\":0,\"description\":\"招牌特色菜\",\"image_url\":\"https://localhost:7092/20250816/a8e35a05-72e4-459e-9cf7-35c37c0289a2.png\",\"status\":1,\"cooking_time\":60,\"created_at\":\"2025-08-16T14:09:20\",\"updated_at\":\"2025-08-16T14:09:20\",\"store_id\":null}}', 1, 2, '2025-08-18 15:56:21', 2, '2025-08-18 15:56:21');
INSERT INTO `sys_operationlog` VALUES (473, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-18 15:56:21', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-18 15:56:21', 2, '2025-08-18 15:56:21');
INSERT INTO `sys_operationlog` VALUES (474, 2, 10, '系统登陆', '人员登陆', '2025-08-18 17:08:41', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-18 17:08:41', 2, '2025-08-18 17:08:41');
INSERT INTO `sys_operationlog` VALUES (475, 2, 4, '系统设置>角色管理', '菜品分类管理查询', '2025-08-18 17:08:49', '{\"name\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-18 17:08:49', 2, '2025-08-18 17:08:49');
INSERT INTO `sys_operationlog` VALUES (476, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-18 17:08:53', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-18 17:08:53', 2, '2025-08-18 17:08:53');
INSERT INTO `sys_operationlog` VALUES (477, 2, 10, '系统登陆', '人员登陆', '2025-08-20 14:43:07', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-20 14:43:07', 2, '2025-08-20 14:43:07');
INSERT INTO `sys_operationlog` VALUES (478, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-20 14:43:18', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 14:43:18', 2, '2025-08-20 14:43:18');
INSERT INTO `sys_operationlog` VALUES (479, 2, 3, '系统设置>角色管理', '新增角色', '2025-08-20 14:44:03', '{\"sys_Role\":{\"role_id\":3,\"role_name\":\"员工\",\"description\":\"负责订单处理\"}}', 1, 2, '2025-08-20 14:44:03', 2, '2025-08-20 14:44:03');
INSERT INTO `sys_operationlog` VALUES (480, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-20 14:44:03', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 14:44:03', 2, '2025-08-20 14:44:03');
INSERT INTO `sys_operationlog` VALUES (481, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-20 14:44:30', '{\"roleId\":3,\"permissionIds\":[1,13,2,14,15,16,3,18,19,4,20,21,22,23,5,24,25,26,27,6,28,29,7,30,31,32,33,8,34,35,36,37,9,38,39,40,10,41,42,43,11,44,45,46,47]}', 1, 2, '2025-08-20 14:44:30', 2, '2025-08-20 14:44:30');
INSERT INTO `sys_operationlog` VALUES (482, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 14:44:33', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 14:44:33', 2, '2025-08-20 14:44:33');
INSERT INTO `sys_operationlog` VALUES (483, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-20 14:45:06', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 14:45:06', 2, '2025-08-20 14:45:06');
INSERT INTO `sys_operationlog` VALUES (484, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-20 14:45:07', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 14:45:07', 2, '2025-08-20 14:45:07');
INSERT INTO `sys_operationlog` VALUES (485, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 14:45:08', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 14:45:08', 2, '2025-08-20 14:45:08');
INSERT INTO `sys_operationlog` VALUES (486, 2, 3, '系统设置>员工管理', '添加新员工', '2025-08-20 14:46:14', '{\"User\":{\"staff_id\":0,\"store_id\":2,\"username\":\"lq\",\"password\":\"RmvNZj6kSC+nwjcKUz508qr5QZQzYMJvV+AZijokzRg=\",\"Salt\":\"NPfUr8Mh5OCBOCKWVjTe5g==\",\"name\":\"lq\",\"phone\":\"11111111111\",\"position\":\"服务员\",\"status\":1,\"IsDelete\":1,\"last_login_time\":null,\"staff_role\":null,\"store\":null}}', 1, 2, '2025-08-20 14:46:14', 2, '2025-08-20 14:46:14');
INSERT INTO `sys_operationlog` VALUES (487, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 14:46:14', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 14:46:14', 2, '2025-08-20 14:46:14');
INSERT INTO `sys_operationlog` VALUES (488, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-20 14:47:06', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 14:47:06', 2, '2025-08-20 14:47:06');
INSERT INTO `sys_operationlog` VALUES (489, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-20 14:47:08', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 14:47:08', 2, '2025-08-20 14:47:08');
INSERT INTO `sys_operationlog` VALUES (490, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:04:48', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:04:48', 2, '2025-08-20 15:04:48');
INSERT INTO `sys_operationlog` VALUES (491, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:07:35', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:07:35', 2, '2025-08-20 15:07:35');
INSERT INTO `sys_operationlog` VALUES (492, 2, 10, '系统登陆', '人员登陆', '2025-08-20 15:32:19', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-20 15:32:19', 2, '2025-08-20 15:32:19');
INSERT INTO `sys_operationlog` VALUES (493, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:32:26', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:32:26', 2, '2025-08-20 15:32:26');
INSERT INTO `sys_operationlog` VALUES (494, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:33:17', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:33:17', 2, '2025-08-20 15:33:17');
INSERT INTO `sys_operationlog` VALUES (495, 2, 10, '系统登陆', '人员登陆', '2025-08-20 15:35:10', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-20 15:35:10', 2, '2025-08-20 15:35:10');
INSERT INTO `sys_operationlog` VALUES (496, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:35:18', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:35:18', 2, '2025-08-20 15:35:18');
INSERT INTO `sys_operationlog` VALUES (497, 2, 10, '系统登陆', '人员登陆', '2025-08-20 15:35:36', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-20 15:35:36', 2, '2025-08-20 15:35:36');
INSERT INTO `sys_operationlog` VALUES (498, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:35:46', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:35:46', 2, '2025-08-20 15:35:46');
INSERT INTO `sys_operationlog` VALUES (499, 2, 10, '系统登陆', '人员登陆', '2025-08-20 15:36:44', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-20 15:36:44', 2, '2025-08-20 15:36:44');
INSERT INTO `sys_operationlog` VALUES (500, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:36:47', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:36:47', 2, '2025-08-20 15:36:47');
INSERT INTO `sys_operationlog` VALUES (501, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:37:27', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:37:27', 2, '2025-08-20 15:37:27');
INSERT INTO `sys_operationlog` VALUES (502, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:37:32', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:37:32', 2, '2025-08-20 15:37:32');
INSERT INTO `sys_operationlog` VALUES (503, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:40:40', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:40:40', 2, '2025-08-20 15:40:40');
INSERT INTO `sys_operationlog` VALUES (504, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:43:06', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:43:06', 2, '2025-08-20 15:43:06');
INSERT INTO `sys_operationlog` VALUES (505, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:43:08', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:43:08', 2, '2025-08-20 15:43:08');
INSERT INTO `sys_operationlog` VALUES (506, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:44:53', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:44:53', 2, '2025-08-20 15:44:53');
INSERT INTO `sys_operationlog` VALUES (507, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:44:58', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:44:58', 2, '2025-08-20 15:44:58');
INSERT INTO `sys_operationlog` VALUES (508, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:45:06', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:45:06', 2, '2025-08-20 15:45:06');
INSERT INTO `sys_operationlog` VALUES (509, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:45:14', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:45:14', 2, '2025-08-20 15:45:14');
INSERT INTO `sys_operationlog` VALUES (510, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:45:36', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:45:36', 2, '2025-08-20 15:45:36');
INSERT INTO `sys_operationlog` VALUES (511, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:45:38', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:45:38', 2, '2025-08-20 15:45:38');
INSERT INTO `sys_operationlog` VALUES (512, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:46:10', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:46:10', 2, '2025-08-20 15:46:10');
INSERT INTO `sys_operationlog` VALUES (513, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:46:11', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:46:11', 2, '2025-08-20 15:46:11');
INSERT INTO `sys_operationlog` VALUES (514, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:52:10', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:52:10', 2, '2025-08-20 15:52:10');
INSERT INTO `sys_operationlog` VALUES (515, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:55:22', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:55:22', 2, '2025-08-20 15:55:22');
INSERT INTO `sys_operationlog` VALUES (516, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 15:56:25', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 15:56:25', 2, '2025-08-20 15:56:25');
INSERT INTO `sys_operationlog` VALUES (517, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:00:03', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:00:03', 2, '2025-08-20 16:00:03');
INSERT INTO `sys_operationlog` VALUES (518, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:01:09', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:01:09', 2, '2025-08-20 16:01:09');
INSERT INTO `sys_operationlog` VALUES (519, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:01:27', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:01:27', 2, '2025-08-20 16:01:27');
INSERT INTO `sys_operationlog` VALUES (520, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:01:57', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:01:57', 2, '2025-08-20 16:01:57');
INSERT INTO `sys_operationlog` VALUES (521, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:05:17', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:05:17', 2, '2025-08-20 16:05:17');
INSERT INTO `sys_operationlog` VALUES (522, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:05:58', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:05:58', 2, '2025-08-20 16:05:58');
INSERT INTO `sys_operationlog` VALUES (523, 2, 1, '系统设置>员工管理', '修改员工信息', '2025-08-20 16:06:27', '{\"User\":{\"staff_id\":5,\"store_id\":2,\"username\":\"lq\",\"password\":\"IejnNOe2gnOvVHvEhQD2hzD5JHHl+OTa/6lx4uXTL9E=\",\"Salt\":\"60oCj4q4esjJP8TVONr5ew==\",\"name\":\"lq\",\"phone\":\"11111111111\",\"position\":\"服务员\",\"status\":1,\"IsDelete\":1,\"last_login_time\":null,\"staff_role\":null,\"store\":null,\"RoleId\":0}}', 1, 2, '2025-08-20 16:06:27', 2, '2025-08-20 16:06:27');
INSERT INTO `sys_operationlog` VALUES (524, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:06:27', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:06:27', 2, '2025-08-20 16:06:27');
INSERT INTO `sys_operationlog` VALUES (525, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:06:30', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:06:30', 2, '2025-08-20 16:06:30');
INSERT INTO `sys_operationlog` VALUES (526, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:06:32', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:06:32', 2, '2025-08-20 16:06:32');
INSERT INTO `sys_operationlog` VALUES (527, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:06:32', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:06:32', 2, '2025-08-20 16:06:32');
INSERT INTO `sys_operationlog` VALUES (528, 2, 1, '系统设置>员工管理', '修改员工信息', '2025-08-20 16:07:47', '{\"User\":{\"staff_id\":5,\"store_id\":2,\"username\":\"lq\",\"password\":\"dC5id1XnzbN5o/VhFaTuVHxIDKa5WrylAqGcnsOM7k0=\",\"Salt\":\"tAwmiMR8dNGWcWl6wWymJg==\",\"name\":\"lq\",\"phone\":\"11111111111\",\"position\":\"服务员\",\"status\":1,\"IsDelete\":1,\"last_login_time\":null,\"staff_role\":null,\"store\":null,\"RoleId\":0}}', 1, 2, '2025-08-20 16:07:47', 2, '2025-08-20 16:07:47');
INSERT INTO `sys_operationlog` VALUES (529, 2, 10, '系统登陆', '人员登陆', '2025-08-20 16:08:46', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-20 16:08:46', 2, '2025-08-20 16:08:46');
INSERT INTO `sys_operationlog` VALUES (530, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:08:51', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:08:51', 2, '2025-08-20 16:08:51');
INSERT INTO `sys_operationlog` VALUES (531, 2, 1, '系统设置>员工管理', '修改员工信息', '2025-08-20 16:08:56', '{\"User\":{\"staff_id\":5,\"store_id\":2,\"username\":\"lq\",\"password\":\"2ArJ1ZU1TJuQeluqqTsKy+9NvW8IWFG8ik7iemrrJqA=\",\"Salt\":\"AA0c3Vt2C2eDjv0n7Nql6g==\",\"name\":\"lq\",\"phone\":\"11111111111\",\"position\":\"服务员\",\"status\":1,\"IsDelete\":1,\"last_login_time\":null,\"staff_role\":null,\"store\":null,\"RoleId\":3}}', 1, 2, '2025-08-20 16:08:56', 2, '2025-08-20 16:08:56');
INSERT INTO `sys_operationlog` VALUES (532, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:08:56', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:08:56', 2, '2025-08-20 16:08:56');
INSERT INTO `sys_operationlog` VALUES (533, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:08:59', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:08:59', 2, '2025-08-20 16:08:59');
INSERT INTO `sys_operationlog` VALUES (534, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:09:00', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:09:00', 2, '2025-08-20 16:09:00');
INSERT INTO `sys_operationlog` VALUES (535, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:09:00', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:09:00', 2, '2025-08-20 16:09:00');
INSERT INTO `sys_operationlog` VALUES (536, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:09:00', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:09:00', 2, '2025-08-20 16:09:00');
INSERT INTO `sys_operationlog` VALUES (537, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:09:05', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:09:05', 2, '2025-08-20 16:09:05');
INSERT INTO `sys_operationlog` VALUES (538, 2, 1, '系统设置>员工管理', '修改员工信息', '2025-08-20 16:09:33', '{\"User\":{\"staff_id\":5,\"store_id\":2,\"username\":\"lq\",\"password\":\"xk1PjzJhE40m4A3PdaUizc9N4YwN1oqbRv1STj0AmYA=\",\"Salt\":\"1oXTj8z+1xKZJ4E46fA68g==\",\"name\":\"lq\",\"phone\":\"11111111111\",\"position\":\"服务员\",\"status\":1,\"IsDelete\":1,\"last_login_time\":null,\"staff_role\":null,\"store\":null,\"RoleId\":3}}', 1, 2, '2025-08-20 16:09:33', 2, '2025-08-20 16:09:33');
INSERT INTO `sys_operationlog` VALUES (539, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:09:33', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:09:33', 2, '2025-08-20 16:09:33');
INSERT INTO `sys_operationlog` VALUES (540, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:09:41', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:09:41', 2, '2025-08-20 16:09:41');
INSERT INTO `sys_operationlog` VALUES (541, 2, 1, '系统设置>员工管理', '修改员工信息', '2025-08-20 16:10:16', '{\"User\":{\"staff_id\":5,\"store_id\":2,\"username\":\"lq\",\"password\":\"kWzXNr8I0tqBew1vrUF5pmZY8fPL9gX5KZrI713LNqg=\",\"Salt\":\"PNtBsYkhlRk5ZVaMI6GsOQ==\",\"name\":\"lq\",\"phone\":\"11111111111\",\"position\":\"服务员\",\"status\":1,\"IsDelete\":1,\"last_login_time\":null,\"staff_role\":null,\"store\":null,\"RoleId\":3}}', 1, 2, '2025-08-20 16:10:16', 2, '2025-08-20 16:10:16');
INSERT INTO `sys_operationlog` VALUES (542, 2, 10, '系统登陆', '人员登陆', '2025-08-20 16:12:38', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-20 16:12:38', 2, '2025-08-20 16:12:38');
INSERT INTO `sys_operationlog` VALUES (543, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:12:40', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:12:40', 2, '2025-08-20 16:12:40');
INSERT INTO `sys_operationlog` VALUES (544, 2, 1, '系统设置>员工管理', '修改员工信息', '2025-08-20 16:12:48', '{\"User\":{\"staff_id\":5,\"store_id\":2,\"username\":\"lq\",\"password\":\"0K6Ho9bbgNFczwzrkW1Zl1rzntOtXLNzz8VEUtZYZCg=\",\"Salt\":\"Hia9s1aWaS6FmnJmdFD46w==\",\"name\":\"lq\",\"phone\":\"11111111111\",\"position\":\"服务员\",\"status\":1,\"IsDelete\":1,\"last_login_time\":null,\"staff_role\":null,\"store\":null,\"RoleId\":3}}', 1, 2, '2025-08-20 16:12:48', 2, '2025-08-20 16:12:48');
INSERT INTO `sys_operationlog` VALUES (545, 2, 1, '系统设置>员工管理', '修改员工信息', '2025-08-20 16:12:54', '{\"User\":{\"staff_id\":5,\"store_id\":2,\"username\":\"lq\",\"password\":\"QWgp/gS7Lo4JZudAQdN8RvldnkwXfESr1QfCk4qx7Tw=\",\"Salt\":\"Ka4TliPcYphbB+oCGalvMw==\",\"name\":\"lq\",\"phone\":\"11111111111\",\"position\":\"服务员\",\"status\":1,\"IsDelete\":1,\"last_login_time\":null,\"staff_role\":null,\"store\":null,\"RoleId\":3}}', 1, 2, '2025-08-20 16:12:54', 2, '2025-08-20 16:12:54');
INSERT INTO `sys_operationlog` VALUES (546, 2, 1, '系统设置>员工管理', '修改员工信息', '2025-08-20 16:14:09', '{\"User\":{\"staff_id\":5,\"store_id\":2,\"username\":\"lq\",\"password\":\"2pjBN/3ejk9IbE698dRnBrFlT/jbduFlkinF+l0xmMo=\",\"Salt\":\"Mh7dEqXCwjz2F1gTAJzB3A==\",\"name\":\"lq\",\"phone\":\"11111111111\",\"position\":\"服务员\",\"status\":1,\"IsDelete\":1,\"last_login_time\":null,\"staff_role\":null,\"store\":null,\"RoleId\":3}}', 1, 2, '2025-08-20 16:14:09', 2, '2025-08-20 16:14:09');
INSERT INTO `sys_operationlog` VALUES (547, 2, 10, '系统登陆', '人员登陆', '2025-08-20 16:14:09', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-20 16:14:09', 2, '2025-08-20 16:14:09');
INSERT INTO `sys_operationlog` VALUES (548, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:14:12', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:14:12', 2, '2025-08-20 16:14:12');
INSERT INTO `sys_operationlog` VALUES (549, 2, 1, '系统设置>员工管理', '修改员工信息', '2025-08-20 16:14:50', '{\"User\":{\"staff_id\":5,\"store_id\":2,\"username\":\"lq\",\"password\":\"5iodpJQyXZwZUlkmv2sDfDd8mX/13HuoTRBTokwvvUo=\",\"Salt\":\"2zpKzVyKZrkZ0FyEHotNHA==\",\"name\":\"lq\",\"phone\":\"11111111111\",\"position\":\"服务员\",\"status\":1,\"IsDelete\":1,\"last_login_time\":null,\"staff_role\":null,\"store\":null,\"RoleId\":3}}', 1, 2, '2025-08-20 16:14:50', 2, '2025-08-20 16:14:50');
INSERT INTO `sys_operationlog` VALUES (550, 2, 10, '系统登陆', '人员登陆', '2025-08-20 16:14:54', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-20 16:14:54', 2, '2025-08-20 16:14:54');
INSERT INTO `sys_operationlog` VALUES (551, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:14:57', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:14:57', 2, '2025-08-20 16:14:57');
INSERT INTO `sys_operationlog` VALUES (552, 2, 1, '系统设置>员工管理', '修改员工信息', '2025-08-20 16:15:05', '{\"User\":{\"staff_id\":5,\"store_id\":2,\"username\":\"lq\",\"password\":\"rHsCXWY6Rijv1YaWVMqE2JFm6XxHSowud1UYFXLgIqs=\",\"Salt\":\"YbrhDavyF72UYFDK3qwxXw==\",\"name\":\"lq\",\"phone\":\"11111111111\",\"position\":\"服务员\",\"status\":1,\"IsDelete\":1,\"last_login_time\":null,\"staff_role\":null,\"store\":null,\"RoleId\":3}}', 1, 2, '2025-08-20 16:15:05', 2, '2025-08-20 16:15:05');
INSERT INTO `sys_operationlog` VALUES (553, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:15:05', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:15:05', 2, '2025-08-20 16:15:05');
INSERT INTO `sys_operationlog` VALUES (554, 2, 11, '账号登出', '人员退出系统', '2025-08-20 16:15:21', '{}', 1, 2, '2025-08-20 16:15:21', 2, '2025-08-20 16:15:21');
INSERT INTO `sys_operationlog` VALUES (555, 2, 10, '系统登陆', '人员登陆', '2025-08-20 16:19:06', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-20 16:19:06', 2, '2025-08-20 16:19:06');
INSERT INTO `sys_operationlog` VALUES (556, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:19:12', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:19:12', 2, '2025-08-20 16:19:12');
INSERT INTO `sys_operationlog` VALUES (557, 2, 2, '系统设置>员工管理', '删除员工账号', '2025-08-20 16:19:16', '{\"Ids\":[5]}', 1, 2, '2025-08-20 16:19:16', 2, '2025-08-20 16:19:16');
INSERT INTO `sys_operationlog` VALUES (558, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:19:16', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:19:16', 2, '2025-08-20 16:19:16');
INSERT INTO `sys_operationlog` VALUES (559, 2, 3, '系统设置>员工管理', '添加新员工', '2025-08-20 16:19:56', '{\"User\":{\"staff_id\":0,\"store_id\":2,\"username\":\"lq\",\"password\":\"jv77mITf0Nl7Vpz1iyPSAszCDwLxq4lU11UnEOn4q6U=\",\"Salt\":\"PzBgx3X4Rqt+GDPMcm2ekw==\",\"name\":\"lq\",\"phone\":\"11111111111\",\"position\":\"服务员\",\"status\":1,\"IsDelete\":1,\"last_login_time\":null,\"staff_role\":null,\"store\":null,\"RoleId\":3}}', 1, 2, '2025-08-20 16:19:56', 2, '2025-08-20 16:19:56');
INSERT INTO `sys_operationlog` VALUES (560, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-20 16:19:56', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-20 16:19:56', 2, '2025-08-20 16:19:56');
INSERT INTO `sys_operationlog` VALUES (561, 2, 11, '账号登出', '人员退出系统', '2025-08-20 16:20:00', '{}', 1, 2, '2025-08-20 16:20:00', 2, '2025-08-20 16:20:00');
INSERT INTO `sys_operationlog` VALUES (562, 6, 10, '系统登陆', '人员登陆', '2025-08-20 16:20:02', '账号：lq,员工姓名：lq', 2, 6, '2025-08-20 16:20:02', 6, '2025-08-20 16:20:02');
INSERT INTO `sys_operationlog` VALUES (563, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-20 16:21:05', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-20 16:21:05', 6, '2025-08-20 16:21:05');
INSERT INTO `sys_operationlog` VALUES (564, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-20 16:21:12', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-20 16:21:12', 6, '2025-08-20 16:21:12');
INSERT INTO `sys_operationlog` VALUES (565, 6, 10, '系统登陆', '人员登陆', '2025-08-21 09:48:45', '账号：lq,员工姓名：lq', 2, 6, '2025-08-21 09:48:45', 6, '2025-08-21 09:48:45');
INSERT INTO `sys_operationlog` VALUES (566, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 09:48:48', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 09:48:48', 6, '2025-08-21 09:48:48');
INSERT INTO `sys_operationlog` VALUES (567, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 09:49:20', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 09:49:20', 6, '2025-08-21 09:49:20');
INSERT INTO `sys_operationlog` VALUES (568, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 09:49:51', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 09:49:51', 6, '2025-08-21 09:49:51');
INSERT INTO `sys_operationlog` VALUES (569, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 09:49:55', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 09:49:55', 6, '2025-08-21 09:49:55');
INSERT INTO `sys_operationlog` VALUES (570, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 09:50:21', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 09:50:21', 6, '2025-08-21 09:50:21');
INSERT INTO `sys_operationlog` VALUES (571, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 09:50:24', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 09:50:24', 6, '2025-08-21 09:50:24');
INSERT INTO `sys_operationlog` VALUES (572, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 09:51:27', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 09:51:27', 6, '2025-08-21 09:51:27');
INSERT INTO `sys_operationlog` VALUES (573, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 09:54:52', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 09:54:52', 6, '2025-08-21 09:54:52');
INSERT INTO `sys_operationlog` VALUES (574, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 09:55:12', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 09:55:12', 6, '2025-08-21 09:55:12');
INSERT INTO `sys_operationlog` VALUES (575, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 09:55:18', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 09:55:18', 6, '2025-08-21 09:55:18');
INSERT INTO `sys_operationlog` VALUES (576, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 09:55:25', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 09:55:25', 6, '2025-08-21 09:55:25');
INSERT INTO `sys_operationlog` VALUES (577, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 09:55:53', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 09:55:53', 6, '2025-08-21 09:55:53');
INSERT INTO `sys_operationlog` VALUES (578, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 09:55:59', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 09:55:59', 6, '2025-08-21 09:55:59');
INSERT INTO `sys_operationlog` VALUES (579, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 09:56:36', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 09:56:36', 6, '2025-08-21 09:56:36');
INSERT INTO `sys_operationlog` VALUES (580, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 10:07:34', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:07:34', 6, '2025-08-21 10:07:34');
INSERT INTO `sys_operationlog` VALUES (581, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 10:07:42', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:07:42', 6, '2025-08-21 10:07:42');
INSERT INTO `sys_operationlog` VALUES (582, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 10:07:46', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:07:46', 6, '2025-08-21 10:07:46');
INSERT INTO `sys_operationlog` VALUES (583, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 10:07:49', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:07:49', 6, '2025-08-21 10:07:49');
INSERT INTO `sys_operationlog` VALUES (584, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 10:10:27', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:10:27', 6, '2025-08-21 10:10:27');
INSERT INTO `sys_operationlog` VALUES (585, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-21 10:11:07', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:11:07', 6, '2025-08-21 10:11:07');
INSERT INTO `sys_operationlog` VALUES (586, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-21 10:14:22', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:14:22', 6, '2025-08-21 10:14:22');
INSERT INTO `sys_operationlog` VALUES (587, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-21 10:14:43', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:14:43', 6, '2025-08-21 10:14:43');
INSERT INTO `sys_operationlog` VALUES (588, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-21 10:14:58', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:14:58', 6, '2025-08-21 10:14:58');
INSERT INTO `sys_operationlog` VALUES (589, 6, 1, '系统设置>角色管理', '修改桌台', '2025-08-21 10:16:34', '{\"sys_Table\":{\"table_id\":1,\"store_id\":2,\"table_no\":\"A01\",\"capacity\":4,\"table_type\":null,\"status\":1,\"min_consumption\":0.0,\"created_at\":\"0001-01-01T00:00:00\",\"updated_at\":\"0001-01-01T00:00:00\",\"order_id\":null,\"order\":null,\"desc\":\"四人桌（一楼大厅）\"}}', 2, 6, '2025-08-21 10:16:34', 6, '2025-08-21 10:16:34');
INSERT INTO `sys_operationlog` VALUES (590, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-21 10:16:34', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:16:34', 6, '2025-08-21 10:16:34');
INSERT INTO `sys_operationlog` VALUES (591, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-21 10:16:37', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:16:37', 6, '2025-08-21 10:16:37');
INSERT INTO `sys_operationlog` VALUES (592, 6, 1, '系统设置>角色管理', '修改桌台', '2025-08-21 10:17:19', '{\"sys_Table\":{\"table_id\":1,\"store_id\":2,\"table_no\":\"A01\",\"capacity\":4,\"table_type\":null,\"status\":1,\"min_consumption\":0.0,\"created_at\":\"0001-01-01T00:00:00\",\"updated_at\":\"0001-01-01T00:00:00\",\"order_id\":null,\"order\":null,\"desc\":\"四人桌（一楼大厅）\"}}', 2, 6, '2025-08-21 10:17:19', 6, '2025-08-21 10:17:19');
INSERT INTO `sys_operationlog` VALUES (593, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-21 10:17:19', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:17:19', 6, '2025-08-21 10:17:19');
INSERT INTO `sys_operationlog` VALUES (594, 6, 1, '系统设置>角色管理', '修改桌台', '2025-08-21 10:18:23', '{\"sys_Table\":{\"table_id\":1,\"store_id\":2,\"table_no\":\"A01\",\"capacity\":4,\"table_type\":null,\"status\":1,\"min_consumption\":0.0,\"created_at\":\"0001-01-01T00:00:00\",\"updated_at\":\"0001-01-01T00:00:00\",\"order_id\":null,\"order\":null,\"desc\":\"四人桌（一楼大厅）\"}}', 2, 6, '2025-08-21 10:18:23', 6, '2025-08-21 10:18:23');
INSERT INTO `sys_operationlog` VALUES (595, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-21 10:18:23', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:18:23', 6, '2025-08-21 10:18:23');
INSERT INTO `sys_operationlog` VALUES (596, 6, 10, '系统登陆', '人员登陆', '2025-08-21 10:18:59', '账号：lq,员工姓名：lq', 2, 6, '2025-08-21 10:18:59', 6, '2025-08-21 10:18:59');
INSERT INTO `sys_operationlog` VALUES (597, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 10:19:02', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:19:02', 6, '2025-08-21 10:19:02');
INSERT INTO `sys_operationlog` VALUES (598, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-21 10:19:06', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:19:06', 6, '2025-08-21 10:19:06');
INSERT INTO `sys_operationlog` VALUES (599, 6, 1, '系统设置>角色管理', '修改桌台', '2025-08-21 10:19:11', '{\"sys_Table\":{\"table_id\":1,\"store_id\":2,\"table_no\":\"A01\",\"capacity\":4,\"table_type\":null,\"status\":1,\"min_consumption\":0.0,\"created_at\":\"0001-01-01T00:00:00\",\"updated_at\":\"0001-01-01T00:00:00\",\"order_id\":null,\"desc\":\"四人桌（一楼大厅）\",\"order\":null}}', 2, 6, '2025-08-21 10:19:11', 6, '2025-08-21 10:19:11');
INSERT INTO `sys_operationlog` VALUES (600, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-21 10:19:12', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:19:12', 6, '2025-08-21 10:19:12');
INSERT INTO `sys_operationlog` VALUES (601, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-21 10:19:14', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:19:14', 6, '2025-08-21 10:19:14');
INSERT INTO `sys_operationlog` VALUES (602, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-21 10:19:14', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:19:14', 6, '2025-08-21 10:19:14');
INSERT INTO `sys_operationlog` VALUES (603, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-21 10:19:15', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:19:15', 6, '2025-08-21 10:19:15');
INSERT INTO `sys_operationlog` VALUES (604, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 10:19:18', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:19:18', 6, '2025-08-21 10:19:18');
INSERT INTO `sys_operationlog` VALUES (605, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-21 10:19:18', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:19:18', 6, '2025-08-21 10:19:18');
INSERT INTO `sys_operationlog` VALUES (606, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-21 10:19:22', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:19:22', 6, '2025-08-21 10:19:22');
INSERT INTO `sys_operationlog` VALUES (607, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 10:19:34', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 10:19:34', 6, '2025-08-21 10:19:34');
INSERT INTO `sys_operationlog` VALUES (608, 6, 10, '系统登陆', '人员登陆', '2025-08-21 11:14:47', '账号：lq,员工姓名：lq', 2, 6, '2025-08-21 11:14:47', 6, '2025-08-21 11:14:47');
INSERT INTO `sys_operationlog` VALUES (609, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-21 11:14:50', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 11:14:50', 6, '2025-08-21 11:14:50');
INSERT INTO `sys_operationlog` VALUES (610, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-21 11:42:00', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-21 11:42:00', 6, '2025-08-21 11:42:00');
INSERT INTO `sys_operationlog` VALUES (611, 6, 10, '系统登陆', '人员登陆', '2025-08-22 09:12:08', '账号：lq,员工姓名：lq', 2, 6, '2025-08-22 09:12:08', 6, '2025-08-22 09:12:08');
INSERT INTO `sys_operationlog` VALUES (612, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 09:12:11', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 09:12:11', 6, '2025-08-22 09:12:11');
INSERT INTO `sys_operationlog` VALUES (613, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 09:12:51', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 09:12:51', 6, '2025-08-22 09:12:51');
INSERT INTO `sys_operationlog` VALUES (614, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 09:14:21', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 09:14:21', 6, '2025-08-22 09:14:21');
INSERT INTO `sys_operationlog` VALUES (615, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 09:15:48', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 09:15:48', 6, '2025-08-22 09:15:48');
INSERT INTO `sys_operationlog` VALUES (616, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 09:16:10', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 09:16:10', 6, '2025-08-22 09:16:10');
INSERT INTO `sys_operationlog` VALUES (617, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 09:24:12', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 09:24:12', 6, '2025-08-22 09:24:12');
INSERT INTO `sys_operationlog` VALUES (618, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 09:25:22', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 09:25:22', 6, '2025-08-22 09:25:22');
INSERT INTO `sys_operationlog` VALUES (619, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 09:26:28', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 09:26:28', 6, '2025-08-22 09:26:28');
INSERT INTO `sys_operationlog` VALUES (620, 6, 10, '系统登陆', '人员登陆', '2025-08-22 11:14:34', '账号：lq,员工姓名：lq', 2, 6, '2025-08-22 11:14:34', 6, '2025-08-22 11:14:34');
INSERT INTO `sys_operationlog` VALUES (621, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 11:14:37', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 11:14:37', 6, '2025-08-22 11:14:37');
INSERT INTO `sys_operationlog` VALUES (622, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 11:31:12', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 11:31:12', 6, '2025-08-22 11:31:12');
INSERT INTO `sys_operationlog` VALUES (623, 6, 4, '订单管理', '获取订单明细', '2025-08-22 11:31:36', '{\"orderId\":5}', 2, 6, '2025-08-22 11:31:36', 6, '2025-08-22 11:31:36');
INSERT INTO `sys_operationlog` VALUES (624, 6, 4, '订单管理', '获取订单明细', '2025-08-22 11:31:55', '{\"orderId\":5}', 2, 6, '2025-08-22 11:31:55', 6, '2025-08-22 11:31:55');
INSERT INTO `sys_operationlog` VALUES (625, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 11:31:55', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 11:31:55', 6, '2025-08-22 11:31:55');
INSERT INTO `sys_operationlog` VALUES (626, 6, 4, '订单管理', '获取订单明细', '2025-08-22 11:31:57', '{\"orderId\":5}', 2, 6, '2025-08-22 11:31:57', 6, '2025-08-22 11:31:57');
INSERT INTO `sys_operationlog` VALUES (627, 6, 4, '订单管理', '获取订单明细', '2025-08-22 11:34:20', '{\"orderId\":5}', 2, 6, '2025-08-22 11:34:20', 6, '2025-08-22 11:34:20');
INSERT INTO `sys_operationlog` VALUES (628, 6, 4, '订单管理', '获取订单明细', '2025-08-22 11:34:55', '{\"orderId\":5}', 2, 6, '2025-08-22 11:34:55', 6, '2025-08-22 11:34:55');
INSERT INTO `sys_operationlog` VALUES (629, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-22 11:35:08', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 11:35:08', 6, '2025-08-22 11:35:08');
INSERT INTO `sys_operationlog` VALUES (630, 6, 1, '系统设置>角色管理', '修改桌台', '2025-08-22 11:35:18', '{\"sys_Table\":{\"table_id\":3,\"store_id\":2,\"table_no\":\"B01\",\"capacity\":6,\"table_type\":null,\"status\":2,\"min_consumption\":0.0,\"created_at\":\"0001-01-01T00:00:00\",\"updated_at\":\"0001-01-01T00:00:00\",\"order_id\":null,\"desc\":\"四人桌（一楼大厅）\",\"order\":null}}', 2, 6, '2025-08-22 11:35:18', 6, '2025-08-22 11:35:18');
INSERT INTO `sys_operationlog` VALUES (631, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-22 11:35:18', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 11:35:18', 6, '2025-08-22 11:35:18');
INSERT INTO `sys_operationlog` VALUES (632, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 11:35:20', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 11:35:20', 6, '2025-08-22 11:35:20');
INSERT INTO `sys_operationlog` VALUES (633, 6, 4, '订单管理', '获取订单明细', '2025-08-22 11:35:21', '{\"orderId\":5}', 2, 6, '2025-08-22 11:35:21', 6, '2025-08-22 11:35:21');
INSERT INTO `sys_operationlog` VALUES (634, 6, 4, '订单管理', '获取订单明细', '2025-08-22 11:41:42', '{\"orderId\":5}', 2, 6, '2025-08-22 11:41:42', 6, '2025-08-22 11:41:42');
INSERT INTO `sys_operationlog` VALUES (635, 6, 4, '订单管理', '获取订单明细', '2025-08-22 11:42:12', '{\"orderId\":5}', 2, 6, '2025-08-22 11:42:12', 6, '2025-08-22 11:42:12');
INSERT INTO `sys_operationlog` VALUES (636, 6, 4, '订单管理', '获取订单明细', '2025-08-22 11:42:21', '{\"orderId\":5}', 2, 6, '2025-08-22 11:42:21', 6, '2025-08-22 11:42:21');
INSERT INTO `sys_operationlog` VALUES (637, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 11:42:21', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 11:42:21', 6, '2025-08-22 11:42:21');
INSERT INTO `sys_operationlog` VALUES (638, 6, 4, '订单管理', '获取订单明细', '2025-08-22 11:42:22', '{\"orderId\":5}', 2, 6, '2025-08-22 11:42:22', 6, '2025-08-22 11:42:22');
INSERT INTO `sys_operationlog` VALUES (639, 6, 4, '订单管理', '获取订单明细', '2025-08-22 11:42:42', '{\"orderId\":5}', 2, 6, '2025-08-22 11:42:42', 6, '2025-08-22 11:42:42');
INSERT INTO `sys_operationlog` VALUES (640, 6, 4, '订单管理', '获取订单明细', '2025-08-22 11:44:41', '{\"orderId\":5}', 2, 6, '2025-08-22 11:44:41', 6, '2025-08-22 11:44:41');
INSERT INTO `sys_operationlog` VALUES (641, 6, 4, '订单管理', '获取订单明细', '2025-08-22 11:47:55', '{\"orderId\":5}', 2, 6, '2025-08-22 11:47:55', 6, '2025-08-22 11:47:55');
INSERT INTO `sys_operationlog` VALUES (642, 6, 4, '订单管理', '获取订单明细', '2025-08-22 11:49:27', '{\"orderId\":5}', 2, 6, '2025-08-22 11:49:27', 6, '2025-08-22 11:49:27');
INSERT INTO `sys_operationlog` VALUES (643, 6, 10, '系统登陆', '人员登陆', '2025-08-22 11:52:19', '账号：lq,员工姓名：lq', 2, 6, '2025-08-22 11:52:19', 6, '2025-08-22 11:52:19');
INSERT INTO `sys_operationlog` VALUES (644, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 11:52:22', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 11:52:22', 6, '2025-08-22 11:52:22');
INSERT INTO `sys_operationlog` VALUES (645, 6, 4, '订单管理', '获取订单明细', '2025-08-22 11:52:23', '{\"orderId\":5}', 2, 6, '2025-08-22 11:52:23', 6, '2025-08-22 11:52:23');
INSERT INTO `sys_operationlog` VALUES (646, 6, 4, '订单管理', '获取订单明细', '2025-08-22 11:53:11', '{\"orderId\":5}', 2, 6, '2025-08-22 11:53:11', 6, '2025-08-22 11:53:11');
INSERT INTO `sys_operationlog` VALUES (647, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-22 11:54:35', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 11:54:35', 6, '2025-08-22 11:54:35');
INSERT INTO `sys_operationlog` VALUES (648, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-22 11:54:46', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 11:54:46', 6, '2025-08-22 11:54:46');
INSERT INTO `sys_operationlog` VALUES (649, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 13:54:02', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 13:54:02', 6, '2025-08-22 13:54:02');
INSERT INTO `sys_operationlog` VALUES (650, 6, 4, '订单管理', '获取订单明细', '2025-08-22 13:54:04', '{\"orderId\":5}', 2, 6, '2025-08-22 13:54:04', 6, '2025-08-22 13:54:04');
INSERT INTO `sys_operationlog` VALUES (651, 6, 10, '系统登陆', '人员登陆', '2025-08-22 14:14:17', '账号：lq,员工姓名：lq', 2, 6, '2025-08-22 14:14:17', 6, '2025-08-22 14:14:17');
INSERT INTO `sys_operationlog` VALUES (652, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 14:14:17', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 14:14:17', 6, '2025-08-22 14:14:17');
INSERT INTO `sys_operationlog` VALUES (653, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:16:52', '{\"orderId\":5}', 2, 6, '2025-08-22 14:16:52', 6, '2025-08-22 14:16:52');
INSERT INTO `sys_operationlog` VALUES (654, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:16:56', '{\"orderId\":5}', 2, 6, '2025-08-22 14:16:56', 6, '2025-08-22 14:16:56');
INSERT INTO `sys_operationlog` VALUES (655, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 14:16:56', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 14:16:56', 6, '2025-08-22 14:16:56');
INSERT INTO `sys_operationlog` VALUES (656, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:16:58', '{\"orderId\":5}', 2, 6, '2025-08-22 14:16:58', 6, '2025-08-22 14:16:58');
INSERT INTO `sys_operationlog` VALUES (657, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:17:49', '{\"orderId\":5}', 2, 6, '2025-08-22 14:17:49', 6, '2025-08-22 14:17:49');
INSERT INTO `sys_operationlog` VALUES (658, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 14:17:49', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 14:17:49', 6, '2025-08-22 14:17:49');
INSERT INTO `sys_operationlog` VALUES (659, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:17:50', '{\"orderId\":5}', 2, 6, '2025-08-22 14:17:50', 6, '2025-08-22 14:17:50');
INSERT INTO `sys_operationlog` VALUES (660, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:18:10', '{\"orderId\":5}', 2, 6, '2025-08-22 14:18:10', 6, '2025-08-22 14:18:10');
INSERT INTO `sys_operationlog` VALUES (661, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 14:18:10', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 14:18:10', 6, '2025-08-22 14:18:10');
INSERT INTO `sys_operationlog` VALUES (662, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:18:11', '{\"orderId\":5}', 2, 6, '2025-08-22 14:18:11', 6, '2025-08-22 14:18:11');
INSERT INTO `sys_operationlog` VALUES (663, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:19:12', '{\"orderId\":5}', 2, 6, '2025-08-22 14:19:12', 6, '2025-08-22 14:19:12');
INSERT INTO `sys_operationlog` VALUES (664, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:19:18', '{\"orderId\":5}', 2, 6, '2025-08-22 14:19:18', 6, '2025-08-22 14:19:18');
INSERT INTO `sys_operationlog` VALUES (665, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 14:19:18', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 14:19:18', 6, '2025-08-22 14:19:18');
INSERT INTO `sys_operationlog` VALUES (666, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:19:19', '{\"orderId\":5}', 2, 6, '2025-08-22 14:19:19', 6, '2025-08-22 14:19:19');
INSERT INTO `sys_operationlog` VALUES (667, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:19:36', '{\"orderId\":5}', 2, 6, '2025-08-22 14:19:36', 6, '2025-08-22 14:19:36');
INSERT INTO `sys_operationlog` VALUES (668, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 14:19:36', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 14:19:36', 6, '2025-08-22 14:19:36');
INSERT INTO `sys_operationlog` VALUES (669, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:19:37', '{\"orderId\":5}', 2, 6, '2025-08-22 14:19:37', 6, '2025-08-22 14:19:37');
INSERT INTO `sys_operationlog` VALUES (670, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:20:54', '{\"orderId\":5}', 2, 6, '2025-08-22 14:20:54', 6, '2025-08-22 14:20:54');
INSERT INTO `sys_operationlog` VALUES (671, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:21:09', '{\"orderId\":5}', 2, 6, '2025-08-22 14:21:09', 6, '2025-08-22 14:21:09');
INSERT INTO `sys_operationlog` VALUES (672, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 14:21:09', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 14:21:09', 6, '2025-08-22 14:21:09');
INSERT INTO `sys_operationlog` VALUES (673, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:21:09', '{\"orderId\":5}', 2, 6, '2025-08-22 14:21:09', 6, '2025-08-22 14:21:09');
INSERT INTO `sys_operationlog` VALUES (674, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:21:45', '{\"orderId\":5}', 2, 6, '2025-08-22 14:21:45', 6, '2025-08-22 14:21:45');
INSERT INTO `sys_operationlog` VALUES (675, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:22:11', '{\"orderId\":5}', 2, 6, '2025-08-22 14:22:11', 6, '2025-08-22 14:22:11');
INSERT INTO `sys_operationlog` VALUES (676, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:22:34', '{\"orderId\":5}', 2, 6, '2025-08-22 14:22:34', 6, '2025-08-22 14:22:34');
INSERT INTO `sys_operationlog` VALUES (677, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 14:22:34', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 14:22:34', 6, '2025-08-22 14:22:34');
INSERT INTO `sys_operationlog` VALUES (678, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 14:22:49', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 14:22:49', 6, '2025-08-22 14:22:49');
INSERT INTO `sys_operationlog` VALUES (679, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:22:53', '{\"orderId\":5}', 2, 6, '2025-08-22 14:22:53', 6, '2025-08-22 14:22:53');
INSERT INTO `sys_operationlog` VALUES (680, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:23:24', '{\"orderId\":5}', 2, 6, '2025-08-22 14:23:24', 6, '2025-08-22 14:23:24');
INSERT INTO `sys_operationlog` VALUES (681, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:23:27', '{\"orderId\":5}', 2, 6, '2025-08-22 14:23:27', 6, '2025-08-22 14:23:27');
INSERT INTO `sys_operationlog` VALUES (682, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 14:23:28', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 14:23:28', 6, '2025-08-22 14:23:28');
INSERT INTO `sys_operationlog` VALUES (683, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:23:30', '{\"orderId\":5}', 2, 6, '2025-08-22 14:23:30', 6, '2025-08-22 14:23:30');
INSERT INTO `sys_operationlog` VALUES (684, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:23:44', '{\"orderId\":5}', 2, 6, '2025-08-22 14:23:44', 6, '2025-08-22 14:23:44');
INSERT INTO `sys_operationlog` VALUES (685, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 14:23:45', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 14:23:45', 6, '2025-08-22 14:23:45');
INSERT INTO `sys_operationlog` VALUES (686, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:23:46', '{\"orderId\":5}', 2, 6, '2025-08-22 14:23:46', 6, '2025-08-22 14:23:46');
INSERT INTO `sys_operationlog` VALUES (687, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-22 14:24:18', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 14:24:18', 6, '2025-08-22 14:24:18');
INSERT INTO `sys_operationlog` VALUES (688, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 14:39:52', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 14:39:52', 6, '2025-08-22 14:39:52');
INSERT INTO `sys_operationlog` VALUES (689, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:39:53', '{\"orderId\":5}', 2, 6, '2025-08-22 14:39:53', 6, '2025-08-22 14:39:53');
INSERT INTO `sys_operationlog` VALUES (690, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 14:47:11', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 14:47:11', 6, '2025-08-22 14:47:11');
INSERT INTO `sys_operationlog` VALUES (691, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:47:14', '{\"orderId\":5}', 2, 6, '2025-08-22 14:47:14', 6, '2025-08-22 14:47:14');
INSERT INTO `sys_operationlog` VALUES (692, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:49:09', '{\"orderId\":5}', 2, 6, '2025-08-22 14:49:09', 6, '2025-08-22 14:49:09');
INSERT INTO `sys_operationlog` VALUES (693, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:49:34', '{\"orderId\":5}', 2, 6, '2025-08-22 14:49:34', 6, '2025-08-22 14:49:34');
INSERT INTO `sys_operationlog` VALUES (694, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:49:48', '{\"orderId\":5}', 2, 6, '2025-08-22 14:49:48', 6, '2025-08-22 14:49:48');
INSERT INTO `sys_operationlog` VALUES (695, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:50:33', '{\"orderId\":5}', 2, 6, '2025-08-22 14:50:33', 6, '2025-08-22 14:50:33');
INSERT INTO `sys_operationlog` VALUES (696, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:52:05', '{\"orderId\":5}', 2, 6, '2025-08-22 14:52:05', 6, '2025-08-22 14:52:05');
INSERT INTO `sys_operationlog` VALUES (697, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:53:12', '{\"orderId\":5}', 2, 6, '2025-08-22 14:53:12', 6, '2025-08-22 14:53:12');
INSERT INTO `sys_operationlog` VALUES (698, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:53:54', '{\"orderId\":5}', 2, 6, '2025-08-22 14:53:54', 6, '2025-08-22 14:53:54');
INSERT INTO `sys_operationlog` VALUES (699, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 14:54:36', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 14:54:36', 6, '2025-08-22 14:54:36');
INSERT INTO `sys_operationlog` VALUES (700, 6, 4, '订单管理', '获取订单明细', '2025-08-22 14:54:38', '{\"orderId\":5}', 2, 6, '2025-08-22 14:54:38', 6, '2025-08-22 14:54:38');
INSERT INTO `sys_operationlog` VALUES (701, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 14:54:39', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 14:54:39', 6, '2025-08-22 14:54:39');
INSERT INTO `sys_operationlog` VALUES (702, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 15:04:09', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 15:04:09', 6, '2025-08-22 15:04:09');
INSERT INTO `sys_operationlog` VALUES (703, 6, 4, '订单管理', '获取订单明细', '2025-08-22 15:04:10', '{\"orderId\":5}', 2, 6, '2025-08-22 15:04:10', 6, '2025-08-22 15:04:10');
INSERT INTO `sys_operationlog` VALUES (704, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 15:27:47', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 15:27:47', 6, '2025-08-22 15:27:47');
INSERT INTO `sys_operationlog` VALUES (705, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 15:29:14', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 15:29:14', 6, '2025-08-22 15:29:14');
INSERT INTO `sys_operationlog` VALUES (706, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-22 15:31:52', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 15:31:52', 6, '2025-08-22 15:31:52');
INSERT INTO `sys_operationlog` VALUES (707, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-22 15:37:36', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 15:37:36', 6, '2025-08-22 15:37:36');
INSERT INTO `sys_operationlog` VALUES (708, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-22 15:38:55', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 15:38:55', 6, '2025-08-22 15:38:55');
INSERT INTO `sys_operationlog` VALUES (709, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-22 15:48:14', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 15:48:14', 6, '2025-08-22 15:48:14');
INSERT INTO `sys_operationlog` VALUES (710, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 15:52:34', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 15:52:34', 6, '2025-08-22 15:52:34');
INSERT INTO `sys_operationlog` VALUES (711, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 15:52:45', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 15:52:45', 6, '2025-08-22 15:52:45');
INSERT INTO `sys_operationlog` VALUES (712, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 15:55:36', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 15:55:36', 6, '2025-08-22 15:55:36');
INSERT INTO `sys_operationlog` VALUES (713, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 15:55:52', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 15:55:52', 6, '2025-08-22 15:55:52');
INSERT INTO `sys_operationlog` VALUES (714, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 15:56:01', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 15:56:01', 6, '2025-08-22 15:56:01');
INSERT INTO `sys_operationlog` VALUES (715, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 15:57:38', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 15:57:38', 6, '2025-08-22 15:57:38');
INSERT INTO `sys_operationlog` VALUES (716, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 15:57:40', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 15:57:40', 6, '2025-08-22 15:57:40');
INSERT INTO `sys_operationlog` VALUES (717, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 15:58:23', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 15:58:23', 6, '2025-08-22 15:58:23');
INSERT INTO `sys_operationlog` VALUES (718, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 15:58:27', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 15:58:27', 6, '2025-08-22 15:58:27');
INSERT INTO `sys_operationlog` VALUES (719, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 15:58:31', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 15:58:31', 6, '2025-08-22 15:58:31');
INSERT INTO `sys_operationlog` VALUES (720, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 16:00:19', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 16:00:19', 6, '2025-08-22 16:00:19');
INSERT INTO `sys_operationlog` VALUES (721, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 16:00:39', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 16:00:39', 6, '2025-08-22 16:00:39');
INSERT INTO `sys_operationlog` VALUES (722, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 16:01:09', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 16:01:09', 6, '2025-08-22 16:01:09');
INSERT INTO `sys_operationlog` VALUES (723, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 16:01:14', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 16:01:14', 6, '2025-08-22 16:01:14');
INSERT INTO `sys_operationlog` VALUES (724, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-22 16:01:26', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 16:01:26', 6, '2025-08-22 16:01:26');
INSERT INTO `sys_operationlog` VALUES (725, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-22 16:01:28', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 16:01:28', 6, '2025-08-22 16:01:28');
INSERT INTO `sys_operationlog` VALUES (726, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-22 16:01:28', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 16:01:28', 6, '2025-08-22 16:01:28');
INSERT INTO `sys_operationlog` VALUES (727, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-22 16:01:29', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 16:01:29', 6, '2025-08-22 16:01:29');
INSERT INTO `sys_operationlog` VALUES (728, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-22 16:01:35', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 16:01:35', 6, '2025-08-22 16:01:35');
INSERT INTO `sys_operationlog` VALUES (729, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-22 16:01:45', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 16:01:45', 6, '2025-08-22 16:01:45');
INSERT INTO `sys_operationlog` VALUES (730, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 16:13:59', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 16:13:59', 6, '2025-08-22 16:13:59');
INSERT INTO `sys_operationlog` VALUES (731, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 16:22:43', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 16:22:43', 6, '2025-08-22 16:22:43');
INSERT INTO `sys_operationlog` VALUES (732, 6, 4, '订单管理', '获取订单明细', '2025-08-22 16:22:45', '{\"orderId\":5}', 2, 6, '2025-08-22 16:22:45', 6, '2025-08-22 16:22:45');
INSERT INTO `sys_operationlog` VALUES (733, 6, 4, '系统设置>角色管理', '菜品分类管理查询', '2025-08-22 16:45:47', '{\"name\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 16:45:47', 6, '2025-08-22 16:45:47');
INSERT INTO `sys_operationlog` VALUES (734, 6, 10, '系统登陆', '人员登陆', '2025-08-22 17:04:17', '账号：lq,员工姓名：lq', 2, 6, '2025-08-22 17:04:17', 6, '2025-08-22 17:04:17');
INSERT INTO `sys_operationlog` VALUES (735, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 17:04:17', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 17:04:17', 6, '2025-08-22 17:04:17');
INSERT INTO `sys_operationlog` VALUES (736, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-22 17:04:21', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 17:04:21', 6, '2025-08-22 17:04:21');
INSERT INTO `sys_operationlog` VALUES (737, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-22 17:22:40', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 17:22:40', 6, '2025-08-22 17:22:40');
INSERT INTO `sys_operationlog` VALUES (738, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-22 17:28:25', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-22 17:28:25', 6, '2025-08-22 17:28:25');
INSERT INTO `sys_operationlog` VALUES (739, 6, 10, '系统登陆', '人员登陆', '2025-08-25 08:51:34', '账号：lq,员工姓名：lq', 2, 6, '2025-08-25 08:51:34', 6, '2025-08-25 08:51:34');
INSERT INTO `sys_operationlog` VALUES (740, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 08:51:37', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 08:51:37', 6, '2025-08-25 08:51:37');
INSERT INTO `sys_operationlog` VALUES (741, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 08:51:44', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 08:51:44', 6, '2025-08-25 08:51:44');
INSERT INTO `sys_operationlog` VALUES (742, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 08:53:31', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 2, 6, '2025-08-25 08:53:31', 6, '2025-08-25 08:53:31');
INSERT INTO `sys_operationlog` VALUES (743, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 08:54:15', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 2, 6, '2025-08-25 08:54:15', 6, '2025-08-25 08:54:15');
INSERT INTO `sys_operationlog` VALUES (744, 6, 4, '系统设置>角色管理', '菜品分类管理查询', '2025-08-25 08:54:17', '{\"name\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 08:54:17', 6, '2025-08-25 08:54:17');
INSERT INTO `sys_operationlog` VALUES (745, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 09:19:55', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 2, 6, '2025-08-25 09:19:55', 6, '2025-08-25 09:19:55');
INSERT INTO `sys_operationlog` VALUES (746, 6, 4, '系统设置>角色管理', '菜品分类管理查询', '2025-08-25 09:20:06', '{\"name\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 09:20:06', 6, '2025-08-25 09:20:06');
INSERT INTO `sys_operationlog` VALUES (747, 6, 4, '系统设置>角色管理', '菜品分类管理查询', '2025-08-25 09:23:38', '{\"name\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 09:23:38', 6, '2025-08-25 09:23:38');
INSERT INTO `sys_operationlog` VALUES (748, 2, 10, '系统登陆', '人员登陆', '2025-08-25 10:03:11', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-25 10:03:11', 2, '2025-08-25 10:03:11');
INSERT INTO `sys_operationlog` VALUES (749, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 10:03:18', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 10:03:18', 2, '2025-08-25 10:03:18');
INSERT INTO `sys_operationlog` VALUES (750, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 10:03:48', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 10:03:48', 2, '2025-08-25 10:03:48');
INSERT INTO `sys_operationlog` VALUES (751, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-25 10:04:01', '{\"roleId\":3,\"permissionIds\":[1,13,2,14,15,16,3,18,19,4,20,21,22,23,5,24,25,26,27,6,28,29,52,7,30,31,32,33,8,34,35,36,37,9,38,39,40,10,41,42,43,11,44,45,46,47]}', 1, 2, '2025-08-25 10:04:01', 2, '2025-08-25 10:04:01');
INSERT INTO `sys_operationlog` VALUES (752, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 10:04:05', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 10:04:05', 2, '2025-08-25 10:04:05');
INSERT INTO `sys_operationlog` VALUES (753, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 10:04:15', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 10:04:15', 2, '2025-08-25 10:04:15');
INSERT INTO `sys_operationlog` VALUES (754, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 10:14:18', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 10:14:18', 2, '2025-08-25 10:14:18');
INSERT INTO `sys_operationlog` VALUES (755, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-25 10:16:25', '{\"roleId\":1,\"permissionIds\":[1,13,2,14,15,16,3,18,19,4,20,21,22,23,5,24,25,26,27,6,28,29,52,7,30,31,32,33,8,34,35,36,37,9,38,39,40,10,41,42,43,11,44,45,46,47,12,48,49,50,51]}', 1, 2, '2025-08-25 10:16:25', 2, '2025-08-25 10:16:25');
INSERT INTO `sys_operationlog` VALUES (756, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-25 10:16:31', '{\"roleId\":3,\"permissionIds\":[1,13,2,14,15,16,3,18,19,4,20,21,22,23,5,24,25,26,27,28,29,7,30,31,32,33,8,34,35,36,37,9,38,39,40,10,41,42,43,11,44,45,46,47,12,48,49,50,51,6]}', 1, 2, '2025-08-25 10:16:31', 2, '2025-08-25 10:16:31');
INSERT INTO `sys_operationlog` VALUES (757, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 10:16:44', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 10:16:44', 2, '2025-08-25 10:16:44');
INSERT INTO `sys_operationlog` VALUES (758, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 10:16:49', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 10:16:49', 2, '2025-08-25 10:16:49');
INSERT INTO `sys_operationlog` VALUES (759, 2, 10, '系统登陆', '人员登陆', '2025-08-25 10:30:27', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-25 10:30:27', 2, '2025-08-25 10:30:27');
INSERT INTO `sys_operationlog` VALUES (760, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 10:30:40', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 10:30:40', 2, '2025-08-25 10:30:40');
INSERT INTO `sys_operationlog` VALUES (761, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 10:31:19', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 10:31:19', 2, '2025-08-25 10:31:19');
INSERT INTO `sys_operationlog` VALUES (762, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 10:35:11', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 10:35:11', 2, '2025-08-25 10:35:11');
INSERT INTO `sys_operationlog` VALUES (763, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 10:36:33', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 10:36:33', 2, '2025-08-25 10:36:33');
INSERT INTO `sys_operationlog` VALUES (764, 2, 10, '系统登陆', '人员登陆', '2025-08-25 10:39:24', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-25 10:39:24', 2, '2025-08-25 10:39:24');
INSERT INTO `sys_operationlog` VALUES (765, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 10:39:28', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 10:39:28', 2, '2025-08-25 10:39:28');
INSERT INTO `sys_operationlog` VALUES (766, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 10:41:53', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 10:41:53', 2, '2025-08-25 10:41:53');
INSERT INTO `sys_operationlog` VALUES (767, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 10:55:34', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 10:55:34', 2, '2025-08-25 10:55:34');
INSERT INTO `sys_operationlog` VALUES (768, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 10:56:05', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 10:56:05', 2, '2025-08-25 10:56:05');
INSERT INTO `sys_operationlog` VALUES (769, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 10:56:09', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 10:56:09', 2, '2025-08-25 10:56:09');
INSERT INTO `sys_operationlog` VALUES (770, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 10:57:15', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 10:57:15', 2, '2025-08-25 10:57:15');
INSERT INTO `sys_operationlog` VALUES (771, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 10:59:48', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 10:59:48', 2, '2025-08-25 10:59:48');
INSERT INTO `sys_operationlog` VALUES (772, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 10:59:58', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 10:59:58', 2, '2025-08-25 10:59:58');
INSERT INTO `sys_operationlog` VALUES (773, 2, 10, '系统登陆', '人员登陆', '2025-08-25 11:00:25', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-25 11:00:25', 2, '2025-08-25 11:00:25');
INSERT INTO `sys_operationlog` VALUES (774, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 11:00:30', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 11:00:30', 2, '2025-08-25 11:00:30');
INSERT INTO `sys_operationlog` VALUES (775, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 11:02:13', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 11:02:13', 2, '2025-08-25 11:02:13');
INSERT INTO `sys_operationlog` VALUES (776, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 11:15:09', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 11:15:09', 2, '2025-08-25 11:15:09');
INSERT INTO `sys_operationlog` VALUES (777, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-25 11:19:24', '{\"roleId\":1,\"permissionIds\":[1,13,2,14,15,16,3,18,19,4,20,21,22,23,5,24,25,26,27,6,28,29,52,7,30,31,32,33,8,34,35,36,37,9,38,39,40,10,41,42,43,11,44,45,46,47,12,48,49,50,51]}', 1, 2, '2025-08-25 11:19:24', 2, '2025-08-25 11:19:24');
INSERT INTO `sys_operationlog` VALUES (778, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-25 11:19:32', '{\"roleId\":3,\"permissionIds\":[1,13,2,14,15,16,3,18,19,4,20,21,22,23,5,24,25,26,27,6,28,29,52,7,30,31,32,33,8,34,35,36,37,9,38,39,40,10,41,42,43,11,44,45,46,47,48,49,50,51]}', 1, 2, '2025-08-25 11:19:32', 2, '2025-08-25 11:19:32');
INSERT INTO `sys_operationlog` VALUES (779, 2, 11, '账号登出', '人员退出系统', '2025-08-25 11:19:39', '{}', 1, 2, '2025-08-25 11:19:39', 2, '2025-08-25 11:19:39');
INSERT INTO `sys_operationlog` VALUES (780, 6, 10, '系统登陆', '人员登陆', '2025-08-25 11:19:44', '账号：lq,员工姓名：lq', 2, 6, '2025-08-25 11:19:44', 6, '2025-08-25 11:19:44');
INSERT INTO `sys_operationlog` VALUES (781, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 11:19:45', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 11:19:45', 6, '2025-08-25 11:19:45');
INSERT INTO `sys_operationlog` VALUES (782, 6, 10, '系统登陆', '人员登陆', '2025-08-25 11:56:36', '账号：lq,员工姓名：lq', 2, 6, '2025-08-25 11:56:36', 6, '2025-08-25 11:56:36');
INSERT INTO `sys_operationlog` VALUES (783, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 11:56:39', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 11:56:39', 6, '2025-08-25 11:56:39');
INSERT INTO `sys_operationlog` VALUES (784, 6, 10, '系统登陆', '人员登陆', '2025-08-25 13:36:40', '账号：lq,员工姓名：lq', 2, 6, '2025-08-25 13:36:40', 6, '2025-08-25 13:36:40');
INSERT INTO `sys_operationlog` VALUES (785, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 13:36:42', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 13:36:42', 6, '2025-08-25 13:36:42');
INSERT INTO `sys_operationlog` VALUES (786, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 13:40:59', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 2, 6, '2025-08-25 13:40:59', 6, '2025-08-25 13:40:59');
INSERT INTO `sys_operationlog` VALUES (787, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 15:16:11', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 15:16:11', 6, '2025-08-25 15:16:11');
INSERT INTO `sys_operationlog` VALUES (788, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 15:39:11', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 15:39:11', 6, '2025-08-25 15:39:11');
INSERT INTO `sys_operationlog` VALUES (789, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 15:40:19', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 15:40:19', 6, '2025-08-25 15:40:19');
INSERT INTO `sys_operationlog` VALUES (790, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 15:40:26', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 2, 6, '2025-08-25 15:40:26', 6, '2025-08-25 15:40:26');
INSERT INTO `sys_operationlog` VALUES (791, 6, 4, '系统设置>角色管理', '菜品分类管理查询', '2025-08-25 15:40:27', '{\"name\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 15:40:27', 6, '2025-08-25 15:40:27');
INSERT INTO `sys_operationlog` VALUES (792, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 15:43:16', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 2, 6, '2025-08-25 15:43:16', 6, '2025-08-25 15:43:16');
INSERT INTO `sys_operationlog` VALUES (793, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 15:43:22', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 15:43:22', 6, '2025-08-25 15:43:22');
INSERT INTO `sys_operationlog` VALUES (794, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 15:43:30', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 2, 6, '2025-08-25 15:43:30', 6, '2025-08-25 15:43:30');
INSERT INTO `sys_operationlog` VALUES (795, 6, 4, '系统设置>角色管理', '菜品分类管理查询', '2025-08-25 15:43:32', '{\"name\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 15:43:32', 6, '2025-08-25 15:43:32');
INSERT INTO `sys_operationlog` VALUES (796, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 15:46:53', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 2, 6, '2025-08-25 15:46:53', 6, '2025-08-25 15:46:53');
INSERT INTO `sys_operationlog` VALUES (797, 6, 4, '系统设置>角色管理', '菜品分类管理查询', '2025-08-25 15:46:54', '{\"name\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 15:46:54', 6, '2025-08-25 15:46:54');
INSERT INTO `sys_operationlog` VALUES (798, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 15:51:35', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 2, 6, '2025-08-25 15:51:35', 6, '2025-08-25 15:51:35');
INSERT INTO `sys_operationlog` VALUES (799, 6, 4, '系统设置>角色管理', '菜品分类管理查询', '2025-08-25 15:51:36', '{\"name\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 15:51:36', 6, '2025-08-25 15:51:36');
INSERT INTO `sys_operationlog` VALUES (800, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 15:56:21', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 15:56:21', 6, '2025-08-25 15:56:21');
INSERT INTO `sys_operationlog` VALUES (801, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 15:56:21', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 15:56:21', 6, '2025-08-25 15:56:21');
INSERT INTO `sys_operationlog` VALUES (802, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 15:56:33', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 15:56:33', 6, '2025-08-25 15:56:33');
INSERT INTO `sys_operationlog` VALUES (803, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 15:56:46', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 15:56:46', 6, '2025-08-25 15:56:46');
INSERT INTO `sys_operationlog` VALUES (804, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 15:56:46', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 15:56:46', 6, '2025-08-25 15:56:46');
INSERT INTO `sys_operationlog` VALUES (805, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 15:58:15', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 15:58:15', 6, '2025-08-25 15:58:15');
INSERT INTO `sys_operationlog` VALUES (806, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 15:58:15', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 15:58:15', 6, '2025-08-25 15:58:15');
INSERT INTO `sys_operationlog` VALUES (807, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 15:58:43', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 15:58:43', 6, '2025-08-25 15:58:43');
INSERT INTO `sys_operationlog` VALUES (808, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:00:41', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:00:41', 6, '2025-08-25 16:00:41');
INSERT INTO `sys_operationlog` VALUES (809, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:00:41', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:00:41', 6, '2025-08-25 16:00:41');
INSERT INTO `sys_operationlog` VALUES (810, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:01:22', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:01:22', 6, '2025-08-25 16:01:22');
INSERT INTO `sys_operationlog` VALUES (811, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:01:31', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:01:31', 6, '2025-08-25 16:01:31');
INSERT INTO `sys_operationlog` VALUES (812, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:01:31', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:01:31', 6, '2025-08-25 16:01:31');
INSERT INTO `sys_operationlog` VALUES (813, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:01:45', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:01:45', 6, '2025-08-25 16:01:45');
INSERT INTO `sys_operationlog` VALUES (814, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:01:52', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:01:52', 6, '2025-08-25 16:01:52');
INSERT INTO `sys_operationlog` VALUES (815, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:01:52', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:01:52', 6, '2025-08-25 16:01:52');
INSERT INTO `sys_operationlog` VALUES (816, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:02:24', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:02:24', 6, '2025-08-25 16:02:24');
INSERT INTO `sys_operationlog` VALUES (817, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:02:43', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:02:43', 6, '2025-08-25 16:02:43');
INSERT INTO `sys_operationlog` VALUES (818, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:02:46', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:02:46', 6, '2025-08-25 16:02:46');
INSERT INTO `sys_operationlog` VALUES (819, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:02:51', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:02:51', 6, '2025-08-25 16:02:51');
INSERT INTO `sys_operationlog` VALUES (820, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:02:51', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:02:51', 6, '2025-08-25 16:02:51');
INSERT INTO `sys_operationlog` VALUES (821, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:03:41', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:03:41', 6, '2025-08-25 16:03:41');
INSERT INTO `sys_operationlog` VALUES (822, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:04:38', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:04:38', 6, '2025-08-25 16:04:38');
INSERT INTO `sys_operationlog` VALUES (823, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:05:05', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:05:05', 6, '2025-08-25 16:05:05');
INSERT INTO `sys_operationlog` VALUES (824, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:05:15', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:05:15', 6, '2025-08-25 16:05:15');
INSERT INTO `sys_operationlog` VALUES (825, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:05:15', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:05:15', 6, '2025-08-25 16:05:15');
INSERT INTO `sys_operationlog` VALUES (826, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:05:28', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:05:28', 6, '2025-08-25 16:05:28');
INSERT INTO `sys_operationlog` VALUES (827, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:05:28', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:05:28', 6, '2025-08-25 16:05:28');
INSERT INTO `sys_operationlog` VALUES (828, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:16:01', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:16:01', 6, '2025-08-25 16:16:01');
INSERT INTO `sys_operationlog` VALUES (829, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:16:01', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:16:01', 6, '2025-08-25 16:16:01');
INSERT INTO `sys_operationlog` VALUES (830, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:18:34', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:18:34', 6, '2025-08-25 16:18:34');
INSERT INTO `sys_operationlog` VALUES (831, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:18:40', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:18:40', 6, '2025-08-25 16:18:40');
INSERT INTO `sys_operationlog` VALUES (832, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:18:40', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:18:40', 6, '2025-08-25 16:18:40');
INSERT INTO `sys_operationlog` VALUES (833, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:18:42', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:18:42', 6, '2025-08-25 16:18:42');
INSERT INTO `sys_operationlog` VALUES (834, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:18:42', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:18:42', 6, '2025-08-25 16:18:42');
INSERT INTO `sys_operationlog` VALUES (835, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:18:42', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:18:42', 6, '2025-08-25 16:18:42');
INSERT INTO `sys_operationlog` VALUES (836, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:18:44', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:18:44', 6, '2025-08-25 16:18:44');
INSERT INTO `sys_operationlog` VALUES (837, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:18:44', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:18:44', 6, '2025-08-25 16:18:44');
INSERT INTO `sys_operationlog` VALUES (838, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:18:44', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:18:44', 6, '2025-08-25 16:18:44');
INSERT INTO `sys_operationlog` VALUES (839, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:18:46', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:18:46', 6, '2025-08-25 16:18:46');
INSERT INTO `sys_operationlog` VALUES (840, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:18:46', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:18:46', 6, '2025-08-25 16:18:46');
INSERT INTO `sys_operationlog` VALUES (841, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:18:46', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:18:46', 6, '2025-08-25 16:18:46');
INSERT INTO `sys_operationlog` VALUES (842, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:18:53', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:18:53', 6, '2025-08-25 16:18:53');
INSERT INTO `sys_operationlog` VALUES (843, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:18:53', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:18:53', 6, '2025-08-25 16:18:53');
INSERT INTO `sys_operationlog` VALUES (844, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:18:53', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:18:53', 6, '2025-08-25 16:18:53');
INSERT INTO `sys_operationlog` VALUES (845, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:19:01', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:19:01', 6, '2025-08-25 16:19:01');
INSERT INTO `sys_operationlog` VALUES (846, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:19:01', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:19:01', 6, '2025-08-25 16:19:01');
INSERT INTO `sys_operationlog` VALUES (847, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:19:01', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:19:01', 6, '2025-08-25 16:19:01');
INSERT INTO `sys_operationlog` VALUES (848, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:19:37', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:19:37', 6, '2025-08-25 16:19:37');
INSERT INTO `sys_operationlog` VALUES (849, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:19:37', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:19:37', 6, '2025-08-25 16:19:37');
INSERT INTO `sys_operationlog` VALUES (850, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:24:25', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:24:25', 6, '2025-08-25 16:24:25');
INSERT INTO `sys_operationlog` VALUES (851, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:24:25', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:24:25', 6, '2025-08-25 16:24:25');
INSERT INTO `sys_operationlog` VALUES (852, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:24:29', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:24:29', 6, '2025-08-25 16:24:29');
INSERT INTO `sys_operationlog` VALUES (853, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:24:29', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:24:29', 6, '2025-08-25 16:24:29');
INSERT INTO `sys_operationlog` VALUES (854, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:24:29', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:24:29', 6, '2025-08-25 16:24:29');
INSERT INTO `sys_operationlog` VALUES (855, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:24:31', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:24:31', 6, '2025-08-25 16:24:31');
INSERT INTO `sys_operationlog` VALUES (856, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:25:18', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:25:18', 6, '2025-08-25 16:25:18');
INSERT INTO `sys_operationlog` VALUES (857, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:25:18', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:25:18', 6, '2025-08-25 16:25:18');
INSERT INTO `sys_operationlog` VALUES (858, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:26:30', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:26:30', 6, '2025-08-25 16:26:30');
INSERT INTO `sys_operationlog` VALUES (859, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:26:30', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:26:30', 6, '2025-08-25 16:26:30');
INSERT INTO `sys_operationlog` VALUES (860, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:26:40', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:26:40', 6, '2025-08-25 16:26:40');
INSERT INTO `sys_operationlog` VALUES (861, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:26:40', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:26:40', 6, '2025-08-25 16:26:40');
INSERT INTO `sys_operationlog` VALUES (862, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:26:40', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:26:40', 6, '2025-08-25 16:26:40');
INSERT INTO `sys_operationlog` VALUES (863, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:27:32', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:27:32', 6, '2025-08-25 16:27:32');
INSERT INTO `sys_operationlog` VALUES (864, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:27:32', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:27:32', 6, '2025-08-25 16:27:32');
INSERT INTO `sys_operationlog` VALUES (865, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:31:39', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:31:39', 6, '2025-08-25 16:31:39');
INSERT INTO `sys_operationlog` VALUES (866, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:31:39', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:31:39', 6, '2025-08-25 16:31:39');
INSERT INTO `sys_operationlog` VALUES (867, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:31:52', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:31:52', 6, '2025-08-25 16:31:52');
INSERT INTO `sys_operationlog` VALUES (868, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 16:31:52', '{\"status\":null,\"tableCode\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:31:52', 6, '2025-08-25 16:31:52');
INSERT INTO `sys_operationlog` VALUES (869, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 16:32:01', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:32:01', 6, '2025-08-25 16:32:01');
INSERT INTO `sys_operationlog` VALUES (870, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 16:32:03', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:32:03', 6, '2025-08-25 16:32:03');
INSERT INTO `sys_operationlog` VALUES (871, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 16:32:55', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:32:55', 6, '2025-08-25 16:32:55');
INSERT INTO `sys_operationlog` VALUES (872, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 16:33:29', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:33:29', 6, '2025-08-25 16:33:29');
INSERT INTO `sys_operationlog` VALUES (873, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 16:33:34', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:33:34', 6, '2025-08-25 16:33:34');
INSERT INTO `sys_operationlog` VALUES (874, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 16:33:39', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:33:39', 6, '2025-08-25 16:33:39');
INSERT INTO `sys_operationlog` VALUES (875, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 16:33:48', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:33:48', 6, '2025-08-25 16:33:48');
INSERT INTO `sys_operationlog` VALUES (876, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 16:33:54', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:33:54', 6, '2025-08-25 16:33:54');
INSERT INTO `sys_operationlog` VALUES (877, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 16:34:27', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:34:27', 6, '2025-08-25 16:34:27');
INSERT INTO `sys_operationlog` VALUES (878, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 16:34:31', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:34:31', 6, '2025-08-25 16:34:31');
INSERT INTO `sys_operationlog` VALUES (879, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 16:35:03', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:35:03', 6, '2025-08-25 16:35:03');
INSERT INTO `sys_operationlog` VALUES (880, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 16:35:58', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:35:58', 6, '2025-08-25 16:35:58');
INSERT INTO `sys_operationlog` VALUES (881, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 16:36:02', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:36:02', 6, '2025-08-25 16:36:02');
INSERT INTO `sys_operationlog` VALUES (882, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 16:36:16', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:36:16', 6, '2025-08-25 16:36:16');
INSERT INTO `sys_operationlog` VALUES (883, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 16:36:20', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:36:20', 6, '2025-08-25 16:36:20');
INSERT INTO `sys_operationlog` VALUES (884, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 16:36:23', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:36:23', 6, '2025-08-25 16:36:23');
INSERT INTO `sys_operationlog` VALUES (885, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-25 16:36:28', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-25 16:36:28', 6, '2025-08-25 16:36:28');
INSERT INTO `sys_operationlog` VALUES (886, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 17:00:27', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 2, 6, '2025-08-25 17:00:27', 6, '2025-08-25 17:00:27');
INSERT INTO `sys_operationlog` VALUES (887, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 17:00:27', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 2, 6, '2025-08-25 17:00:27', 6, '2025-08-25 17:00:27');
INSERT INTO `sys_operationlog` VALUES (888, 6, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-25 17:01:33', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 2, 6, '2025-08-25 17:01:33', 6, '2025-08-25 17:01:33');
INSERT INTO `sys_operationlog` VALUES (889, 6, 11, '账号登出', '人员退出系统', '2025-08-25 17:06:20', '{}', 2, 6, '2025-08-25 17:06:20', 6, '2025-08-25 17:06:20');
INSERT INTO `sys_operationlog` VALUES (890, 2, 10, '系统登陆', '人员登陆', '2025-08-25 17:06:26', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-25 17:06:26', 2, '2025-08-25 17:06:26');
INSERT INTO `sys_operationlog` VALUES (891, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 17:06:31', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 17:06:31', 2, '2025-08-25 17:06:31');
INSERT INTO `sys_operationlog` VALUES (892, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 17:06:31', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 17:06:31', 2, '2025-08-25 17:06:31');
INSERT INTO `sys_operationlog` VALUES (893, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-25 17:06:38', '{\"roleId\":1,\"permissionIds\":[1,13,2,14,15,16,3,18,19,4,20,21,22,23,5,24,25,26,27,6,28,29,52,7,30,31,32,33,8,34,35,36,37,9,38,40,10,41,42,43,11,44,45,46,47,12,48,49,50,51]}', 1, 2, '2025-08-25 17:06:38', 2, '2025-08-25 17:06:38');
INSERT INTO `sys_operationlog` VALUES (894, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-25 17:06:54', '{\"roleId\":3,\"permissionIds\":[1,13,2,14,15,16,3,18,19,4,20,21,22,23,5,24,25,26,27,6,28,29,52,7,30,31,32,33,8,34,35,36,37,9,38,40,10,41,42,43,11,44,45,46,47,48,49,50,51]}', 1, 2, '2025-08-25 17:06:54', 2, '2025-08-25 17:06:54');
INSERT INTO `sys_operationlog` VALUES (895, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-25 17:07:07', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-25 17:07:07', 2, '2025-08-25 17:07:07');
INSERT INTO `sys_operationlog` VALUES (896, 2, 10, '系统登陆', '人员登陆', '2025-08-28 09:16:42', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-28 09:16:42', 2, '2025-08-28 09:16:42');
INSERT INTO `sys_operationlog` VALUES (897, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-28 09:16:58', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-28 09:16:58', 2, '2025-08-28 09:16:58');
INSERT INTO `sys_operationlog` VALUES (898, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-28 09:16:58', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-28 09:16:58', 2, '2025-08-28 09:16:58');
INSERT INTO `sys_operationlog` VALUES (899, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-28 09:17:08', '{\"roleId\":1,\"permissionIds\":[1,13,53,2,14,15,16,3,18,19,4,20,21,22,23,5,24,25,26,27,6,28,29,52,7,30,31,32,33,8,34,35,36,37,9,38,40,10,41,42,43,11,44,45,46,47,12,48,49,50,51]}', 1, 2, '2025-08-28 09:17:08', 2, '2025-08-28 09:17:08');
INSERT INTO `sys_operationlog` VALUES (900, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-28 09:17:13', '{\"roleId\":3,\"permissionIds\":[1,13,53,2,14,15,16,3,18,19,4,20,21,22,23,5,24,25,26,27,6,28,29,52,7,30,31,32,33,8,34,35,36,37,9,38,40,10,41,42,43,11,44,45,46,47,48,49,50,51]}', 1, 2, '2025-08-28 09:17:13', 2, '2025-08-28 09:17:13');
INSERT INTO `sys_operationlog` VALUES (901, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-28 09:17:15', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-28 09:17:15', 2, '2025-08-28 09:17:15');
INSERT INTO `sys_operationlog` VALUES (902, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 09:18:23', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 09:18:23', 2, '2025-08-28 09:18:23');
INSERT INTO `sys_operationlog` VALUES (903, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 09:18:23', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 09:18:23', 2, '2025-08-28 09:18:23');
INSERT INTO `sys_operationlog` VALUES (904, 2, 4, '系统设置>角色管理', '菜品分类管理查询', '2025-08-28 09:18:27', '{\"name\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-28 09:18:27', 2, '2025-08-28 09:18:27');
INSERT INTO `sys_operationlog` VALUES (905, 2, 4, '系统设置>角色管理', '菜品分类管理查询', '2025-08-28 09:18:27', '{\"name\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-28 09:18:27', 2, '2025-08-28 09:18:27');
INSERT INTO `sys_operationlog` VALUES (906, 2, 4, '系统设置>角色管理', '菜品分类管理查询', '2025-08-28 09:18:27', '{\"name\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-28 09:18:27', 2, '2025-08-28 09:18:27');
INSERT INTO `sys_operationlog` VALUES (907, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 09:18:28', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 09:18:28', 2, '2025-08-28 09:18:28');
INSERT INTO `sys_operationlog` VALUES (908, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 09:18:28', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 09:18:28', 2, '2025-08-28 09:18:28');
INSERT INTO `sys_operationlog` VALUES (909, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 09:18:28', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 09:18:28', 2, '2025-08-28 09:18:28');
INSERT INTO `sys_operationlog` VALUES (910, 2, 10, '系统登陆', '人员登陆', '2025-08-28 13:56:14', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-28 13:56:14', 2, '2025-08-28 13:56:14');
INSERT INTO `sys_operationlog` VALUES (911, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 13:56:39', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 13:56:39', 2, '2025-08-28 13:56:39');
INSERT INTO `sys_operationlog` VALUES (912, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 13:56:39', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 13:56:39', 2, '2025-08-28 13:56:39');
INSERT INTO `sys_operationlog` VALUES (913, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:01:15', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:01:15', 2, '2025-08-28 14:01:15');
INSERT INTO `sys_operationlog` VALUES (914, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:01:16', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:01:16', 2, '2025-08-28 14:01:16');
INSERT INTO `sys_operationlog` VALUES (915, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:01:41', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:01:41', 2, '2025-08-28 14:01:41');
INSERT INTO `sys_operationlog` VALUES (916, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:01:41', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:01:41', 2, '2025-08-28 14:01:41');
INSERT INTO `sys_operationlog` VALUES (917, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:03:13', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:03:13', 2, '2025-08-28 14:03:13');
INSERT INTO `sys_operationlog` VALUES (918, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:03:13', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:03:13', 2, '2025-08-28 14:03:13');
INSERT INTO `sys_operationlog` VALUES (919, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:03:26', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:03:26', 2, '2025-08-28 14:03:26');
INSERT INTO `sys_operationlog` VALUES (920, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:03:26', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:03:26', 2, '2025-08-28 14:03:26');
INSERT INTO `sys_operationlog` VALUES (921, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:04:27', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:04:27', 2, '2025-08-28 14:04:27');
INSERT INTO `sys_operationlog` VALUES (922, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:04:27', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:04:27', 2, '2025-08-28 14:04:27');
INSERT INTO `sys_operationlog` VALUES (923, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:20:33', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:20:33', 2, '2025-08-28 14:20:33');
INSERT INTO `sys_operationlog` VALUES (924, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:20:34', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:20:34', 2, '2025-08-28 14:20:34');
INSERT INTO `sys_operationlog` VALUES (925, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:28:33', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:28:33', 2, '2025-08-28 14:28:33');
INSERT INTO `sys_operationlog` VALUES (926, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:28:33', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:28:33', 2, '2025-08-28 14:28:33');
INSERT INTO `sys_operationlog` VALUES (927, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:28:42', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:28:42', 2, '2025-08-28 14:28:42');
INSERT INTO `sys_operationlog` VALUES (928, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:28:42', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:28:42', 2, '2025-08-28 14:28:42');
INSERT INTO `sys_operationlog` VALUES (929, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:28:53', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:28:53', 2, '2025-08-28 14:28:53');
INSERT INTO `sys_operationlog` VALUES (930, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:28:53', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:28:53', 2, '2025-08-28 14:28:53');
INSERT INTO `sys_operationlog` VALUES (931, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:29:11', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:29:11', 2, '2025-08-28 14:29:11');
INSERT INTO `sys_operationlog` VALUES (932, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:29:11', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:29:11', 2, '2025-08-28 14:29:11');
INSERT INTO `sys_operationlog` VALUES (933, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:29:18', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:29:18', 2, '2025-08-28 14:29:18');
INSERT INTO `sys_operationlog` VALUES (934, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:29:18', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:29:18', 2, '2025-08-28 14:29:18');
INSERT INTO `sys_operationlog` VALUES (935, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:29:48', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:29:48', 2, '2025-08-28 14:29:48');
INSERT INTO `sys_operationlog` VALUES (936, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:32:03', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:32:03', 2, '2025-08-28 14:32:03');
INSERT INTO `sys_operationlog` VALUES (937, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:32:15', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:32:15', 2, '2025-08-28 14:32:15');
INSERT INTO `sys_operationlog` VALUES (938, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:32:31', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:32:31', 2, '2025-08-28 14:32:31');
INSERT INTO `sys_operationlog` VALUES (939, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-28 14:32:38', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-28 14:32:38', 2, '2025-08-28 14:32:38');
INSERT INTO `sys_operationlog` VALUES (940, 2, 10, '系统登陆', '人员登陆', '2025-08-28 16:33:20', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-28 16:33:20', 2, '2025-08-28 16:33:20');
INSERT INTO `sys_operationlog` VALUES (941, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:20:15', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:20:15', 2, '2025-08-28 17:20:15');
INSERT INTO `sys_operationlog` VALUES (942, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:20:23', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:20:23', 2, '2025-08-28 17:20:23');
INSERT INTO `sys_operationlog` VALUES (943, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:27:30', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:27:30', 2, '2025-08-28 17:27:30');
INSERT INTO `sys_operationlog` VALUES (944, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:28:34', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:28:34', 2, '2025-08-28 17:28:34');
INSERT INTO `sys_operationlog` VALUES (945, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:28:47', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:28:47', 2, '2025-08-28 17:28:47');
INSERT INTO `sys_operationlog` VALUES (946, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:28:50', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:28:50', 2, '2025-08-28 17:28:50');
INSERT INTO `sys_operationlog` VALUES (947, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:28:53', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:28:53', 2, '2025-08-28 17:28:53');
INSERT INTO `sys_operationlog` VALUES (948, 2, 3, '系统设置>厨房管理', '新增厨房', '2025-08-28 17:29:05', '{\"kitchen\":{\"id\":0,\"kitchen_name\":\"热菜厨房\",\"kitchen_type\":\"热菜厨房\",\"kitchen_description\":\"\",\"store_id\":0}}', 1, 2, '2025-08-28 17:29:05', 2, '2025-08-28 17:29:05');
INSERT INTO `sys_operationlog` VALUES (949, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:31:40', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:31:40', 2, '2025-08-28 17:31:40');
INSERT INTO `sys_operationlog` VALUES (950, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:32:01', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:32:01', 2, '2025-08-28 17:32:01');
INSERT INTO `sys_operationlog` VALUES (951, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:32:14', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:32:14', 2, '2025-08-28 17:32:14');
INSERT INTO `sys_operationlog` VALUES (952, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:32:20', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:32:20', 2, '2025-08-28 17:32:20');
INSERT INTO `sys_operationlog` VALUES (953, 2, 3, '系统设置>厨房管理', '新增厨房', '2025-08-28 17:32:31', '{\"kitchen\":{\"id\":0,\"kitchen_name\":\"热菜厨房\",\"kitchen_type\":\"热菜厨房\",\"kitchen_description\":\"\",\"store_id\":0}}', 1, 2, '2025-08-28 17:32:31', 2, '2025-08-28 17:32:31');
INSERT INTO `sys_operationlog` VALUES (954, 2, 10, '系统登陆', '人员登陆', '2025-08-28 17:32:46', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-28 17:32:46', 2, '2025-08-28 17:32:46');
INSERT INTO `sys_operationlog` VALUES (955, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:32:50', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:32:50', 2, '2025-08-28 17:32:50');
INSERT INTO `sys_operationlog` VALUES (956, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:32:50', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:32:50', 2, '2025-08-28 17:32:50');
INSERT INTO `sys_operationlog` VALUES (957, 2, 3, '系统设置>厨房管理', '新增厨房', '2025-08-28 17:32:55', '{\"kitchen\":{\"id\":0,\"kitchen_name\":\"热菜厨房\",\"kitchen_type\":\"热菜厨房\",\"kitchen_description\":\"\",\"store_id\":0}}', 1, 2, '2025-08-28 17:32:55', 2, '2025-08-28 17:32:55');
INSERT INTO `sys_operationlog` VALUES (958, 2, 10, '系统登陆', '人员登陆', '2025-08-28 17:34:04', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-28 17:34:04', 2, '2025-08-28 17:34:04');
INSERT INTO `sys_operationlog` VALUES (959, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:34:06', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:34:06', 2, '2025-08-28 17:34:06');
INSERT INTO `sys_operationlog` VALUES (960, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:34:06', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:34:06', 2, '2025-08-28 17:34:06');
INSERT INTO `sys_operationlog` VALUES (961, 2, 1, '系统设置>厨房管理', '修改厨房', '2025-08-28 17:34:12', '{\"kitchen\":{\"id\":1,\"kitchen_name\":\"热菜厨房\",\"kitchen_type\":\"热菜厨房\",\"kitchen_description\":\"\",\"store_id\":0}}', 1, 2, '2025-08-28 17:34:12', 2, '2025-08-28 17:34:12');
INSERT INTO `sys_operationlog` VALUES (962, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:34:12', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:34:12', 2, '2025-08-28 17:34:12');
INSERT INTO `sys_operationlog` VALUES (963, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:34:17', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:34:17', 2, '2025-08-28 17:34:17');
INSERT INTO `sys_operationlog` VALUES (964, 2, 1, '系统设置>厨房管理', '修改厨房', '2025-08-28 17:34:29', '{\"kitchen\":{\"id\":1,\"kitchen_name\":\"热菜厨房\",\"kitchen_type\":\"热菜厨房\",\"kitchen_description\":\"\",\"store_id\":0}}', 1, 2, '2025-08-28 17:34:29', 2, '2025-08-28 17:34:29');
INSERT INTO `sys_operationlog` VALUES (965, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:34:29', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:34:29', 2, '2025-08-28 17:34:29');
INSERT INTO `sys_operationlog` VALUES (966, 2, 1, '系统设置>厨房管理', '修改厨房', '2025-08-28 17:35:22', '{\"kitchen\":{\"id\":1,\"kitchen_name\":\"热菜厨房\",\"kitchen_type\":\"热菜厨房\",\"kitchen_description\":\"111\",\"store_id\":0}}', 1, 2, '2025-08-28 17:35:22', 2, '2025-08-28 17:35:22');
INSERT INTO `sys_operationlog` VALUES (967, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:35:22', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:35:22', 2, '2025-08-28 17:35:22');
INSERT INTO `sys_operationlog` VALUES (968, 2, 1, '系统设置>厨房管理', '修改厨房', '2025-08-28 17:35:22', '{\"kitchen\":{\"id\":1,\"kitchen_name\":\"热菜厨房\",\"kitchen_type\":\"热菜厨房\",\"kitchen_description\":\"111\",\"store_id\":0}}', 1, 2, '2025-08-28 17:35:22', 2, '2025-08-28 17:35:22');
INSERT INTO `sys_operationlog` VALUES (969, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:35:22', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:35:22', 2, '2025-08-28 17:35:22');
INSERT INTO `sys_operationlog` VALUES (970, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:35:25', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:35:25', 2, '2025-08-28 17:35:25');
INSERT INTO `sys_operationlog` VALUES (971, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:35:37', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:35:37', 2, '2025-08-28 17:35:37');
INSERT INTO `sys_operationlog` VALUES (972, 2, 3, '系统设置>厨房管理', '新增厨房', '2025-08-28 17:36:23', '{\"kitchen\":{\"id\":0,\"kitchen_name\":\"凉菜厨房\",\"kitchen_type\":\"凉菜厨房\",\"kitchen_description\":\"\",\"store_id\":0}}', 1, 2, '2025-08-28 17:36:23', 2, '2025-08-28 17:36:23');
INSERT INTO `sys_operationlog` VALUES (973, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:36:23', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:36:23', 2, '2025-08-28 17:36:23');
INSERT INTO `sys_operationlog` VALUES (974, 2, 3, '系统设置>厨房管理', '新增厨房', '2025-08-28 17:36:50', '{\"kitchen\":{\"id\":0,\"kitchen_name\":\"饮料厨房\",\"kitchen_type\":\"饮料厨房\",\"kitchen_description\":\"\",\"store_id\":0}}', 1, 2, '2025-08-28 17:36:50', 2, '2025-08-28 17:36:50');
INSERT INTO `sys_operationlog` VALUES (975, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-28 17:36:50', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-28 17:36:50', 2, '2025-08-28 17:36:50');
INSERT INTO `sys_operationlog` VALUES (976, 2, 10, '系统登陆', '人员登陆', '2025-08-29 09:30:22', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-29 09:30:22', 2, '2025-08-29 09:30:22');
INSERT INTO `sys_operationlog` VALUES (977, 2, 4, '厨房管理', '厨房订单查询', '2025-08-29 09:30:27', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-29 09:30:27', 2, '2025-08-29 09:30:27');
INSERT INTO `sys_operationlog` VALUES (978, 2, 4, '厨房管理', '厨房订单查询', '2025-08-29 09:30:28', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-29 09:30:28', 2, '2025-08-29 09:30:28');
INSERT INTO `sys_operationlog` VALUES (979, 2, 4, '厨房管理', '订单状态统计', '2025-08-29 09:30:28', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-29 09:30:28', 2, '2025-08-29 09:30:28');
INSERT INTO `sys_operationlog` VALUES (980, 2, 4, '厨房管理', '订单状态统计', '2025-08-29 09:30:28', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-29 09:30:28', 2, '2025-08-29 09:30:28');
INSERT INTO `sys_operationlog` VALUES (981, 2, 4, '厨房管理', '订单状态统计', '2025-08-29 09:30:28', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-29 09:30:28', 2, '2025-08-29 09:30:28');
INSERT INTO `sys_operationlog` VALUES (982, 2, 4, '厨房管理', '订单状态统计', '2025-08-29 09:30:28', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-29 09:30:28', 2, '2025-08-29 09:30:28');
INSERT INTO `sys_operationlog` VALUES (983, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-29 09:31:38', '{\"storeId\":null,\"kitchenType\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-29 09:31:38', 2, '2025-08-29 09:31:38');
INSERT INTO `sys_operationlog` VALUES (984, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-29 09:31:38', '{\"storeId\":null,\"kitchenType\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-29 09:31:38', 2, '2025-08-29 09:31:38');
INSERT INTO `sys_operationlog` VALUES (985, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-29 09:31:38', '{\"storeId\":null,\"kitchenType\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-29 09:31:38', 2, '2025-08-29 09:31:38');
INSERT INTO `sys_operationlog` VALUES (986, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-29 09:32:41', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-29 09:32:41', 2, '2025-08-29 09:32:41');
INSERT INTO `sys_operationlog` VALUES (987, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-29 09:32:41', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-29 09:32:41', 2, '2025-08-29 09:32:41');
INSERT INTO `sys_operationlog` VALUES (988, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-29 09:32:41', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-29 09:32:41', 2, '2025-08-29 09:32:41');
INSERT INTO `sys_operationlog` VALUES (989, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-29 09:32:41', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-29 09:32:41', 2, '2025-08-29 09:32:41');
INSERT INTO `sys_operationlog` VALUES (990, 2, 10, '系统登陆', '人员登陆', '2025-08-29 15:22:26', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-29 15:22:26', 2, '2025-08-29 15:22:26');
INSERT INTO `sys_operationlog` VALUES (991, 2, 10, '系统登陆', '人员登陆', '2025-08-29 15:53:47', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-29 15:53:47', 2, '2025-08-29 15:53:47');
INSERT INTO `sys_operationlog` VALUES (992, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 15:53:55', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 15:53:55', 2, '2025-08-29 15:53:55');
INSERT INTO `sys_operationlog` VALUES (993, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 15:53:55', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 15:53:55', 2, '2025-08-29 15:53:55');
INSERT INTO `sys_operationlog` VALUES (994, 2, 10, '系统登陆', '人员登陆', '2025-08-29 15:55:31', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-29 15:55:31', 2, '2025-08-29 15:55:31');
INSERT INTO `sys_operationlog` VALUES (995, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 15:55:37', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 15:55:37', 2, '2025-08-29 15:55:37');
INSERT INTO `sys_operationlog` VALUES (996, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 15:55:37', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 15:55:37', 2, '2025-08-29 15:55:37');
INSERT INTO `sys_operationlog` VALUES (997, 2, 10, '系统登陆', '人员登陆', '2025-08-29 15:58:26', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-29 15:58:26', 2, '2025-08-29 15:58:26');
INSERT INTO `sys_operationlog` VALUES (998, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 15:58:32', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 15:58:32', 2, '2025-08-29 15:58:32');
INSERT INTO `sys_operationlog` VALUES (999, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 15:58:32', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 15:58:32', 2, '2025-08-29 15:58:32');
INSERT INTO `sys_operationlog` VALUES (1000, 2, 10, '系统登陆', '人员登陆', '2025-08-29 16:00:15', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-29 16:00:15', 2, '2025-08-29 16:00:15');
INSERT INTO `sys_operationlog` VALUES (1001, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:00:27', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:00:27', 2, '2025-08-29 16:00:27');
INSERT INTO `sys_operationlog` VALUES (1002, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:00:27', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:00:27', 2, '2025-08-29 16:00:27');
INSERT INTO `sys_operationlog` VALUES (1003, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:01:15', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:01:15', 2, '2025-08-29 16:01:15');
INSERT INTO `sys_operationlog` VALUES (1004, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:01:56', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:01:56', 2, '2025-08-29 16:01:56');
INSERT INTO `sys_operationlog` VALUES (1005, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:01:59', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:01:59', 2, '2025-08-29 16:01:59');
INSERT INTO `sys_operationlog` VALUES (1006, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:02:00', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:02:00', 2, '2025-08-29 16:02:00');
INSERT INTO `sys_operationlog` VALUES (1007, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:02:00', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:02:00', 2, '2025-08-29 16:02:00');
INSERT INTO `sys_operationlog` VALUES (1008, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:02:00', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:02:00', 2, '2025-08-29 16:02:00');
INSERT INTO `sys_operationlog` VALUES (1009, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:02:00', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:02:00', 2, '2025-08-29 16:02:00');
INSERT INTO `sys_operationlog` VALUES (1010, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:02:01', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:02:01', 2, '2025-08-29 16:02:01');
INSERT INTO `sys_operationlog` VALUES (1011, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:05:00', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:05:00', 2, '2025-08-29 16:05:00');
INSERT INTO `sys_operationlog` VALUES (1012, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:05:59', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:05:59', 2, '2025-08-29 16:05:59');
INSERT INTO `sys_operationlog` VALUES (1013, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:06:08', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:06:08', 2, '2025-08-29 16:06:08');
INSERT INTO `sys_operationlog` VALUES (1014, 2, 3, '菜品管理>套餐管理', '新增套餐', '2025-08-29 16:06:38', '{\"meal\":{\"meal_id\":0,\"store_id\":2,\"meal_name\":\"1111\",\"price\":111.0,\"original_price\":11.0,\"description\":\"\",\"is_fixed\":1,\"status\":1,\"start_time\":\"2025-07-31T16:00:00Z\",\"end_time\":\"2025-08-30T16:00:00Z\"}}', 1, 2, '2025-08-29 16:06:38', 2, '2025-08-29 16:06:38');
INSERT INTO `sys_operationlog` VALUES (1015, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:06:38', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:06:38', 2, '2025-08-29 16:06:38');
INSERT INTO `sys_operationlog` VALUES (1016, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:08:10', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:08:10', 2, '2025-08-29 16:08:10');
INSERT INTO `sys_operationlog` VALUES (1017, 2, 4, '菜品管理>套餐管理', '套餐详情查询', '2025-08-29 16:09:18', '{\"mealId\":1}', 1, 2, '2025-08-29 16:09:18', 2, '2025-08-29 16:09:18');
INSERT INTO `sys_operationlog` VALUES (1018, 2, 4, '菜品管理>套餐管理', '套餐详情查询', '2025-08-29 16:09:20', '{\"mealId\":1}', 1, 2, '2025-08-29 16:09:20', 2, '2025-08-29 16:09:20');
INSERT INTO `sys_operationlog` VALUES (1019, 2, 4, '菜品管理>套餐管理', '套餐详情查询', '2025-08-29 16:09:20', '{\"mealId\":1}', 1, 2, '2025-08-29 16:09:20', 2, '2025-08-29 16:09:20');
INSERT INTO `sys_operationlog` VALUES (1020, 2, 4, '菜品管理>套餐管理', '套餐详情查询', '2025-08-29 16:09:21', '{\"mealId\":1}', 1, 2, '2025-08-29 16:09:21', 2, '2025-08-29 16:09:21');
INSERT INTO `sys_operationlog` VALUES (1021, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:09:24', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:09:24', 2, '2025-08-29 16:09:24');
INSERT INTO `sys_operationlog` VALUES (1022, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 16:09:31', '{\"mealId\":1}', 1, 2, '2025-08-29 16:09:31', 2, '2025-08-29 16:09:31');
INSERT INTO `sys_operationlog` VALUES (1023, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 16:09:37', '{\"mealId\":1}', 1, 2, '2025-08-29 16:09:37', 2, '2025-08-29 16:09:37');
INSERT INTO `sys_operationlog` VALUES (1024, 2, 4, '菜品管理>套餐管理', '套餐详情查询', '2025-08-29 16:09:40', '{\"mealId\":1}', 1, 2, '2025-08-29 16:09:40', 2, '2025-08-29 16:09:40');
INSERT INTO `sys_operationlog` VALUES (1025, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:10:23', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:10:23', 2, '2025-08-29 16:10:23');
INSERT INTO `sys_operationlog` VALUES (1026, 2, 4, '菜品管理>套餐管理', '套餐详情查询', '2025-08-29 16:10:25', '{\"mealId\":1}', 1, 2, '2025-08-29 16:10:25', 2, '2025-08-29 16:10:25');
INSERT INTO `sys_operationlog` VALUES (1027, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:11:02', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:11:02', 2, '2025-08-29 16:11:02');
INSERT INTO `sys_operationlog` VALUES (1028, 2, 4, '菜品管理>套餐管理', '套餐详情查询', '2025-08-29 16:11:04', '{\"mealId\":1}', 1, 2, '2025-08-29 16:11:04', 2, '2025-08-29 16:11:04');
INSERT INTO `sys_operationlog` VALUES (1029, 2, 4, '菜品管理>套餐管理', '套餐详情查询', '2025-08-29 16:11:06', '{\"mealId\":1}', 1, 2, '2025-08-29 16:11:06', 2, '2025-08-29 16:11:06');
INSERT INTO `sys_operationlog` VALUES (1030, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:11:16', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:11:16', 2, '2025-08-29 16:11:16');
INSERT INTO `sys_operationlog` VALUES (1031, 2, 4, '菜品管理>套餐管理', '套餐详情查询', '2025-08-29 16:11:18', '{\"mealId\":1}', 1, 2, '2025-08-29 16:11:18', 2, '2025-08-29 16:11:18');
INSERT INTO `sys_operationlog` VALUES (1032, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:12:01', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:12:01', 2, '2025-08-29 16:12:01');
INSERT INTO `sys_operationlog` VALUES (1033, 2, 4, '菜品管理>套餐管理', '套餐详情查询', '2025-08-29 16:12:05', '{\"mealId\":1}', 1, 2, '2025-08-29 16:12:05', 2, '2025-08-29 16:12:05');
INSERT INTO `sys_operationlog` VALUES (1034, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:12:21', '{\"storeId\":null,\"mealName\":null,\"status\":0,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:12:21', 2, '2025-08-29 16:12:21');
INSERT INTO `sys_operationlog` VALUES (1035, 2, 10, '系统登陆', '人员登陆', '2025-08-29 16:39:26', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-29 16:39:26', 2, '2025-08-29 16:39:26');
INSERT INTO `sys_operationlog` VALUES (1036, 2, 4, '菜品管理>规格管理', '规格列表查询', '2025-08-29 16:39:33', '{\"specName\":null,\"specType\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:39:33', 2, '2025-08-29 16:39:33');
INSERT INTO `sys_operationlog` VALUES (1037, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:39:33', '{}', 1, 2, '2025-08-29 16:39:33', 2, '2025-08-29 16:39:33');
INSERT INTO `sys_operationlog` VALUES (1038, 2, 4, '菜品管理>规格管理', '规格列表查询', '2025-08-29 16:39:33', '{\"specName\":null,\"specType\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:39:33', 2, '2025-08-29 16:39:33');
INSERT INTO `sys_operationlog` VALUES (1039, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:39:33', '{}', 1, 2, '2025-08-29 16:39:33', 2, '2025-08-29 16:39:33');
INSERT INTO `sys_operationlog` VALUES (1040, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:39:51', '{}', 1, 2, '2025-08-29 16:39:51', 2, '2025-08-29 16:39:51');
INSERT INTO `sys_operationlog` VALUES (1041, 2, 4, '菜品管理>规格管理', '规格列表查询', '2025-08-29 16:39:52', '{\"specName\":null,\"specType\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:39:52', 2, '2025-08-29 16:39:52');
INSERT INTO `sys_operationlog` VALUES (1042, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:39:52', '{}', 1, 2, '2025-08-29 16:39:52', 2, '2025-08-29 16:39:52');
INSERT INTO `sys_operationlog` VALUES (1043, 2, 4, '菜品管理>规格管理', '规格列表查询', '2025-08-29 16:39:52', '{\"specName\":null,\"specType\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:39:52', 2, '2025-08-29 16:39:52');
INSERT INTO `sys_operationlog` VALUES (1044, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:40:00', '{}', 1, 2, '2025-08-29 16:40:00', 2, '2025-08-29 16:40:00');
INSERT INTO `sys_operationlog` VALUES (1045, 2, 4, '菜品管理>规格管理', '规格列表查询', '2025-08-29 16:40:00', '{\"specName\":null,\"specType\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:40:00', 2, '2025-08-29 16:40:00');
INSERT INTO `sys_operationlog` VALUES (1046, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:40:00', '{}', 1, 2, '2025-08-29 16:40:00', 2, '2025-08-29 16:40:00');
INSERT INTO `sys_operationlog` VALUES (1047, 2, 4, '菜品管理>规格管理', '规格列表查询', '2025-08-29 16:40:00', '{\"specName\":null,\"specType\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:40:00', 2, '2025-08-29 16:40:00');
INSERT INTO `sys_operationlog` VALUES (1048, 2, 4, '菜品管理>规格管理', '规格列表查询', '2025-08-29 16:40:08', '{\"specName\":null,\"specType\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:40:08', 2, '2025-08-29 16:40:08');
INSERT INTO `sys_operationlog` VALUES (1049, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:40:08', '{}', 1, 2, '2025-08-29 16:40:08', 2, '2025-08-29 16:40:08');
INSERT INTO `sys_operationlog` VALUES (1050, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:40:08', '{}', 1, 2, '2025-08-29 16:40:08', 2, '2025-08-29 16:40:08');
INSERT INTO `sys_operationlog` VALUES (1051, 2, 4, '菜品管理>规格管理', '规格列表查询', '2025-08-29 16:40:08', '{\"specName\":null,\"specType\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:40:08', 2, '2025-08-29 16:40:08');
INSERT INTO `sys_operationlog` VALUES (1052, 2, 4, '菜品管理>规格管理', '规格列表查询', '2025-08-29 16:42:57', '{\"specName\":null,\"specType\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:42:57', 2, '2025-08-29 16:42:57');
INSERT INTO `sys_operationlog` VALUES (1053, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:42:57', '{}', 1, 2, '2025-08-29 16:42:57', 2, '2025-08-29 16:42:57');
INSERT INTO `sys_operationlog` VALUES (1054, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:42:57', '{}', 1, 2, '2025-08-29 16:42:57', 2, '2025-08-29 16:42:57');
INSERT INTO `sys_operationlog` VALUES (1055, 2, 4, '菜品管理>规格管理', '规格列表查询', '2025-08-29 16:42:57', '{\"specName\":null,\"specType\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:42:57', 2, '2025-08-29 16:42:57');
INSERT INTO `sys_operationlog` VALUES (1056, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:44:43', '{}', 1, 2, '2025-08-29 16:44:43', 2, '2025-08-29 16:44:43');
INSERT INTO `sys_operationlog` VALUES (1057, 2, 4, '菜品管理>规格管理', '规格列表查询', '2025-08-29 16:44:43', '{\"specName\":null,\"specType\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:44:43', 2, '2025-08-29 16:44:43');
INSERT INTO `sys_operationlog` VALUES (1058, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:44:43', '{}', 1, 2, '2025-08-29 16:44:43', 2, '2025-08-29 16:44:43');
INSERT INTO `sys_operationlog` VALUES (1059, 2, 4, '菜品管理>规格管理', '规格列表查询', '2025-08-29 16:44:43', '{\"specName\":null,\"specType\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:44:43', 2, '2025-08-29 16:44:43');
INSERT INTO `sys_operationlog` VALUES (1060, 2, 3, '菜品管理>规格管理', '新增规格', '2025-08-29 16:45:28', '{\"spec\":{\"spec_id\":0,\"dish_id\":2,\"spec_name\":\"小份\",\"spec_type\":\"分量\",\"price_diff\":30.0,\"sort_order\":1,\"dish\":null}}', 1, 2, '2025-08-29 16:45:28', 2, '2025-08-29 16:45:28');
INSERT INTO `sys_operationlog` VALUES (1061, 2, 4, '菜品管理>规格管理', '规格列表查询', '2025-08-29 16:45:28', '{\"specName\":null,\"specType\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:45:28', 2, '2025-08-29 16:45:28');
INSERT INTO `sys_operationlog` VALUES (1062, 2, 3, '菜品管理>规格管理', '新增规格', '2025-08-29 16:46:12', '{\"spec\":{\"spec_id\":0,\"dish_id\":2,\"spec_name\":\"中份\",\"spec_type\":\"分量\",\"price_diff\":50.0,\"sort_order\":2,\"dish\":null}}', 1, 2, '2025-08-29 16:46:12', 2, '2025-08-29 16:46:12');
INSERT INTO `sys_operationlog` VALUES (1063, 2, 4, '菜品管理>规格管理', '规格列表查询', '2025-08-29 16:46:12', '{\"specName\":null,\"specType\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:46:12', 2, '2025-08-29 16:46:12');
INSERT INTO `sys_operationlog` VALUES (1064, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:46:21', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:46:21', 2, '2025-08-29 16:46:21');
INSERT INTO `sys_operationlog` VALUES (1065, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:46:22', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:46:22', 2, '2025-08-29 16:46:22');
INSERT INTO `sys_operationlog` VALUES (1066, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:46:22', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:46:22', 2, '2025-08-29 16:46:22');
INSERT INTO `sys_operationlog` VALUES (1067, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 16:46:24', '{\"mealId\":1}', 1, 2, '2025-08-29 16:46:24', 2, '2025-08-29 16:46:24');
INSERT INTO `sys_operationlog` VALUES (1068, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:48:52', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:48:52', 2, '2025-08-29 16:48:52');
INSERT INTO `sys_operationlog` VALUES (1069, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:48:52', '{}', 1, 2, '2025-08-29 16:48:52', 2, '2025-08-29 16:48:52');
INSERT INTO `sys_operationlog` VALUES (1070, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:48:53', '{}', 1, 2, '2025-08-29 16:48:53', 2, '2025-08-29 16:48:53');
INSERT INTO `sys_operationlog` VALUES (1071, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:48:53', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:48:53', 2, '2025-08-29 16:48:53');
INSERT INTO `sys_operationlog` VALUES (1072, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:48:53', '{}', 1, 2, '2025-08-29 16:48:53', 2, '2025-08-29 16:48:53');
INSERT INTO `sys_operationlog` VALUES (1073, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:48:53', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:48:53', 2, '2025-08-29 16:48:53');
INSERT INTO `sys_operationlog` VALUES (1074, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 16:48:56', '{\"mealId\":1}', 1, 2, '2025-08-29 16:48:56', 2, '2025-08-29 16:48:56');
INSERT INTO `sys_operationlog` VALUES (1075, 2, 10, '系统登陆', '人员登陆', '2025-08-29 16:54:28', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-29 16:54:28', 2, '2025-08-29 16:54:28');
INSERT INTO `sys_operationlog` VALUES (1076, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:54:32', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:54:32', 2, '2025-08-29 16:54:32');
INSERT INTO `sys_operationlog` VALUES (1077, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:54:32', '{}', 1, 2, '2025-08-29 16:54:32', 2, '2025-08-29 16:54:32');
INSERT INTO `sys_operationlog` VALUES (1078, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:54:32', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:54:32', 2, '2025-08-29 16:54:32');
INSERT INTO `sys_operationlog` VALUES (1079, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:54:32', '{}', 1, 2, '2025-08-29 16:54:32', 2, '2025-08-29 16:54:32');
INSERT INTO `sys_operationlog` VALUES (1080, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 16:54:33', '{\"mealId\":1}', 1, 2, '2025-08-29 16:54:33', 2, '2025-08-29 16:54:33');
INSERT INTO `sys_operationlog` VALUES (1081, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:57:01', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:57:01', 2, '2025-08-29 16:57:01');
INSERT INTO `sys_operationlog` VALUES (1082, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:57:01', '{}', 1, 2, '2025-08-29 16:57:01', 2, '2025-08-29 16:57:01');
INSERT INTO `sys_operationlog` VALUES (1083, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:57:01', '{}', 1, 2, '2025-08-29 16:57:01', 2, '2025-08-29 16:57:01');
INSERT INTO `sys_operationlog` VALUES (1084, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:57:01', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:57:01', 2, '2025-08-29 16:57:01');
INSERT INTO `sys_operationlog` VALUES (1085, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:57:13', '{}', 1, 2, '2025-08-29 16:57:13', 2, '2025-08-29 16:57:13');
INSERT INTO `sys_operationlog` VALUES (1086, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:57:13', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:57:13', 2, '2025-08-29 16:57:13');
INSERT INTO `sys_operationlog` VALUES (1087, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:57:13', '{}', 1, 2, '2025-08-29 16:57:13', 2, '2025-08-29 16:57:13');
INSERT INTO `sys_operationlog` VALUES (1088, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:57:13', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:57:13', 2, '2025-08-29 16:57:13');
INSERT INTO `sys_operationlog` VALUES (1089, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:57:18', '{}', 1, 2, '2025-08-29 16:57:18', 2, '2025-08-29 16:57:18');
INSERT INTO `sys_operationlog` VALUES (1090, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:57:18', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:57:18', 2, '2025-08-29 16:57:18');
INSERT INTO `sys_operationlog` VALUES (1091, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:57:18', '{}', 1, 2, '2025-08-29 16:57:18', 2, '2025-08-29 16:57:18');
INSERT INTO `sys_operationlog` VALUES (1092, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:57:18', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:57:18', 2, '2025-08-29 16:57:18');
INSERT INTO `sys_operationlog` VALUES (1093, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 16:57:49', '{\"mealId\":1}', 1, 2, '2025-08-29 16:57:49', 2, '2025-08-29 16:57:49');
INSERT INTO `sys_operationlog` VALUES (1094, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:58:12', '{}', 1, 2, '2025-08-29 16:58:12', 2, '2025-08-29 16:58:12');
INSERT INTO `sys_operationlog` VALUES (1095, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:58:12', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:58:12', 2, '2025-08-29 16:58:12');
INSERT INTO `sys_operationlog` VALUES (1096, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 16:58:12', '{}', 1, 2, '2025-08-29 16:58:12', 2, '2025-08-29 16:58:12');
INSERT INTO `sys_operationlog` VALUES (1097, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 16:58:12', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 16:58:12', 2, '2025-08-29 16:58:12');
INSERT INTO `sys_operationlog` VALUES (1098, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 16:58:15', '{\"mealId\":1}', 1, 2, '2025-08-29 16:58:15', 2, '2025-08-29 16:58:15');
INSERT INTO `sys_operationlog` VALUES (1099, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 17:00:05', '{}', 1, 2, '2025-08-29 17:00:05', 2, '2025-08-29 17:00:05');
INSERT INTO `sys_operationlog` VALUES (1100, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 17:00:05', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 17:00:05', 2, '2025-08-29 17:00:05');
INSERT INTO `sys_operationlog` VALUES (1101, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 17:00:06', '{\"mealId\":1}', 1, 2, '2025-08-29 17:00:06', 2, '2025-08-29 17:00:06');
INSERT INTO `sys_operationlog` VALUES (1102, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 17:00:14', '{}', 1, 2, '2025-08-29 17:00:14', 2, '2025-08-29 17:00:14');
INSERT INTO `sys_operationlog` VALUES (1103, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 17:00:14', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 17:00:14', 2, '2025-08-29 17:00:14');
INSERT INTO `sys_operationlog` VALUES (1104, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 17:00:21', '{\"mealId\":1}', 1, 2, '2025-08-29 17:00:21', 2, '2025-08-29 17:00:21');
INSERT INTO `sys_operationlog` VALUES (1105, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 17:01:11', '{}', 1, 2, '2025-08-29 17:01:11', 2, '2025-08-29 17:01:11');
INSERT INTO `sys_operationlog` VALUES (1106, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 17:01:11', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 17:01:11', 2, '2025-08-29 17:01:11');
INSERT INTO `sys_operationlog` VALUES (1107, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 17:01:26', '{}', 1, 2, '2025-08-29 17:01:26', 2, '2025-08-29 17:01:26');
INSERT INTO `sys_operationlog` VALUES (1108, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 17:01:26', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 17:01:26', 2, '2025-08-29 17:01:26');
INSERT INTO `sys_operationlog` VALUES (1109, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 17:01:31', '{\"mealId\":1}', 1, 2, '2025-08-29 17:01:31', 2, '2025-08-29 17:01:31');
INSERT INTO `sys_operationlog` VALUES (1110, 2, 1, '菜品管理>套餐管理', '保存套餐明细', '2025-08-29 17:01:55', '{\"item\":{\"item_id\":0,\"meal_id\":1,\"dish_id\":2,\"spec_id\":1,\"quantity\":1,\"is_replaceable\":0,\"replaceable_dishes\":null,\"meal_group\":\"\"}}', 1, 2, '2025-08-29 17:01:55', 2, '2025-08-29 17:01:55');
INSERT INTO `sys_operationlog` VALUES (1111, 2, 4, '菜品管理>套餐管理', '套餐详情查询', '2025-08-29 17:01:55', '{\"mealId\":1}', 1, 2, '2025-08-29 17:01:55', 2, '2025-08-29 17:01:55');
INSERT INTO `sys_operationlog` VALUES (1112, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 17:01:55', '{\"mealId\":1}', 1, 2, '2025-08-29 17:01:55', 2, '2025-08-29 17:01:55');
INSERT INTO `sys_operationlog` VALUES (1113, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 17:07:52', '{}', 1, 2, '2025-08-29 17:07:52', 2, '2025-08-29 17:07:52');
INSERT INTO `sys_operationlog` VALUES (1114, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 17:07:52', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 17:07:52', 2, '2025-08-29 17:07:52');
INSERT INTO `sys_operationlog` VALUES (1115, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 17:07:58', '{\"mealId\":1}', 1, 2, '2025-08-29 17:07:58', 2, '2025-08-29 17:07:58');
INSERT INTO `sys_operationlog` VALUES (1116, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 17:08:06', '{\"mealId\":1}', 1, 2, '2025-08-29 17:08:06', 2, '2025-08-29 17:08:06');
INSERT INTO `sys_operationlog` VALUES (1117, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 17:08:21', '{}', 1, 2, '2025-08-29 17:08:21', 2, '2025-08-29 17:08:21');
INSERT INTO `sys_operationlog` VALUES (1118, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 17:08:21', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 17:08:21', 2, '2025-08-29 17:08:21');
INSERT INTO `sys_operationlog` VALUES (1119, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 17:08:27', '{}', 1, 2, '2025-08-29 17:08:27', 2, '2025-08-29 17:08:27');
INSERT INTO `sys_operationlog` VALUES (1120, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 17:08:27', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 17:08:27', 2, '2025-08-29 17:08:27');
INSERT INTO `sys_operationlog` VALUES (1121, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 17:08:29', '{\"mealId\":1}', 1, 2, '2025-08-29 17:08:29', 2, '2025-08-29 17:08:29');
INSERT INTO `sys_operationlog` VALUES (1122, 2, 4, '菜品管理>套餐管理', '套餐详情查询', '2025-08-29 17:08:43', '{\"mealId\":1}', 1, 2, '2025-08-29 17:08:43', 2, '2025-08-29 17:08:43');
INSERT INTO `sys_operationlog` VALUES (1123, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 17:08:48', '{\"mealId\":1}', 1, 2, '2025-08-29 17:08:48', 2, '2025-08-29 17:08:48');
INSERT INTO `sys_operationlog` VALUES (1124, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 17:09:17', '{\"mealId\":1}', 1, 2, '2025-08-29 17:09:17', 2, '2025-08-29 17:09:17');
INSERT INTO `sys_operationlog` VALUES (1125, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 17:09:50', '{\"mealId\":1}', 1, 2, '2025-08-29 17:09:50', 2, '2025-08-29 17:09:50');
INSERT INTO `sys_operationlog` VALUES (1126, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 17:10:11', '{\"mealId\":1}', 1, 2, '2025-08-29 17:10:11', 2, '2025-08-29 17:10:11');
INSERT INTO `sys_operationlog` VALUES (1127, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 17:10:36', '{\"mealId\":1}', 1, 2, '2025-08-29 17:10:36', 2, '2025-08-29 17:10:36');
INSERT INTO `sys_operationlog` VALUES (1128, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 17:10:39', '{\"mealId\":1}', 1, 2, '2025-08-29 17:10:39', 2, '2025-08-29 17:10:39');
INSERT INTO `sys_operationlog` VALUES (1129, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 17:11:57', '{}', 1, 2, '2025-08-29 17:11:57', 2, '2025-08-29 17:11:57');
INSERT INTO `sys_operationlog` VALUES (1130, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 17:11:57', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 17:11:57', 2, '2025-08-29 17:11:57');
INSERT INTO `sys_operationlog` VALUES (1131, 2, 10, '系统登陆', '人员登陆', '2025-08-29 17:29:36', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-29 17:29:36', 2, '2025-08-29 17:29:36');
INSERT INTO `sys_operationlog` VALUES (1132, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 17:29:40', '{}', 1, 2, '2025-08-29 17:29:40', 2, '2025-08-29 17:29:40');
INSERT INTO `sys_operationlog` VALUES (1133, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 17:29:40', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 17:29:40', 2, '2025-08-29 17:29:40');
INSERT INTO `sys_operationlog` VALUES (1134, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 17:29:40', '{}', 1, 2, '2025-08-29 17:29:40', 2, '2025-08-29 17:29:40');
INSERT INTO `sys_operationlog` VALUES (1135, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 17:29:40', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 17:29:40', 2, '2025-08-29 17:29:40');
INSERT INTO `sys_operationlog` VALUES (1136, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 17:29:42', '{\"mealId\":1}', 1, 2, '2025-08-29 17:29:42', 2, '2025-08-29 17:29:42');
INSERT INTO `sys_operationlog` VALUES (1137, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 17:33:40', '{}', 1, 2, '2025-08-29 17:33:40', 2, '2025-08-29 17:33:40');
INSERT INTO `sys_operationlog` VALUES (1138, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 17:33:41', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 17:33:41', 2, '2025-08-29 17:33:41');
INSERT INTO `sys_operationlog` VALUES (1139, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-29 17:33:41', '{}', 1, 2, '2025-08-29 17:33:41', 2, '2025-08-29 17:33:41');
INSERT INTO `sys_operationlog` VALUES (1140, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-29 17:33:41', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-29 17:33:41', 2, '2025-08-29 17:33:41');
INSERT INTO `sys_operationlog` VALUES (1141, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 17:33:44', '{\"mealId\":1}', 1, 2, '2025-08-29 17:33:44', 2, '2025-08-29 17:33:44');
INSERT INTO `sys_operationlog` VALUES (1142, 2, 1, '菜品管理>套餐管理', '保存套餐明细', '2025-08-29 17:33:48', '{\"item\":{\"item_id\":0,\"meal_id\":1,\"dish_id\":3,\"spec_id\":null,\"quantity\":1,\"is_replaceable\":0,\"replaceable_dishes\":null,\"meal_group\":\"\"}}', 1, 2, '2025-08-29 17:33:48', 2, '2025-08-29 17:33:48');
INSERT INTO `sys_operationlog` VALUES (1143, 2, 4, '菜品管理>套餐管理', '套餐详情查询', '2025-08-29 17:33:48', '{\"mealId\":1}', 1, 2, '2025-08-29 17:33:48', 2, '2025-08-29 17:33:48');
INSERT INTO `sys_operationlog` VALUES (1144, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 17:33:48', '{\"mealId\":1}', 1, 2, '2025-08-29 17:33:48', 2, '2025-08-29 17:33:48');
INSERT INTO `sys_operationlog` VALUES (1145, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 17:34:13', '{\"mealId\":1}', 1, 2, '2025-08-29 17:34:13', 2, '2025-08-29 17:34:13');
INSERT INTO `sys_operationlog` VALUES (1146, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-29 17:34:44', '{\"mealId\":1}', 1, 2, '2025-08-29 17:34:44', 2, '2025-08-29 17:34:44');
INSERT INTO `sys_operationlog` VALUES (1147, 2, 10, '系统登陆', '人员登陆', '2025-08-30 09:02:15', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-30 09:02:15', 2, '2025-08-30 09:02:15');
INSERT INTO `sys_operationlog` VALUES (1148, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-30 09:02:23', '{}', 1, 2, '2025-08-30 09:02:23', 2, '2025-08-30 09:02:23');
INSERT INTO `sys_operationlog` VALUES (1149, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-30 09:02:23', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 09:02:23', 2, '2025-08-30 09:02:23');
INSERT INTO `sys_operationlog` VALUES (1150, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-30 09:02:23', '{}', 1, 2, '2025-08-30 09:02:23', 2, '2025-08-30 09:02:23');
INSERT INTO `sys_operationlog` VALUES (1151, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-30 09:02:23', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 09:02:23', 2, '2025-08-30 09:02:23');
INSERT INTO `sys_operationlog` VALUES (1152, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-30 09:02:26', '{\"mealId\":1}', 1, 2, '2025-08-30 09:02:26', 2, '2025-08-30 09:02:26');
INSERT INTO `sys_operationlog` VALUES (1153, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-30 09:09:13', '{}', 1, 2, '2025-08-30 09:09:13', 2, '2025-08-30 09:09:13');
INSERT INTO `sys_operationlog` VALUES (1154, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-30 09:09:13', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 09:09:13', 2, '2025-08-30 09:09:13');
INSERT INTO `sys_operationlog` VALUES (1155, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-30 09:09:13', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 09:09:13', 2, '2025-08-30 09:09:13');
INSERT INTO `sys_operationlog` VALUES (1156, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-30 09:09:13', '{}', 1, 2, '2025-08-30 09:09:13', 2, '2025-08-30 09:09:13');
INSERT INTO `sys_operationlog` VALUES (1157, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-30 09:09:13', '{}', 1, 2, '2025-08-30 09:09:13', 2, '2025-08-30 09:09:13');
INSERT INTO `sys_operationlog` VALUES (1158, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-30 09:09:13', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 09:09:13', 2, '2025-08-30 09:09:13');
INSERT INTO `sys_operationlog` VALUES (1159, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-30 09:09:13', '{}', 1, 2, '2025-08-30 09:09:13', 2, '2025-08-30 09:09:13');
INSERT INTO `sys_operationlog` VALUES (1160, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-30 09:09:13', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 09:09:13', 2, '2025-08-30 09:09:13');
INSERT INTO `sys_operationlog` VALUES (1161, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-30 09:09:13', '{}', 1, 2, '2025-08-30 09:09:13', 2, '2025-08-30 09:09:13');
INSERT INTO `sys_operationlog` VALUES (1162, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-30 09:09:14', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 09:09:14', 2, '2025-08-30 09:09:14');
INSERT INTO `sys_operationlog` VALUES (1163, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:19:32', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:19:32', 2, '2025-08-30 10:19:32');
INSERT INTO `sys_operationlog` VALUES (1164, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:19:37', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:19:37', 2, '2025-08-30 10:19:37');
INSERT INTO `sys_operationlog` VALUES (1165, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:19:54', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:19:54', 2, '2025-08-30 10:19:54');
INSERT INTO `sys_operationlog` VALUES (1166, 2, 10, '系统登陆', '人员登陆', '2025-08-30 10:20:51', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-30 10:20:51', 2, '2025-08-30 10:20:51');
INSERT INTO `sys_operationlog` VALUES (1167, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:21:02', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:21:02', 2, '2025-08-30 10:21:02');
INSERT INTO `sys_operationlog` VALUES (1168, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:21:02', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:21:02', 2, '2025-08-30 10:21:02');
INSERT INTO `sys_operationlog` VALUES (1169, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:22:30', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:22:30', 2, '2025-08-30 10:22:30');
INSERT INTO `sys_operationlog` VALUES (1170, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:22:31', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:22:31', 2, '2025-08-30 10:22:31');
INSERT INTO `sys_operationlog` VALUES (1171, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:22:53', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:22:53', 2, '2025-08-30 10:22:53');
INSERT INTO `sys_operationlog` VALUES (1172, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:22:57', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:22:57', 2, '2025-08-30 10:22:57');
INSERT INTO `sys_operationlog` VALUES (1173, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:23:43', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:23:43', 2, '2025-08-30 10:23:43');
INSERT INTO `sys_operationlog` VALUES (1174, 2, 10, '系统登陆', '人员登陆', '2025-08-30 10:25:23', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-30 10:25:23', 2, '2025-08-30 10:25:23');
INSERT INTO `sys_operationlog` VALUES (1175, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:25:38', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:25:38', 2, '2025-08-30 10:25:38');
INSERT INTO `sys_operationlog` VALUES (1176, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:25:38', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:25:38', 2, '2025-08-30 10:25:38');
INSERT INTO `sys_operationlog` VALUES (1177, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:25:38', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:25:38', 2, '2025-08-30 10:25:38');
INSERT INTO `sys_operationlog` VALUES (1178, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:25:38', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:25:38', 2, '2025-08-30 10:25:38');
INSERT INTO `sys_operationlog` VALUES (1179, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:25:38', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:25:38', 2, '2025-08-30 10:25:38');
INSERT INTO `sys_operationlog` VALUES (1180, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:25:38', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:25:38', 2, '2025-08-30 10:25:38');
INSERT INTO `sys_operationlog` VALUES (1181, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:25:38', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:25:38', 2, '2025-08-30 10:25:38');
INSERT INTO `sys_operationlog` VALUES (1182, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:25:38', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:25:38', 2, '2025-08-30 10:25:38');
INSERT INTO `sys_operationlog` VALUES (1183, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:25:38', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:25:38', 2, '2025-08-30 10:25:38');
INSERT INTO `sys_operationlog` VALUES (1184, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:25:38', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:25:38', 2, '2025-08-30 10:25:38');
INSERT INTO `sys_operationlog` VALUES (1185, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:25:38', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:25:38', 2, '2025-08-30 10:25:38');
INSERT INTO `sys_operationlog` VALUES (1186, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:25:38', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:25:38', 2, '2025-08-30 10:25:38');
INSERT INTO `sys_operationlog` VALUES (1187, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:25:38', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:25:38', 2, '2025-08-30 10:25:38');
INSERT INTO `sys_operationlog` VALUES (1188, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:25:38', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:25:38', 2, '2025-08-30 10:25:38');
INSERT INTO `sys_operationlog` VALUES (1189, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:25:38', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:25:38', 2, '2025-08-30 10:25:38');
INSERT INTO `sys_operationlog` VALUES (1190, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:25:38', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:25:38', 2, '2025-08-30 10:25:38');
INSERT INTO `sys_operationlog` VALUES (1191, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:25:38', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:25:38', 2, '2025-08-30 10:25:38');
INSERT INTO `sys_operationlog` VALUES (1192, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:25:41', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:25:41', 2, '2025-08-30 10:25:41');
INSERT INTO `sys_operationlog` VALUES (1193, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:25:42', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:25:42', 2, '2025-08-30 10:25:42');
INSERT INTO `sys_operationlog` VALUES (1194, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:27:25', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:27:25', 2, '2025-08-30 10:27:25');
INSERT INTO `sys_operationlog` VALUES (1195, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:28:05', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:28:05', 2, '2025-08-30 10:28:05');
INSERT INTO `sys_operationlog` VALUES (1196, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:31:47', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:31:47', 2, '2025-08-30 10:31:47');
INSERT INTO `sys_operationlog` VALUES (1197, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:32:16', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:32:16', 2, '2025-08-30 10:32:16');
INSERT INTO `sys_operationlog` VALUES (1198, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:33:16', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:33:16', 2, '2025-08-30 10:33:16');
INSERT INTO `sys_operationlog` VALUES (1199, 2, 10, '系统登陆', '人员登陆', '2025-08-30 10:35:33', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-30 10:35:33', 2, '2025-08-30 10:35:33');
INSERT INTO `sys_operationlog` VALUES (1200, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:35:41', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:35:41', 2, '2025-08-30 10:35:41');
INSERT INTO `sys_operationlog` VALUES (1201, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:35:42', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:35:42', 2, '2025-08-30 10:35:42');
INSERT INTO `sys_operationlog` VALUES (1202, 2, 10, '系统登陆', '人员登陆', '2025-08-30 10:39:25', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-30 10:39:25', 2, '2025-08-30 10:39:25');
INSERT INTO `sys_operationlog` VALUES (1203, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:39:33', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:39:33', 2, '2025-08-30 10:39:33');
INSERT INTO `sys_operationlog` VALUES (1204, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:39:36', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:39:36', 2, '2025-08-30 10:39:36');
INSERT INTO `sys_operationlog` VALUES (1205, 2, 3, '会员管理', '新增会员', '2025-08-30 10:40:09', '{\"member\":{\"member_id\":0,\"member_no\":null,\"phone\":\"15235060638\",\"name\":\"lq\",\"birthday\":\"2025-08-11T16:00:00Z\",\"register_time\":\"2025-08-30T02:40:06.609Z\",\"status\":1,\"total_points\":0,\"referrer_id\":null,\"balance\":null}}', 1, 2, '2025-08-30 10:40:09', 2, '2025-08-30 10:40:09');
INSERT INTO `sys_operationlog` VALUES (1206, 2, 10, '系统登陆', '人员登陆', '2025-08-30 10:44:42', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-30 10:44:42', 2, '2025-08-30 10:44:42');
INSERT INTO `sys_operationlog` VALUES (1207, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:44:49', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:44:49', 2, '2025-08-30 10:44:49');
INSERT INTO `sys_operationlog` VALUES (1208, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:44:49', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:44:49', 2, '2025-08-30 10:44:49');
INSERT INTO `sys_operationlog` VALUES (1209, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:44:51', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:44:51', 2, '2025-08-30 10:44:51');
INSERT INTO `sys_operationlog` VALUES (1210, 2, 3, '会员管理', '新增会员', '2025-08-30 10:47:32', '{\"member\":{\"member_id\":0,\"member_no\":\"202508301047284391139\",\"phone\":\"15235060638\",\"name\":\"张科国\",\"birthday\":\"2025-08-18T16:00:00Z\",\"register_time\":\"2025-08-30T10:47:27.2149446+08:00\",\"status\":1,\"total_points\":0,\"referrer_id\":null,\"balance\":null}}', 1, 2, '2025-08-30 10:47:32', 2, '2025-08-30 10:47:32');
INSERT INTO `sys_operationlog` VALUES (1211, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:47:58', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:47:58', 2, '2025-08-30 10:47:58');
INSERT INTO `sys_operationlog` VALUES (1212, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:48:00', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:48:00', 2, '2025-08-30 10:48:00');
INSERT INTO `sys_operationlog` VALUES (1213, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:48:29', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:48:29', 2, '2025-08-30 10:48:29');
INSERT INTO `sys_operationlog` VALUES (1214, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:48:29', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:48:29', 2, '2025-08-30 10:48:29');
INSERT INTO `sys_operationlog` VALUES (1215, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:49:29', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:49:29', 2, '2025-08-30 10:49:29');
INSERT INTO `sys_operationlog` VALUES (1216, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:49:29', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:49:29', 2, '2025-08-30 10:49:29');
INSERT INTO `sys_operationlog` VALUES (1217, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:50:15', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:50:15', 2, '2025-08-30 10:50:15');
INSERT INTO `sys_operationlog` VALUES (1218, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:50:15', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:50:15', 2, '2025-08-30 10:50:15');
INSERT INTO `sys_operationlog` VALUES (1219, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:53:12', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:53:12', 2, '2025-08-30 10:53:12');
INSERT INTO `sys_operationlog` VALUES (1220, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:53:12', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:53:12', 2, '2025-08-30 10:53:12');
INSERT INTO `sys_operationlog` VALUES (1221, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:53:16', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:53:16', 2, '2025-08-30 10:53:16');
INSERT INTO `sys_operationlog` VALUES (1222, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:53:17', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:53:17', 2, '2025-08-30 10:53:17');
INSERT INTO `sys_operationlog` VALUES (1223, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:53:18', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:53:18', 2, '2025-08-30 10:53:18');
INSERT INTO `sys_operationlog` VALUES (1224, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:53:27', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:53:27', 2, '2025-08-30 10:53:27');
INSERT INTO `sys_operationlog` VALUES (1225, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:54:13', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:54:13', 2, '2025-08-30 10:54:13');
INSERT INTO `sys_operationlog` VALUES (1226, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:54:13', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:54:13', 2, '2025-08-30 10:54:13');
INSERT INTO `sys_operationlog` VALUES (1227, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:54:48', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:54:48', 2, '2025-08-30 10:54:48');
INSERT INTO `sys_operationlog` VALUES (1228, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:55:10', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:55:10', 2, '2025-08-30 10:55:10');
INSERT INTO `sys_operationlog` VALUES (1229, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:55:10', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:55:10', 2, '2025-08-30 10:55:10');
INSERT INTO `sys_operationlog` VALUES (1230, 2, 1, '会员管理', '切换会员状态', '2025-08-30 10:56:10', '{\"memberId\":1,\"status\":0}', 1, 2, '2025-08-30 10:56:10', 2, '2025-08-30 10:56:10');
INSERT INTO `sys_operationlog` VALUES (1231, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:56:10', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:56:10', 2, '2025-08-30 10:56:10');
INSERT INTO `sys_operationlog` VALUES (1232, 2, 1, '会员管理', '切换会员状态', '2025-08-30 10:56:11', '{\"memberId\":1,\"status\":1}', 1, 2, '2025-08-30 10:56:11', 2, '2025-08-30 10:56:11');
INSERT INTO `sys_operationlog` VALUES (1233, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:56:11', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:56:11', 2, '2025-08-30 10:56:11');
INSERT INTO `sys_operationlog` VALUES (1234, 2, 1, '会员管理', '切换会员状态', '2025-08-30 10:56:12', '{\"memberId\":1,\"status\":0}', 1, 2, '2025-08-30 10:56:12', 2, '2025-08-30 10:56:12');
INSERT INTO `sys_operationlog` VALUES (1235, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:56:12', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:56:12', 2, '2025-08-30 10:56:12');
INSERT INTO `sys_operationlog` VALUES (1236, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:56:14', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:56:14', 2, '2025-08-30 10:56:14');
INSERT INTO `sys_operationlog` VALUES (1237, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:56:14', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:56:14', 2, '2025-08-30 10:56:14');
INSERT INTO `sys_operationlog` VALUES (1238, 2, 1, '会员管理', '切换会员状态', '2025-08-30 10:56:16', '{\"memberId\":1,\"status\":1}', 1, 2, '2025-08-30 10:56:16', 2, '2025-08-30 10:56:16');
INSERT INTO `sys_operationlog` VALUES (1239, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:56:16', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:56:16', 2, '2025-08-30 10:56:16');
INSERT INTO `sys_operationlog` VALUES (1240, 2, 1, '会员管理', '切换会员状态', '2025-08-30 10:57:59', '{\"memberId\":1,\"status\":0}', 1, 2, '2025-08-30 10:57:59', 2, '2025-08-30 10:57:59');
INSERT INTO `sys_operationlog` VALUES (1241, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:57:59', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:57:59', 2, '2025-08-30 10:57:59');
INSERT INTO `sys_operationlog` VALUES (1242, 2, 1, '会员管理', '切换会员状态', '2025-08-30 10:58:00', '{\"memberId\":1,\"status\":1}', 1, 2, '2025-08-30 10:58:00', 2, '2025-08-30 10:58:00');
INSERT INTO `sys_operationlog` VALUES (1243, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:58:00', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:58:00', 2, '2025-08-30 10:58:00');
INSERT INTO `sys_operationlog` VALUES (1244, 2, 1, '会员管理', '切换会员状态', '2025-08-30 10:58:00', '{\"memberId\":1,\"status\":0}', 1, 2, '2025-08-30 10:58:00', 2, '2025-08-30 10:58:00');
INSERT INTO `sys_operationlog` VALUES (1245, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:58:00', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:58:00', 2, '2025-08-30 10:58:00');
INSERT INTO `sys_operationlog` VALUES (1246, 2, 1, '会员管理', '切换会员状态', '2025-08-30 10:58:00', '{\"memberId\":1,\"status\":1}', 1, 2, '2025-08-30 10:58:00', 2, '2025-08-30 10:58:00');
INSERT INTO `sys_operationlog` VALUES (1247, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:58:00', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:58:00', 2, '2025-08-30 10:58:00');
INSERT INTO `sys_operationlog` VALUES (1248, 2, 1, '会员管理', '切换会员状态', '2025-08-30 10:58:01', '{\"memberId\":1,\"status\":0}', 1, 2, '2025-08-30 10:58:01', 2, '2025-08-30 10:58:01');
INSERT INTO `sys_operationlog` VALUES (1249, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:58:01', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:58:01', 2, '2025-08-30 10:58:01');
INSERT INTO `sys_operationlog` VALUES (1250, 2, 1, '会员管理', '切换会员状态', '2025-08-30 10:58:01', '{\"memberId\":1,\"status\":1}', 1, 2, '2025-08-30 10:58:01', 2, '2025-08-30 10:58:01');
INSERT INTO `sys_operationlog` VALUES (1251, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:58:01', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:58:01', 2, '2025-08-30 10:58:01');
INSERT INTO `sys_operationlog` VALUES (1252, 2, 1, '会员管理', '切换会员状态', '2025-08-30 10:58:01', '{\"memberId\":1,\"status\":0}', 1, 2, '2025-08-30 10:58:01', 2, '2025-08-30 10:58:01');
INSERT INTO `sys_operationlog` VALUES (1253, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:58:01', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:58:01', 2, '2025-08-30 10:58:01');
INSERT INTO `sys_operationlog` VALUES (1254, 2, 1, '会员管理', '切换会员状态', '2025-08-30 10:58:01', '{\"memberId\":1,\"status\":1}', 1, 2, '2025-08-30 10:58:01', 2, '2025-08-30 10:58:01');
INSERT INTO `sys_operationlog` VALUES (1255, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:58:01', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:58:01', 2, '2025-08-30 10:58:01');
INSERT INTO `sys_operationlog` VALUES (1256, 2, 1, '会员管理', '切换会员状态', '2025-08-30 10:58:01', '{\"memberId\":1,\"status\":0}', 1, 2, '2025-08-30 10:58:01', 2, '2025-08-30 10:58:01');
INSERT INTO `sys_operationlog` VALUES (1257, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:58:01', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:58:01', 2, '2025-08-30 10:58:01');
INSERT INTO `sys_operationlog` VALUES (1258, 2, 1, '会员管理', '切换会员状态', '2025-08-30 10:58:02', '{\"memberId\":1,\"status\":1}', 1, 2, '2025-08-30 10:58:02', 2, '2025-08-30 10:58:02');
INSERT INTO `sys_operationlog` VALUES (1259, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:58:02', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:58:02', 2, '2025-08-30 10:58:02');
INSERT INTO `sys_operationlog` VALUES (1260, 2, 1, '会员管理', '切换会员状态', '2025-08-30 10:58:02', '{\"memberId\":1,\"status\":0}', 1, 2, '2025-08-30 10:58:02', 2, '2025-08-30 10:58:02');
INSERT INTO `sys_operationlog` VALUES (1261, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:58:02', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:58:02', 2, '2025-08-30 10:58:02');
INSERT INTO `sys_operationlog` VALUES (1262, 2, 1, '会员管理', '切换会员状态', '2025-08-30 10:58:03', '{\"memberId\":1,\"status\":1}', 1, 2, '2025-08-30 10:58:03', 2, '2025-08-30 10:58:03');
INSERT INTO `sys_operationlog` VALUES (1263, 2, 4, '会员管理', '会员列表查询', '2025-08-30 10:58:03', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 10:58:03', 2, '2025-08-30 10:58:03');
INSERT INTO `sys_operationlog` VALUES (1264, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-30 10:58:37', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-30 10:58:37', 2, '2025-08-30 10:58:37');
INSERT INTO `sys_operationlog` VALUES (1265, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-30 10:58:37', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-30 10:58:37', 2, '2025-08-30 10:58:37');
INSERT INTO `sys_operationlog` VALUES (1266, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-30 10:58:37', '{\"dishname\":null,\"type\":null,\"page\":0,\"size\":10}', 1, 2, '2025-08-30 10:58:37', 2, '2025-08-30 10:58:37');
INSERT INTO `sys_operationlog` VALUES (1267, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-30 10:58:38', '{}', 1, 2, '2025-08-30 10:58:38', 2, '2025-08-30 10:58:38');
INSERT INTO `sys_operationlog` VALUES (1268, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-30 10:58:38', '{}', 1, 2, '2025-08-30 10:58:38', 2, '2025-08-30 10:58:38');
INSERT INTO `sys_operationlog` VALUES (1269, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-30 10:58:38', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 10:58:38', 2, '2025-08-30 10:58:38');
INSERT INTO `sys_operationlog` VALUES (1270, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-30 10:58:38', '{}', 1, 2, '2025-08-30 10:58:38', 2, '2025-08-30 10:58:38');
INSERT INTO `sys_operationlog` VALUES (1271, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-30 10:58:38', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 10:58:38', 2, '2025-08-30 10:58:38');
INSERT INTO `sys_operationlog` VALUES (1272, 2, 4, '系统设置>角色管理', '菜品管理查询', '2025-08-30 10:58:38', '{}', 1, 2, '2025-08-30 10:58:38', 2, '2025-08-30 10:58:38');
INSERT INTO `sys_operationlog` VALUES (1273, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-30 10:58:38', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 10:58:38', 2, '2025-08-30 10:58:38');
INSERT INTO `sys_operationlog` VALUES (1274, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-30 10:58:38', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 10:58:38', 2, '2025-08-30 10:58:38');
INSERT INTO `sys_operationlog` VALUES (1275, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-30 10:58:41', '{\"mealId\":1}', 1, 2, '2025-08-30 10:58:41', 2, '2025-08-30 10:58:41');
INSERT INTO `sys_operationlog` VALUES (1276, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-30 10:59:05', '{\"mealId\":1}', 1, 2, '2025-08-30 10:59:05', 2, '2025-08-30 10:59:05');
INSERT INTO `sys_operationlog` VALUES (1277, 2, 4, '菜品管理>套餐管理', '套餐详情查询', '2025-08-30 10:59:08', '{\"mealId\":1}', 1, 2, '2025-08-30 10:59:08', 2, '2025-08-30 10:59:08');
INSERT INTO `sys_operationlog` VALUES (1278, 2, 1, '菜品管理>套餐管理', '修改套餐', '2025-08-30 10:59:11', '{\"meal\":{\"meal_id\":1,\"store_id\":2,\"meal_name\":\"1111\",\"price\":111.0,\"original_price\":11.0,\"description\":\"\",\"is_fixed\":0,\"status\":1,\"start_time\":\"2025-07-31T16:00:00\",\"end_time\":\"2025-08-30T16:00:00\"}}', 1, 2, '2025-08-30 10:59:11', 2, '2025-08-30 10:59:11');
INSERT INTO `sys_operationlog` VALUES (1279, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-30 10:59:11', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 10:59:11', 2, '2025-08-30 10:59:11');
INSERT INTO `sys_operationlog` VALUES (1280, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-30 10:59:13', '{\"mealId\":1}', 1, 2, '2025-08-30 10:59:13', 2, '2025-08-30 10:59:13');
INSERT INTO `sys_operationlog` VALUES (1281, 2, 4, '菜品管理>套餐管理', '套餐详情查询', '2025-08-30 10:59:18', '{\"mealId\":1}', 1, 2, '2025-08-30 10:59:18', 2, '2025-08-30 10:59:18');
INSERT INTO `sys_operationlog` VALUES (1282, 2, 1, '菜品管理>套餐管理', '修改套餐', '2025-08-30 10:59:21', '{\"meal\":{\"meal_id\":1,\"store_id\":2,\"meal_name\":\"1111\",\"price\":111.0,\"original_price\":11.0,\"description\":\"\",\"is_fixed\":1,\"status\":1,\"start_time\":\"2025-07-31T16:00:00\",\"end_time\":\"2025-08-30T16:00:00\"}}', 1, 2, '2025-08-30 10:59:21', 2, '2025-08-30 10:59:21');
INSERT INTO `sys_operationlog` VALUES (1283, 2, 4, '菜品管理>套餐管理', '套餐列表查询', '2025-08-30 10:59:21', '{\"storeId\":null,\"mealName\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 10:59:21', 2, '2025-08-30 10:59:21');
INSERT INTO `sys_operationlog` VALUES (1284, 2, 4, '菜品管理>套餐管理', '套餐详情查询', '2025-08-30 10:59:23', '{\"mealId\":1}', 1, 2, '2025-08-30 10:59:23', 2, '2025-08-30 10:59:23');
INSERT INTO `sys_operationlog` VALUES (1285, 2, 4, '菜品管理>套餐管理', '套餐明细查询', '2025-08-30 10:59:25', '{\"mealId\":1}', 1, 2, '2025-08-30 10:59:25', 2, '2025-08-30 10:59:25');
INSERT INTO `sys_operationlog` VALUES (1286, 2, 4, '会员管理', '会员列表查询', '2025-08-30 11:01:56', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:01:56', 2, '2025-08-30 11:01:56');
INSERT INTO `sys_operationlog` VALUES (1287, 2, 4, '会员管理', '会员列表查询', '2025-08-30 11:01:56', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:01:56', 2, '2025-08-30 11:01:56');
INSERT INTO `sys_operationlog` VALUES (1288, 2, 4, '会员管理', '会员列表查询', '2025-08-30 11:01:56', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:01:56', 2, '2025-08-30 11:01:56');
INSERT INTO `sys_operationlog` VALUES (1289, 2, 4, '会员管理', '会员列表查询', '2025-08-30 11:01:56', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:01:56', 2, '2025-08-30 11:01:56');
INSERT INTO `sys_operationlog` VALUES (1290, 2, 4, '会员管理', '会员列表查询', '2025-08-30 11:06:05', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:06:05', 2, '2025-08-30 11:06:05');
INSERT INTO `sys_operationlog` VALUES (1291, 2, 1, '会员管理', '修改会员', '2025-08-30 11:07:24', '{\"member\":{\"member_id\":1,\"member_no\":null,\"phone\":\"15235060638\",\"name\":\"张科国1\",\"birthday\":\"2025-08-17T16:00:00Z\",\"register_time\":\"0001-01-01T00:00:00\",\"status\":0,\"total_points\":0,\"referrer_id\":null,\"balance\":null}}', 1, 2, '2025-08-30 11:07:24', 2, '2025-08-30 11:07:24');
INSERT INTO `sys_operationlog` VALUES (1292, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-30 11:08:04', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:04', 2, '2025-08-30 11:08:04');
INSERT INTO `sys_operationlog` VALUES (1293, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-30 11:08:04', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:04', 2, '2025-08-30 11:08:04');
INSERT INTO `sys_operationlog` VALUES (1294, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-30 11:08:04', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:04', 2, '2025-08-30 11:08:04');
INSERT INTO `sys_operationlog` VALUES (1295, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-30 11:08:04', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:04', 2, '2025-08-30 11:08:04');
INSERT INTO `sys_operationlog` VALUES (1296, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-30 11:08:04', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:04', 2, '2025-08-30 11:08:04');
INSERT INTO `sys_operationlog` VALUES (1297, 2, 4, '系统设置>门店设置', '门店设置查询', '2025-08-30 11:08:04', '{\"StoreName\":null,\"phone\":null,\"address\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:04', 2, '2025-08-30 11:08:04');
INSERT INTO `sys_operationlog` VALUES (1298, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-30 11:08:13', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:13', 2, '2025-08-30 11:08:13');
INSERT INTO `sys_operationlog` VALUES (1299, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-30 11:08:13', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:13', 2, '2025-08-30 11:08:13');
INSERT INTO `sys_operationlog` VALUES (1300, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-30 11:08:13', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:13', 2, '2025-08-30 11:08:13');
INSERT INTO `sys_operationlog` VALUES (1301, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-30 11:08:13', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:13', 2, '2025-08-30 11:08:13');
INSERT INTO `sys_operationlog` VALUES (1302, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-30 11:08:13', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:13', 2, '2025-08-30 11:08:13');
INSERT INTO `sys_operationlog` VALUES (1303, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-30 11:08:13', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:13', 2, '2025-08-30 11:08:13');
INSERT INTO `sys_operationlog` VALUES (1304, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-30 11:08:13', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:13', 2, '2025-08-30 11:08:13');
INSERT INTO `sys_operationlog` VALUES (1305, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-30 11:08:13', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:13', 2, '2025-08-30 11:08:13');
INSERT INTO `sys_operationlog` VALUES (1306, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-30 11:08:20', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:20', 2, '2025-08-30 11:08:20');
INSERT INTO `sys_operationlog` VALUES (1307, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-30 11:08:20', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:20', 2, '2025-08-30 11:08:20');
INSERT INTO `sys_operationlog` VALUES (1308, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-30 11:08:20', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:20', 2, '2025-08-30 11:08:20');
INSERT INTO `sys_operationlog` VALUES (1309, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-30 11:08:20', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:20', 2, '2025-08-30 11:08:20');
INSERT INTO `sys_operationlog` VALUES (1310, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-30 11:08:20', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:20', 2, '2025-08-30 11:08:20');
INSERT INTO `sys_operationlog` VALUES (1311, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-30 11:08:20', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:20', 2, '2025-08-30 11:08:20');
INSERT INTO `sys_operationlog` VALUES (1312, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-30 11:08:20', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:20', 2, '2025-08-30 11:08:20');
INSERT INTO `sys_operationlog` VALUES (1313, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-30 11:08:20', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:20', 2, '2025-08-30 11:08:20');
INSERT INTO `sys_operationlog` VALUES (1314, 2, 4, '系统设置>员工管理', '用户分页查询', '2025-08-30 11:08:21', '{\"name\":null,\"username\":null,\"phone\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:21', 2, '2025-08-30 11:08:21');
INSERT INTO `sys_operationlog` VALUES (1315, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-30 11:08:21', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:21', 2, '2025-08-30 11:08:21');
INSERT INTO `sys_operationlog` VALUES (1316, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-30 11:08:21', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:21', 2, '2025-08-30 11:08:21');
INSERT INTO `sys_operationlog` VALUES (1317, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-30 11:08:21', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:21', 2, '2025-08-30 11:08:21');
INSERT INTO `sys_operationlog` VALUES (1318, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-30 11:08:22', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:22', 2, '2025-08-30 11:08:22');
INSERT INTO `sys_operationlog` VALUES (1319, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-30 11:08:22', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:22', 2, '2025-08-30 11:08:22');
INSERT INTO `sys_operationlog` VALUES (1320, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-30 11:08:22', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:22', 2, '2025-08-30 11:08:22');
INSERT INTO `sys_operationlog` VALUES (1321, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-30 11:08:22', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:22', 2, '2025-08-30 11:08:22');
INSERT INTO `sys_operationlog` VALUES (1322, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-30 11:08:22', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:22', 2, '2025-08-30 11:08:22');
INSERT INTO `sys_operationlog` VALUES (1323, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-30 11:08:22', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:08:22', 2, '2025-08-30 11:08:22');
INSERT INTO `sys_operationlog` VALUES (1324, 2, 4, '会员管理', '会员列表查询', '2025-08-30 11:16:39', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:16:39', 2, '2025-08-30 11:16:39');
INSERT INTO `sys_operationlog` VALUES (1325, 2, 4, '会员管理', '会员列表查询', '2025-08-30 11:16:39', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:16:39', 2, '2025-08-30 11:16:39');
INSERT INTO `sys_operationlog` VALUES (1326, 2, 4, '会员管理', '会员列表查询', '2025-08-30 11:16:39', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:16:39', 2, '2025-08-30 11:16:39');
INSERT INTO `sys_operationlog` VALUES (1327, 2, 4, '会员管理', '会员列表查询', '2025-08-30 11:16:39', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:16:39', 2, '2025-08-30 11:16:39');
INSERT INTO `sys_operationlog` VALUES (1328, 2, 4, '会员管理', '会员列表查询', '2025-08-30 11:16:39', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:16:39', 2, '2025-08-30 11:16:39');
INSERT INTO `sys_operationlog` VALUES (1329, 2, 4, '会员管理', '会员列表查询', '2025-08-30 11:16:39', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:16:39', 2, '2025-08-30 11:16:39');
INSERT INTO `sys_operationlog` VALUES (1330, 2, 4, '会员管理', '会员列表查询', '2025-08-30 11:16:39', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:16:39', 2, '2025-08-30 11:16:39');
INSERT INTO `sys_operationlog` VALUES (1331, 2, 4, '会员管理', '会员列表查询', '2025-08-30 11:16:39', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:16:39', 2, '2025-08-30 11:16:39');
INSERT INTO `sys_operationlog` VALUES (1332, 2, 4, '会员管理', '会员列表查询', '2025-08-30 11:16:39', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:16:39', 2, '2025-08-30 11:16:39');
INSERT INTO `sys_operationlog` VALUES (1333, 2, 4, '会员管理', '储值记录查询', '2025-08-30 11:19:36', '{\"keyword\":null,\"operatorId\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:19:36', 2, '2025-08-30 11:19:36');
INSERT INTO `sys_operationlog` VALUES (1334, 2, 4, '会员管理', '储值记录查询', '2025-08-30 11:19:53', '{\"keyword\":null,\"operatorId\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:19:53', 2, '2025-08-30 11:19:53');
INSERT INTO `sys_operationlog` VALUES (1335, 2, 4, '会员管理', '储值记录查询', '2025-08-30 11:19:58', '{\"keyword\":null,\"operatorId\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:19:58', 2, '2025-08-30 11:19:58');
INSERT INTO `sys_operationlog` VALUES (1336, 2, 4, '会员管理', '储值记录查询', '2025-08-30 11:20:04', '{\"keyword\":null,\"operatorId\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:20:04', 2, '2025-08-30 11:20:04');
INSERT INTO `sys_operationlog` VALUES (1337, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-30 11:21:41', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:21:41', 2, '2025-08-30 11:21:41');
INSERT INTO `sys_operationlog` VALUES (1338, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-30 11:21:41', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:21:41', 2, '2025-08-30 11:21:41');
INSERT INTO `sys_operationlog` VALUES (1339, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-30 11:21:48', '{\"roleId\":1,\"permissionIds\":[1,13,53,2,14,15,16,3,18,19,4,20,21,22,23,5,24,25,26,27,6,28,29,52,7,30,31,32,33,8,34,35,9,38,40,10,41,42,43,11,44,45,46,47,12,48,49,50,51]}', 1, 2, '2025-08-30 11:21:48', 2, '2025-08-30 11:21:48');
INSERT INTO `sys_operationlog` VALUES (1340, 2, 1, '系统设置>角色管理', '修改角色权限', '2025-08-30 11:21:54', '{\"roleId\":3,\"permissionIds\":[1,13,53,2,14,15,16,3,18,19,4,20,21,22,23,5,24,25,26,27,6,28,29,52,7,30,31,32,33,8,34,35,9,38,40,10,41,42,43,11,44,45,46,47,48,49,50,51]}', 1, 2, '2025-08-30 11:21:54', 2, '2025-08-30 11:21:54');
INSERT INTO `sys_operationlog` VALUES (1341, 2, 4, '系统设置>角色管理', '角色管理查询', '2025-08-30 11:22:14', '{\"RoleName\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 11:22:14', 2, '2025-08-30 11:22:14');
INSERT INTO `sys_operationlog` VALUES (1342, 2, 11, '账号登出', '人员退出系统', '2025-08-30 11:45:41', '{}', 1, 2, '2025-08-30 11:45:41', 2, '2025-08-30 11:45:41');
INSERT INTO `sys_operationlog` VALUES (1343, 6, 10, '系统登陆', '人员登陆', '2025-08-30 11:45:49', '账号：lq,员工姓名：lq', 2, 6, '2025-08-30 11:45:49', 6, '2025-08-30 11:45:49');
INSERT INTO `sys_operationlog` VALUES (1344, 6, 4, '订单管理', '查询未结算订单列表', '2025-08-30 11:45:49', '{\"tableId\":null,\"orderno\":null,\"page\":1,\"size\":10}', 2, 6, '2025-08-30 11:45:49', 6, '2025-08-30 11:45:49');
INSERT INTO `sys_operationlog` VALUES (1345, 6, 4, '订单管理', '获取订单明细', '2025-08-30 11:45:53', '{\"orderId\":5}', 2, 6, '2025-08-30 11:45:53', 6, '2025-08-30 11:45:53');
INSERT INTO `sys_operationlog` VALUES (1346, 2, 10, '系统登陆', '人员登陆', '2025-08-30 14:39:30', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-30 14:39:30', 2, '2025-08-30 14:39:30');
INSERT INTO `sys_operationlog` VALUES (1347, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:39:41', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:39:41', 2, '2025-08-30 14:39:41');
INSERT INTO `sys_operationlog` VALUES (1348, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:39:41', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:39:41', 2, '2025-08-30 14:39:41');
INSERT INTO `sys_operationlog` VALUES (1349, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:39:41', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:39:41', 2, '2025-08-30 14:39:41');
INSERT INTO `sys_operationlog` VALUES (1350, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:39:41', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:39:41', 2, '2025-08-30 14:39:41');
INSERT INTO `sys_operationlog` VALUES (1351, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:39:41', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:39:41', 2, '2025-08-30 14:39:41');
INSERT INTO `sys_operationlog` VALUES (1352, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:39:41', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:39:41', 2, '2025-08-30 14:39:41');
INSERT INTO `sys_operationlog` VALUES (1353, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:39:46', '{\"storeId\":2,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:39:46', 2, '2025-08-30 14:39:46');
INSERT INTO `sys_operationlog` VALUES (1354, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:39:46', '{\"storeId\":2,\"kitchenType\":null}', 1, 2, '2025-08-30 14:39:46', 2, '2025-08-30 14:39:46');
INSERT INTO `sys_operationlog` VALUES (1355, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:39:47', '{\"storeId\":2,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:39:47', 2, '2025-08-30 14:39:47');
INSERT INTO `sys_operationlog` VALUES (1356, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:39:47', '{\"storeId\":2,\"kitchenType\":null}', 1, 2, '2025-08-30 14:39:47', 2, '2025-08-30 14:39:47');
INSERT INTO `sys_operationlog` VALUES (1357, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:39:48', '{\"storeId\":2,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:39:48', 2, '2025-08-30 14:39:48');
INSERT INTO `sys_operationlog` VALUES (1358, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:39:48', '{\"storeId\":2,\"kitchenType\":null}', 1, 2, '2025-08-30 14:39:48', 2, '2025-08-30 14:39:48');
INSERT INTO `sys_operationlog` VALUES (1359, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:39:48', '{\"storeId\":2,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:39:48', 2, '2025-08-30 14:39:48');
INSERT INTO `sys_operationlog` VALUES (1360, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:39:48', '{\"storeId\":2,\"kitchenType\":null}', 1, 2, '2025-08-30 14:39:48', 2, '2025-08-30 14:39:48');
INSERT INTO `sys_operationlog` VALUES (1361, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:39:52', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:39:52', 2, '2025-08-30 14:39:52');
INSERT INTO `sys_operationlog` VALUES (1362, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:39:52', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:39:52', 2, '2025-08-30 14:39:52');
INSERT INTO `sys_operationlog` VALUES (1363, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:40:00', '{\"storeId\":null,\"kitchenType\":null,\"status\":1}', 1, 2, '2025-08-30 14:40:00', 2, '2025-08-30 14:40:00');
INSERT INTO `sys_operationlog` VALUES (1364, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:40:00', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:40:00', 2, '2025-08-30 14:40:00');
INSERT INTO `sys_operationlog` VALUES (1365, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:40:05', '{\"storeId\":null,\"kitchenType\":null,\"status\":2}', 1, 2, '2025-08-30 14:40:05', 2, '2025-08-30 14:40:05');
INSERT INTO `sys_operationlog` VALUES (1366, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:40:05', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:40:05', 2, '2025-08-30 14:40:05');
INSERT INTO `sys_operationlog` VALUES (1367, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-30 14:40:18', '{\"storeId\":null,\"kitchenType\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:40:18', 2, '2025-08-30 14:40:18');
INSERT INTO `sys_operationlog` VALUES (1368, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-30 14:40:18', '{\"storeId\":null,\"kitchenType\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:40:18', 2, '2025-08-30 14:40:18');
INSERT INTO `sys_operationlog` VALUES (1369, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-30 14:40:18', '{\"storeId\":null,\"kitchenType\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:40:18', 2, '2025-08-30 14:40:18');
INSERT INTO `sys_operationlog` VALUES (1370, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:40:30', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:40:30', 2, '2025-08-30 14:40:30');
INSERT INTO `sys_operationlog` VALUES (1371, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:40:30', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:40:30', 2, '2025-08-30 14:40:30');
INSERT INTO `sys_operationlog` VALUES (1372, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:40:30', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:40:30', 2, '2025-08-30 14:40:30');
INSERT INTO `sys_operationlog` VALUES (1373, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:40:30', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:40:30', 2, '2025-08-30 14:40:30');
INSERT INTO `sys_operationlog` VALUES (1374, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:40:30', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:40:30', 2, '2025-08-30 14:40:30');
INSERT INTO `sys_operationlog` VALUES (1375, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:40:30', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:40:30', 2, '2025-08-30 14:40:30');
INSERT INTO `sys_operationlog` VALUES (1376, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:40:30', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:40:30', 2, '2025-08-30 14:40:30');
INSERT INTO `sys_operationlog` VALUES (1377, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:40:30', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:40:30', 2, '2025-08-30 14:40:30');
INSERT INTO `sys_operationlog` VALUES (1378, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:40:30', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:40:30', 2, '2025-08-30 14:40:30');
INSERT INTO `sys_operationlog` VALUES (1379, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-30 14:40:33', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:40:33', 2, '2025-08-30 14:40:33');
INSERT INTO `sys_operationlog` VALUES (1380, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-30 14:40:33', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:40:33', 2, '2025-08-30 14:40:33');
INSERT INTO `sys_operationlog` VALUES (1381, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-30 14:40:33', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:40:33', 2, '2025-08-30 14:40:33');
INSERT INTO `sys_operationlog` VALUES (1382, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-30 14:40:34', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:40:34', 2, '2025-08-30 14:40:34');
INSERT INTO `sys_operationlog` VALUES (1383, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-30 14:40:35', '{\"storeId\":null,\"kitchenType\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:40:35', 2, '2025-08-30 14:40:35');
INSERT INTO `sys_operationlog` VALUES (1384, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-30 14:40:35', '{\"storeId\":null,\"kitchenType\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:40:35', 2, '2025-08-30 14:40:35');
INSERT INTO `sys_operationlog` VALUES (1385, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-30 14:40:35', '{\"storeId\":null,\"kitchenType\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:40:35', 2, '2025-08-30 14:40:35');
INSERT INTO `sys_operationlog` VALUES (1386, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-30 14:40:35', '{\"storeId\":null,\"kitchenType\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:40:35', 2, '2025-08-30 14:40:35');
INSERT INTO `sys_operationlog` VALUES (1387, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:40:37', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:40:37', 2, '2025-08-30 14:40:37');
INSERT INTO `sys_operationlog` VALUES (1388, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:40:37', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:40:37', 2, '2025-08-30 14:40:37');
INSERT INTO `sys_operationlog` VALUES (1389, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:40:37', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:40:37', 2, '2025-08-30 14:40:37');
INSERT INTO `sys_operationlog` VALUES (1390, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:40:37', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:40:37', 2, '2025-08-30 14:40:37');
INSERT INTO `sys_operationlog` VALUES (1391, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:40:37', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:40:37', 2, '2025-08-30 14:40:37');
INSERT INTO `sys_operationlog` VALUES (1392, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:40:37', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:40:37', 2, '2025-08-30 14:40:37');
INSERT INTO `sys_operationlog` VALUES (1393, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:40:37', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:40:37', 2, '2025-08-30 14:40:37');
INSERT INTO `sys_operationlog` VALUES (1394, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:40:37', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:40:37', 2, '2025-08-30 14:40:37');
INSERT INTO `sys_operationlog` VALUES (1395, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:40:37', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:40:37', 2, '2025-08-30 14:40:37');
INSERT INTO `sys_operationlog` VALUES (1396, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:40:37', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:40:37', 2, '2025-08-30 14:40:37');
INSERT INTO `sys_operationlog` VALUES (1397, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:40:37', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:40:37', 2, '2025-08-30 14:40:37');
INSERT INTO `sys_operationlog` VALUES (1398, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:40:37', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:40:37', 2, '2025-08-30 14:40:37');
INSERT INTO `sys_operationlog` VALUES (1399, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:44:56', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:44:56', 2, '2025-08-30 14:44:56');
INSERT INTO `sys_operationlog` VALUES (1400, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:44:56', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:44:56', 2, '2025-08-30 14:44:56');
INSERT INTO `sys_operationlog` VALUES (1401, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:44:56', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:44:56', 2, '2025-08-30 14:44:56');
INSERT INTO `sys_operationlog` VALUES (1402, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:44:56', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:44:56', 2, '2025-08-30 14:44:56');
INSERT INTO `sys_operationlog` VALUES (1403, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:44:56', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:44:56', 2, '2025-08-30 14:44:56');
INSERT INTO `sys_operationlog` VALUES (1404, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:44:56', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:44:56', 2, '2025-08-30 14:44:56');
INSERT INTO `sys_operationlog` VALUES (1405, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:44:56', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:44:56', 2, '2025-08-30 14:44:56');
INSERT INTO `sys_operationlog` VALUES (1406, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:44:56', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:44:56', 2, '2025-08-30 14:44:56');
INSERT INTO `sys_operationlog` VALUES (1407, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:44:56', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:44:56', 2, '2025-08-30 14:44:56');
INSERT INTO `sys_operationlog` VALUES (1408, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:44:56', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:44:56', 2, '2025-08-30 14:44:56');
INSERT INTO `sys_operationlog` VALUES (1409, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:44:56', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:44:56', 2, '2025-08-30 14:44:56');
INSERT INTO `sys_operationlog` VALUES (1410, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:44:56', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:44:56', 2, '2025-08-30 14:44:56');
INSERT INTO `sys_operationlog` VALUES (1411, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:45:12', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:45:12', 2, '2025-08-30 14:45:12');
INSERT INTO `sys_operationlog` VALUES (1412, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:45:12', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:45:12', 2, '2025-08-30 14:45:12');
INSERT INTO `sys_operationlog` VALUES (1413, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:45:12', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:45:12', 2, '2025-08-30 14:45:12');
INSERT INTO `sys_operationlog` VALUES (1414, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:45:12', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:45:12', 2, '2025-08-30 14:45:12');
INSERT INTO `sys_operationlog` VALUES (1415, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:45:12', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:45:12', 2, '2025-08-30 14:45:12');
INSERT INTO `sys_operationlog` VALUES (1416, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:45:12', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:45:12', 2, '2025-08-30 14:45:12');
INSERT INTO `sys_operationlog` VALUES (1417, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:45:12', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:45:12', 2, '2025-08-30 14:45:12');
INSERT INTO `sys_operationlog` VALUES (1418, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:45:12', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:45:12', 2, '2025-08-30 14:45:12');
INSERT INTO `sys_operationlog` VALUES (1419, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:45:12', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:45:12', 2, '2025-08-30 14:45:12');
INSERT INTO `sys_operationlog` VALUES (1420, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:45:12', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:45:12', 2, '2025-08-30 14:45:12');
INSERT INTO `sys_operationlog` VALUES (1421, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:45:12', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:45:12', 2, '2025-08-30 14:45:12');
INSERT INTO `sys_operationlog` VALUES (1422, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:45:12', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:45:12', 2, '2025-08-30 14:45:12');
INSERT INTO `sys_operationlog` VALUES (1423, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:45:37', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:45:37', 2, '2025-08-30 14:45:37');
INSERT INTO `sys_operationlog` VALUES (1424, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:45:37', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:45:37', 2, '2025-08-30 14:45:37');
INSERT INTO `sys_operationlog` VALUES (1425, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:45:37', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:45:37', 2, '2025-08-30 14:45:37');
INSERT INTO `sys_operationlog` VALUES (1426, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:45:37', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:45:37', 2, '2025-08-30 14:45:37');
INSERT INTO `sys_operationlog` VALUES (1427, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:45:37', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:45:37', 2, '2025-08-30 14:45:37');
INSERT INTO `sys_operationlog` VALUES (1428, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:45:37', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:45:37', 2, '2025-08-30 14:45:37');
INSERT INTO `sys_operationlog` VALUES (1429, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:45:37', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:45:37', 2, '2025-08-30 14:45:37');
INSERT INTO `sys_operationlog` VALUES (1430, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:45:37', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:45:37', 2, '2025-08-30 14:45:37');
INSERT INTO `sys_operationlog` VALUES (1431, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:45:37', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:45:37', 2, '2025-08-30 14:45:37');
INSERT INTO `sys_operationlog` VALUES (1432, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:45:38', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:45:38', 2, '2025-08-30 14:45:38');
INSERT INTO `sys_operationlog` VALUES (1433, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:45:38', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:45:38', 2, '2025-08-30 14:45:38');
INSERT INTO `sys_operationlog` VALUES (1434, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:45:38', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:45:38', 2, '2025-08-30 14:45:38');
INSERT INTO `sys_operationlog` VALUES (1435, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:45:45', '{\"storeId\":null,\"kitchenType\":null,\"status\":5}', 1, 2, '2025-08-30 14:45:45', 2, '2025-08-30 14:45:45');
INSERT INTO `sys_operationlog` VALUES (1436, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:45:45', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:45:45', 2, '2025-08-30 14:45:45');
INSERT INTO `sys_operationlog` VALUES (1437, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-30 14:45:48', '{\"storeId\":null,\"kitchenType\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:45:48', 2, '2025-08-30 14:45:48');
INSERT INTO `sys_operationlog` VALUES (1438, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-30 14:45:48', '{\"storeId\":null,\"kitchenType\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:45:48', 2, '2025-08-30 14:45:48');
INSERT INTO `sys_operationlog` VALUES (1439, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-30 14:45:48', '{\"storeId\":null,\"kitchenType\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:45:48', 2, '2025-08-30 14:45:48');
INSERT INTO `sys_operationlog` VALUES (1440, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-30 14:45:48', '{\"storeId\":null,\"kitchenType\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:45:48', 2, '2025-08-30 14:45:48');
INSERT INTO `sys_operationlog` VALUES (1441, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:46:40', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:46:40', 2, '2025-08-30 14:46:40');
INSERT INTO `sys_operationlog` VALUES (1442, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:46:40', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:46:40', 2, '2025-08-30 14:46:40');
INSERT INTO `sys_operationlog` VALUES (1443, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:46:41', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:46:41', 2, '2025-08-30 14:46:41');
INSERT INTO `sys_operationlog` VALUES (1444, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:46:41', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:46:41', 2, '2025-08-30 14:46:41');
INSERT INTO `sys_operationlog` VALUES (1445, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:46:41', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:46:41', 2, '2025-08-30 14:46:41');
INSERT INTO `sys_operationlog` VALUES (1446, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:46:41', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:46:41', 2, '2025-08-30 14:46:41');
INSERT INTO `sys_operationlog` VALUES (1447, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:46:41', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:46:41', 2, '2025-08-30 14:46:41');
INSERT INTO `sys_operationlog` VALUES (1448, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 14:46:41', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 14:46:41', 2, '2025-08-30 14:46:41');
INSERT INTO `sys_operationlog` VALUES (1449, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:46:41', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:46:41', 2, '2025-08-30 14:46:41');
INSERT INTO `sys_operationlog` VALUES (1450, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:46:41', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:46:41', 2, '2025-08-30 14:46:41');
INSERT INTO `sys_operationlog` VALUES (1451, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:46:41', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:46:41', 2, '2025-08-30 14:46:41');
INSERT INTO `sys_operationlog` VALUES (1452, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 14:46:41', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 14:46:41', 2, '2025-08-30 14:46:41');
INSERT INTO `sys_operationlog` VALUES (1453, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-30 14:46:42', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:42', 2, '2025-08-30 14:46:42');
INSERT INTO `sys_operationlog` VALUES (1454, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-30 14:46:42', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:42', 2, '2025-08-30 14:46:42');
INSERT INTO `sys_operationlog` VALUES (1455, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-30 14:46:42', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:42', 2, '2025-08-30 14:46:42');
INSERT INTO `sys_operationlog` VALUES (1456, 2, 4, '系统设置>厨房管理', '厨房列表查询', '2025-08-30 14:46:42', '{\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:42', 2, '2025-08-30 14:46:42');
INSERT INTO `sys_operationlog` VALUES (1457, 2, 4, '会员管理', '会员列表查询', '2025-08-30 14:46:48', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:48', 2, '2025-08-30 14:46:48');
INSERT INTO `sys_operationlog` VALUES (1458, 2, 4, '会员管理', '会员列表查询', '2025-08-30 14:46:48', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:48', 2, '2025-08-30 14:46:48');
INSERT INTO `sys_operationlog` VALUES (1459, 2, 4, '会员管理', '会员列表查询', '2025-08-30 14:46:48', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:48', 2, '2025-08-30 14:46:48');
INSERT INTO `sys_operationlog` VALUES (1460, 2, 4, '会员管理', '会员列表查询', '2025-08-30 14:46:48', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:48', 2, '2025-08-30 14:46:48');
INSERT INTO `sys_operationlog` VALUES (1461, 2, 4, '会员管理', '会员列表查询', '2025-08-30 14:46:48', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:48', 2, '2025-08-30 14:46:48');
INSERT INTO `sys_operationlog` VALUES (1462, 2, 4, '会员管理', '储值记录查询', '2025-08-30 14:46:50', '{\"keyword\":null,\"operatorId\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:50', 2, '2025-08-30 14:46:50');
INSERT INTO `sys_operationlog` VALUES (1463, 2, 4, '会员管理', '储值记录查询', '2025-08-30 14:46:50', '{\"keyword\":null,\"operatorId\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:50', 2, '2025-08-30 14:46:50');
INSERT INTO `sys_operationlog` VALUES (1464, 2, 4, '会员管理', '储值记录查询', '2025-08-30 14:46:50', '{\"keyword\":null,\"operatorId\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:50', 2, '2025-08-30 14:46:50');
INSERT INTO `sys_operationlog` VALUES (1465, 2, 4, '会员管理', '储值记录查询', '2025-08-30 14:46:50', '{\"keyword\":null,\"operatorId\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:50', 2, '2025-08-30 14:46:50');
INSERT INTO `sys_operationlog` VALUES (1466, 2, 4, '会员管理', '储值记录查询', '2025-08-30 14:46:50', '{\"keyword\":null,\"operatorId\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:50', 2, '2025-08-30 14:46:50');
INSERT INTO `sys_operationlog` VALUES (1467, 2, 4, '会员管理', '储值记录查询', '2025-08-30 14:46:50', '{\"keyword\":null,\"operatorId\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:50', 2, '2025-08-30 14:46:50');
INSERT INTO `sys_operationlog` VALUES (1468, 2, 4, '会员管理', '会员列表查询', '2025-08-30 14:46:52', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:52', 2, '2025-08-30 14:46:52');
INSERT INTO `sys_operationlog` VALUES (1469, 2, 4, '会员管理', '会员列表查询', '2025-08-30 14:46:52', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:52', 2, '2025-08-30 14:46:52');
INSERT INTO `sys_operationlog` VALUES (1470, 2, 4, '会员管理', '会员列表查询', '2025-08-30 14:46:52', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:52', 2, '2025-08-30 14:46:52');
INSERT INTO `sys_operationlog` VALUES (1471, 2, 4, '会员管理', '会员列表查询', '2025-08-30 14:46:52', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:52', 2, '2025-08-30 14:46:52');
INSERT INTO `sys_operationlog` VALUES (1472, 2, 4, '会员管理', '会员列表查询', '2025-08-30 14:46:52', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:52', 2, '2025-08-30 14:46:52');
INSERT INTO `sys_operationlog` VALUES (1473, 2, 4, '会员管理', '会员列表查询', '2025-08-30 14:46:52', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 14:46:52', 2, '2025-08-30 14:46:52');
INSERT INTO `sys_operationlog` VALUES (1474, 2, 10, '系统登陆', '人员登陆', '2025-08-30 14:57:59', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-30 14:57:59', 2, '2025-08-30 14:57:59');
INSERT INTO `sys_operationlog` VALUES (1475, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 14:58:04', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 14:58:04', 2, '2025-08-30 14:58:04');
INSERT INTO `sys_operationlog` VALUES (1476, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 14:58:04', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 14:58:04', 2, '2025-08-30 14:58:04');
INSERT INTO `sys_operationlog` VALUES (1477, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:00:25', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:00:25', 2, '2025-08-30 15:00:25');
INSERT INTO `sys_operationlog` VALUES (1478, 2, 3, '营销管理>促销活动', '新增促销活动', '2025-08-30 15:02:17', '{\"promotion\":{\"promotion_id\":0,\"store_id\":2,\"promotion_name\":\"满200减20\",\"type\":0,\"start_time\":\"2025-08-19T16:00:00Z\",\"end_time\":\"2025-08-29T16:00:00Z\",\"rule\":{\"ValueKind\":3},\"applicable_scope\":\"111\",\"status\":0}}', 1, 2, '2025-08-30 15:02:17', 2, '2025-08-30 15:02:17');
INSERT INTO `sys_operationlog` VALUES (1479, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:02:17', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:02:17', 2, '2025-08-30 15:02:17');
INSERT INTO `sys_operationlog` VALUES (1480, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:03:43', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:03:43', 2, '2025-08-30 15:03:43');
INSERT INTO `sys_operationlog` VALUES (1481, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:05:46', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:05:46', 2, '2025-08-30 15:05:46');
INSERT INTO `sys_operationlog` VALUES (1482, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:08:18', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:08:18', 2, '2025-08-30 15:08:18');
INSERT INTO `sys_operationlog` VALUES (1483, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:08:54', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:08:54', 2, '2025-08-30 15:08:54');
INSERT INTO `sys_operationlog` VALUES (1484, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:10:32', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:10:32', 2, '2025-08-30 15:10:32');
INSERT INTO `sys_operationlog` VALUES (1485, 2, 1, '营销管理>促销活动', '编辑促销活动', '2025-08-30 15:10:40', '{\"promotion\":{\"promotion_id\":1,\"store_id\":2,\"promotion_name\":\"满200减20\",\"type\":0,\"start_time\":\"2025-08-29T16:00:00\",\"end_time\":\"2025-08-29T16:00:00\",\"rule\":{\"ValueKind\":3},\"applicable_scope\":\"111\",\"status\":1}}', 1, 2, '2025-08-30 15:10:40', 2, '2025-08-30 15:10:40');
INSERT INTO `sys_operationlog` VALUES (1486, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:10:40', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:10:40', 2, '2025-08-30 15:10:40');
INSERT INTO `sys_operationlog` VALUES (1487, 2, 1, '营销管理>促销活动', '编辑促销活动', '2025-08-30 15:10:52', '{\"promotion\":{\"promotion_id\":1,\"store_id\":2,\"promotion_name\":\"满200减20\",\"type\":0,\"start_time\":\"2025-08-29T16:00:00\",\"end_time\":\"2025-08-29T16:00:00\",\"rule\":{\"ValueKind\":3},\"applicable_scope\":\"111\",\"status\":1}}', 1, 2, '2025-08-30 15:10:52', 2, '2025-08-30 15:10:52');
INSERT INTO `sys_operationlog` VALUES (1488, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:10:52', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:10:52', 2, '2025-08-30 15:10:52');
INSERT INTO `sys_operationlog` VALUES (1489, 2, 1, '营销管理>促销活动', '编辑促销活动', '2025-08-30 15:18:06', '{\"promotion\":{\"promotion_id\":1,\"store_id\":2,\"promotion_name\":\"满200减20\",\"type\":0,\"start_time\":\"2025-08-29T16:00:00\",\"end_time\":\"2025-08-29T16:00:00\",\"rule\":{\"ValueKind\":3},\"applicable_scope\":\"111\",\"status\":1}}', 1, 2, '2025-08-30 15:18:06', 2, '2025-08-30 15:18:06');
INSERT INTO `sys_operationlog` VALUES (1490, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:18:06', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:18:06', 2, '2025-08-30 15:18:06');
INSERT INTO `sys_operationlog` VALUES (1491, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:19:07', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:19:07', 2, '2025-08-30 15:19:07');
INSERT INTO `sys_operationlog` VALUES (1492, 2, 1, '营销管理>促销活动', '编辑促销活动', '2025-08-30 15:19:27', '{\"promotion\":{\"promotion_id\":1,\"store_id\":2,\"promotion_name\":\"满200减20\",\"type\":0,\"start_time\":\"2025-08-29T16:00:00\",\"end_time\":\"2025-08-29T16:00:00\",\"rule\":{\"ValueKind\":3},\"applicable_scope\":\"111\",\"status\":1}}', 1, 2, '2025-08-30 15:19:27', 2, '2025-08-30 15:19:27');
INSERT INTO `sys_operationlog` VALUES (1493, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:19:27', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:19:27', 2, '2025-08-30 15:19:27');
INSERT INTO `sys_operationlog` VALUES (1494, 2, 1, '营销管理>促销活动', '编辑促销活动', '2025-08-30 15:19:36', '{\"promotion\":{\"promotion_id\":1,\"store_id\":2,\"promotion_name\":\"满200减20\",\"type\":0,\"start_time\":\"2025-08-12T00:00:00\",\"end_time\":\"2025-08-28T00:00:00\",\"rule\":{\"ValueKind\":3},\"applicable_scope\":\"111\",\"status\":1}}', 1, 2, '2025-08-30 15:19:36', 2, '2025-08-30 15:19:36');
INSERT INTO `sys_operationlog` VALUES (1495, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:19:36', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:19:36', 2, '2025-08-30 15:19:36');
INSERT INTO `sys_operationlog` VALUES (1496, 2, 1, '营销管理>促销活动', '编辑促销活动', '2025-08-30 15:19:41', '{\"promotion\":{\"promotion_id\":1,\"store_id\":2,\"promotion_name\":\"满200减20\",\"type\":0,\"start_time\":\"2025-08-12T00:00:00\",\"end_time\":\"2025-08-28T00:00:00\",\"rule\":{\"ValueKind\":3},\"applicable_scope\":\"111\",\"status\":1}}', 1, 2, '2025-08-30 15:19:41', 2, '2025-08-30 15:19:41');
INSERT INTO `sys_operationlog` VALUES (1497, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:19:41', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:19:41', 2, '2025-08-30 15:19:41');
INSERT INTO `sys_operationlog` VALUES (1498, 2, 3, '营销管理>促销活动', '新增促销活动', '2025-08-30 15:20:03', '{\"promotion\":{\"promotion_id\":0,\"store_id\":2,\"promotion_name\":\"11\",\"type\":1,\"start_time\":\"2025-08-04T00:00:00\",\"end_time\":\"2025-08-05T00:00:00\",\"rule\":{\"ValueKind\":3},\"applicable_scope\":\"111\",\"status\":0}}', 1, 2, '2025-08-30 15:20:03', 2, '2025-08-30 15:20:03');
INSERT INTO `sys_operationlog` VALUES (1499, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:20:03', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:20:03', 2, '2025-08-30 15:20:03');
INSERT INTO `sys_operationlog` VALUES (1500, 2, 2, '营销管理>促销活动', '删除促销活动', '2025-08-30 15:20:17', '{\"promotionId\":2}', 1, 2, '2025-08-30 15:20:17', 2, '2025-08-30 15:20:17');
INSERT INTO `sys_operationlog` VALUES (1501, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:20:17', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:20:17', 2, '2025-08-30 15:20:17');
INSERT INTO `sys_operationlog` VALUES (1502, 2, 3, '营销管理>促销活动', '新增促销活动', '2025-08-30 15:20:56', '{\"promotion\":{\"promotion_id\":0,\"store_id\":2,\"promotion_name\":\"11\",\"type\":0,\"start_time\":\"2025-08-04T00:00:00\",\"end_time\":\"2025-08-06T00:00:00\",\"rule\":{\"ValueKind\":3},\"applicable_scope\":\"111\",\"status\":0}}', 1, 2, '2025-08-30 15:20:56', 2, '2025-08-30 15:20:56');
INSERT INTO `sys_operationlog` VALUES (1503, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:20:57', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:20:57', 2, '2025-08-30 15:20:57');
INSERT INTO `sys_operationlog` VALUES (1504, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:22:20', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:22:20', 2, '2025-08-30 15:22:20');
INSERT INTO `sys_operationlog` VALUES (1505, 2, 3, '营销管理>促销活动', '新增促销活动', '2025-08-30 15:22:40', '{\"promotion\":{\"promotion_id\":0,\"store_id\":0,\"promotion_name\":\"111\",\"type\":0,\"start_time\":\"2025-08-03T00:00:00\",\"end_time\":\"2025-08-04T00:00:00\",\"rule\":{\"ValueKind\":3},\"applicable_scope\":\"111\",\"status\":2}}', 1, 2, '2025-08-30 15:22:40', 2, '2025-08-30 15:22:40');
INSERT INTO `sys_operationlog` VALUES (1506, 2, 3, '营销管理>促销活动', '新增促销活动', '2025-08-30 15:23:06', '{\"promotion\":{\"promotion_id\":0,\"store_id\":0,\"promotion_name\":\"111\",\"type\":0,\"start_time\":\"2025-08-03T00:00:00\",\"end_time\":\"2025-08-04T00:00:00\",\"rule\":{\"ValueKind\":3},\"applicable_scope\":\"111\",\"status\":2}}', 1, 2, '2025-08-30 15:23:06', 2, '2025-08-30 15:23:06');
INSERT INTO `sys_operationlog` VALUES (1507, 2, 3, '营销管理>促销活动', '新增促销活动', '2025-08-30 15:24:14', '{\"promotion\":{\"promotion_id\":0,\"store_id\":0,\"promotion_name\":\"111\",\"type\":0,\"start_time\":\"2025-08-03T00:00:00\",\"end_time\":\"2025-08-04T00:00:00\",\"rule\":{\"ValueKind\":3},\"applicable_scope\":\"111\",\"status\":2}}', 1, 2, '2025-08-30 15:24:14', 2, '2025-08-30 15:24:14');
INSERT INTO `sys_operationlog` VALUES (1508, 2, 3, '营销管理>促销活动', '新增促销活动', '2025-08-30 15:24:32', '{\"promotion\":{\"promotion_id\":0,\"store_id\":0,\"promotion_name\":\"111\",\"type\":0,\"start_time\":\"2025-08-03T00:00:00\",\"end_time\":\"2025-08-04T00:00:00\",\"rule\":{\"ValueKind\":3},\"applicable_scope\":\"111\",\"status\":2}}', 1, 2, '2025-08-30 15:24:32', 2, '2025-08-30 15:24:32');
INSERT INTO `sys_operationlog` VALUES (1509, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:24:32', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:24:32', 2, '2025-08-30 15:24:32');
INSERT INTO `sys_operationlog` VALUES (1510, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:29:14', '{\"storeId\":2,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:29:14', 2, '2025-08-30 15:29:14');
INSERT INTO `sys_operationlog` VALUES (1511, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 15:29:24', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 15:29:24', 2, '2025-08-30 15:29:24');
INSERT INTO `sys_operationlog` VALUES (1512, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 15:29:24', '{\"storeId\":null,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 15:29:24', 2, '2025-08-30 15:29:24');
INSERT INTO `sys_operationlog` VALUES (1513, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 15:29:24', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 15:29:24', 2, '2025-08-30 15:29:24');
INSERT INTO `sys_operationlog` VALUES (1514, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 15:29:24', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 15:29:24', 2, '2025-08-30 15:29:24');
INSERT INTO `sys_operationlog` VALUES (1515, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 15:29:24', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 15:29:24', 2, '2025-08-30 15:29:24');
INSERT INTO `sys_operationlog` VALUES (1516, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 15:29:24', '{\"storeId\":null,\"kitchenType\":null}', 1, 2, '2025-08-30 15:29:24', 2, '2025-08-30 15:29:24');
INSERT INTO `sys_operationlog` VALUES (1517, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 15:29:27', '{\"storeId\":2,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 15:29:27', 2, '2025-08-30 15:29:27');
INSERT INTO `sys_operationlog` VALUES (1518, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 15:29:27', '{\"storeId\":2,\"kitchenType\":null}', 1, 2, '2025-08-30 15:29:27', 2, '2025-08-30 15:29:27');
INSERT INTO `sys_operationlog` VALUES (1519, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 15:29:28', '{\"storeId\":2,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 15:29:28', 2, '2025-08-30 15:29:28');
INSERT INTO `sys_operationlog` VALUES (1520, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 15:29:28', '{\"storeId\":2,\"kitchenType\":null}', 1, 2, '2025-08-30 15:29:28', 2, '2025-08-30 15:29:28');
INSERT INTO `sys_operationlog` VALUES (1521, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 15:29:28', '{\"storeId\":2,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 15:29:28', 2, '2025-08-30 15:29:28');
INSERT INTO `sys_operationlog` VALUES (1522, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 15:29:28', '{\"storeId\":2,\"kitchenType\":null}', 1, 2, '2025-08-30 15:29:28', 2, '2025-08-30 15:29:28');
INSERT INTO `sys_operationlog` VALUES (1523, 2, 4, '厨房管理', '厨房订单查询', '2025-08-30 15:29:30', '{\"storeId\":2,\"kitchenType\":null,\"status\":null}', 1, 2, '2025-08-30 15:29:30', 2, '2025-08-30 15:29:30');
INSERT INTO `sys_operationlog` VALUES (1524, 2, 4, '厨房管理', '订单状态统计', '2025-08-30 15:29:30', '{\"storeId\":2,\"kitchenType\":null}', 1, 2, '2025-08-30 15:29:30', 2, '2025-08-30 15:29:30');
INSERT INTO `sys_operationlog` VALUES (1525, 2, 4, '会员管理', '会员列表查询', '2025-08-30 15:29:40', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 15:29:40', 2, '2025-08-30 15:29:40');
INSERT INTO `sys_operationlog` VALUES (1526, 2, 4, '会员管理', '会员列表查询', '2025-08-30 15:29:40', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 15:29:40', 2, '2025-08-30 15:29:40');
INSERT INTO `sys_operationlog` VALUES (1527, 2, 4, '会员管理', '会员列表查询', '2025-08-30 15:29:40', '{\"phone\":null,\"name\":null,\"status\":null,\"page\":1,\"size\":10}', 1, 2, '2025-08-30 15:29:40', 2, '2025-08-30 15:29:40');
INSERT INTO `sys_operationlog` VALUES (1528, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:29:43', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:29:43', 2, '2025-08-30 15:29:43');
INSERT INTO `sys_operationlog` VALUES (1529, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:29:43', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:29:43', 2, '2025-08-30 15:29:43');
INSERT INTO `sys_operationlog` VALUES (1530, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 15:29:43', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 15:29:43', 2, '2025-08-30 15:29:43');
INSERT INTO `sys_operationlog` VALUES (1531, 2, 10, '系统登陆', '人员登陆', '2025-08-30 15:43:16', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-30 15:43:16', 2, '2025-08-30 15:43:16');
INSERT INTO `sys_operationlog` VALUES (1532, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:13:44', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:13:44', 2, '2025-08-30 16:13:44');
INSERT INTO `sys_operationlog` VALUES (1533, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:13:45', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:13:45', 2, '2025-08-30 16:13:45');
INSERT INTO `sys_operationlog` VALUES (1534, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:13:45', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:13:45', 2, '2025-08-30 16:13:45');
INSERT INTO `sys_operationlog` VALUES (1535, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:13:45', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:13:45', 2, '2025-08-30 16:13:45');
INSERT INTO `sys_operationlog` VALUES (1536, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:14:45', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:14:45', 2, '2025-08-30 16:14:45');
INSERT INTO `sys_operationlog` VALUES (1537, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:18:30', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:18:30', 2, '2025-08-30 16:18:30');
INSERT INTO `sys_operationlog` VALUES (1538, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:18:33', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:18:33', 2, '2025-08-30 16:18:33');
INSERT INTO `sys_operationlog` VALUES (1539, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:26:46', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:26:46', 2, '2025-08-30 16:26:46');
INSERT INTO `sys_operationlog` VALUES (1540, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:33:05', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:33:05', 2, '2025-08-30 16:33:05');
INSERT INTO `sys_operationlog` VALUES (1541, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:34:13', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:34:13', 2, '2025-08-30 16:34:13');
INSERT INTO `sys_operationlog` VALUES (1542, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:34:31', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:34:31', 2, '2025-08-30 16:34:31');
INSERT INTO `sys_operationlog` VALUES (1543, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:36:48', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:36:48', 2, '2025-08-30 16:36:48');
INSERT INTO `sys_operationlog` VALUES (1544, 2, 3, '营销管理>优惠券管理', '新增优惠券', '2025-08-30 16:37:38', '{\"coupon\":{\"coupon_id\":0,\"store_id\":2,\"coupon_no\":\"\",\"coupon_name\":\"111\",\"type\":0,\"value\":200.0,\"min_consumption\":1000.0,\"valid_start\":\"2025-08-29T00:00:00\",\"valid_end\":\"2025-09-18T00:00:00\",\"status\":1,\"applicable_dishes\":\"\"}}', 1, 2, '2025-08-30 16:37:38', 2, '2025-08-30 16:37:38');
INSERT INTO `sys_operationlog` VALUES (1545, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:37:39', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:37:39', 2, '2025-08-30 16:37:39');
INSERT INTO `sys_operationlog` VALUES (1546, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:38:51', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:38:51', 2, '2025-08-30 16:38:51');
INSERT INTO `sys_operationlog` VALUES (1547, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:41:22', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:41:22', 2, '2025-08-30 16:41:22');
INSERT INTO `sys_operationlog` VALUES (1548, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:42:34', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:42:34', 2, '2025-08-30 16:42:34');
INSERT INTO `sys_operationlog` VALUES (1549, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:43:51', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:43:51', 2, '2025-08-30 16:43:51');
INSERT INTO `sys_operationlog` VALUES (1550, 2, 4, '营销管理>优惠券管理', '优惠券详情查询', '2025-08-30 16:43:57', '{\"couponId\":1}', 1, 2, '2025-08-30 16:43:57', 2, '2025-08-30 16:43:57');
INSERT INTO `sys_operationlog` VALUES (1551, 2, 1, '营销管理>优惠券管理', '编辑优惠券', '2025-08-30 16:44:08', '{\"coupon\":{\"coupon_id\":1,\"store_id\":2,\"coupon_no\":\"\",\"coupon_name\":\"111111\",\"type\":0,\"value\":200.0,\"min_consumption\":1000.0,\"valid_start\":\"2025-08-29T00:00:00\",\"valid_end\":\"2025-09-19T00:00:00\",\"status\":1,\"applicable_dishes\":\"\"}}', 1, 2, '2025-08-30 16:44:08', 2, '2025-08-30 16:44:08');
INSERT INTO `sys_operationlog` VALUES (1552, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:44:08', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:44:08', 2, '2025-08-30 16:44:08');
INSERT INTO `sys_operationlog` VALUES (1553, 2, 3, '营销管理>优惠券管理', '新增优惠券', '2025-08-30 16:44:39', '{\"coupon\":{\"coupon_id\":0,\"store_id\":0,\"coupon_no\":\"\",\"coupon_name\":\"222\",\"type\":1,\"value\":100.0,\"min_consumption\":500.0,\"valid_start\":\"2025-08-30T00:00:00\",\"valid_end\":\"2025-09-17T00:00:00\",\"status\":0,\"applicable_dishes\":\"\"}}', 1, 2, '2025-08-30 16:44:39', 2, '2025-08-30 16:44:39');
INSERT INTO `sys_operationlog` VALUES (1554, 2, 3, '营销管理>优惠券管理', '新增优惠券', '2025-08-30 16:44:44', '{\"coupon\":{\"coupon_id\":0,\"store_id\":0,\"coupon_no\":\"\",\"coupon_name\":\"222\",\"type\":1,\"value\":100.0,\"min_consumption\":500.0,\"valid_start\":\"2025-08-30T00:00:00\",\"valid_end\":\"2025-09-17T00:00:00\",\"status\":0,\"applicable_dishes\":\"\"}}', 1, 2, '2025-08-30 16:44:44', 2, '2025-08-30 16:44:44');
INSERT INTO `sys_operationlog` VALUES (1555, 2, 10, '系统登陆', '人员登陆', '2025-08-30 16:46:28', '账号：admin,员工姓名：管理员', 1, 2, '2025-08-30 16:46:28', 2, '2025-08-30 16:46:28');
INSERT INTO `sys_operationlog` VALUES (1556, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 16:46:34', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:46:34', 2, '2025-08-30 16:46:34');
INSERT INTO `sys_operationlog` VALUES (1557, 2, 4, '营销管理>促销活动', '促销活动列表查询', '2025-08-30 16:46:34', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:46:34', 2, '2025-08-30 16:46:34');
INSERT INTO `sys_operationlog` VALUES (1558, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:46:36', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:46:36', 2, '2025-08-30 16:46:36');
INSERT INTO `sys_operationlog` VALUES (1559, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:46:36', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:46:36', 2, '2025-08-30 16:46:36');
INSERT INTO `sys_operationlog` VALUES (1560, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:46:36', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:46:36', 2, '2025-08-30 16:46:36');
INSERT INTO `sys_operationlog` VALUES (1561, 2, 3, '营销管理>优惠券管理', '新增优惠券', '2025-08-30 16:46:56', '{\"coupon\":{\"coupon_id\":0,\"store_id\":0,\"coupon_no\":\"202508301646560236595\",\"coupon_name\":\"222\",\"type\":0,\"value\":100.0,\"min_consumption\":10000.0,\"valid_start\":\"2025-09-21T00:00:00\",\"valid_end\":\"2025-09-23T00:00:00\",\"status\":0,\"applicable_dishes\":\"\"}}', 1, 2, '2025-08-30 16:46:56', 2, '2025-08-30 16:46:56');
INSERT INTO `sys_operationlog` VALUES (1562, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:46:56', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:46:56', 2, '2025-08-30 16:46:56');
INSERT INTO `sys_operationlog` VALUES (1563, 2, 2, '营销管理>优惠券管理', '删除优惠券', '2025-08-30 16:47:18', '{\"couponId\":4}', 1, 2, '2025-08-30 16:47:18', 2, '2025-08-30 16:47:18');
INSERT INTO `sys_operationlog` VALUES (1564, 2, 4, '营销管理>优惠券管理', '优惠券列表查询', '2025-08-30 16:47:18', '{\"storeId\":null,\"name\":null,\"type\":null,\"status\":null,\"pageIndex\":1,\"pageSize\":10}', 1, 2, '2025-08-30 16:47:18', 2, '2025-08-30 16:47:18');

-- ----------------------------
-- Table structure for sys_order
-- ----------------------------
DROP TABLE IF EXISTS `sys_order`;
CREATE TABLE `sys_order`  (
  `order_id` bigint NOT NULL AUTO_INCREMENT COMMENT '订单ID（主键）',
  `store_id` bigint NOT NULL COMMENT '所属门店ID',
  `table_id` bigint NOT NULL COMMENT '桌台ID',
  `order_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单编号（唯一）',
  `member_id` bigint NULL DEFAULT NULL COMMENT '会员ID（可空）',
  `order_type` tinyint NOT NULL COMMENT '类型（1-堂食；2-外卖；3-自提）',
  `source_type` tinyint NOT NULL COMMENT '下单方式（1-服务员端；2-扫码点餐；3-触屏点餐；4-外卖平台）',
  `status` tinyint NOT NULL COMMENT '状态（1-待支付；2-已下单；3-已完成；4-已取消；5-挂单;6-预定；7-已并如其他订单，8-退款）',
  `total_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '订单总金额',
  `discount_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '优惠金额',
  `service_fee` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '服务费',
  `payable_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '应付金额',
  `table_fee` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '桌台费/包间费',
  `start_time` datetime NOT NULL COMMENT '开单时间',
  `pay_time` datetime NULL DEFAULT NULL COMMENT '支付时间',
  `close_time` datetime NULL DEFAULT NULL COMMENT '结单时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '订单备注（如\"少盐\"）',
  `is_split` tinyint NOT NULL DEFAULT 0 COMMENT '是否分单（1-是；0-否）',
  `operator_id` bigint NOT NULL COMMENT '操作员工ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `table_capacity` int NULL DEFAULT NULL COMMENT '用餐人数',
  `reservation_id` int NULL DEFAULT NULL COMMENT '预订id',
  `paymeth` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '支付方式',
  PRIMARY KEY (`order_id`) USING BTREE,
  UNIQUE INDEX `uk_order_no`(`order_no` ASC) USING BTREE,
  INDEX `idx_order_store`(`store_id` ASC) USING BTREE,
  INDEX `idx_order_table`(`table_id` ASC) USING BTREE,
  INDEX `idx_order_member`(`member_id` ASC) USING BTREE,
  INDEX `idx_order_type`(`order_type` ASC) USING BTREE,
  INDEX `idx_order_source`(`source_type` ASC) USING BTREE,
  INDEX `idx_order_status`(`status` ASC) USING BTREE,
  INDEX `idx_order_start_time`(`start_time` ASC) USING BTREE,
  INDEX `idx_order_pay_time`(`pay_time` ASC) USING BTREE,
  INDEX `idx_store_status_time`(`store_id` ASC, `status` ASC, `start_time` ASC) USING BTREE,
  CONSTRAINT `fk_order_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_order_table` FOREIGN KEY (`table_id`) REFERENCES `sys_restaurant_table` (`table_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单主表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_order
-- ----------------------------
INSERT INTO `sys_order` VALUES (5, 2, 3, '202508191429032501685', NULL, 1, 1, 2, 55.00, 0.00, 0.00, 55.00, 0.00, '2025-08-19 14:29:03', NULL, NULL, NULL, 0, 0, '1900-01-01 00:00:00', '2025-08-20 10:47:19', 2, NULL, NULL);

-- ----------------------------
-- Table structure for sys_order_item
-- ----------------------------
DROP TABLE IF EXISTS `sys_order_item`;
CREATE TABLE `sys_order_item`  (
  `item_id` bigint NOT NULL AUTO_INCREMENT COMMENT '明细ID（主键）',
  `order_id` bigint NOT NULL COMMENT '所属订单ID',
  `dish_id` bigint NOT NULL COMMENT '菜品ID',
  `spec_id` bigint NULL DEFAULT NULL COMMENT '规格ID（可空）',
  `meal_id` bigint NULL DEFAULT NULL COMMENT '所属套餐ID（可空）',
  `quantity` int NOT NULL DEFAULT 1 COMMENT '数量',
  `unit_price` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '单价',
  `total_price` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '总价',
  `cooking_require` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '烹饪要求（如\"微辣\"）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态（1-待制作；2-制作中；3-已出餐；4-已退菜）',
  `is_rush` tinyint NOT NULL DEFAULT 0 COMMENT '是否加急（1-是；0-否）',
  `return_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '退菜原因（状态为4时填写）',
  `return_audit_id` bigint NULL DEFAULT NULL COMMENT '退菜审核员工ID',
  `specification` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户选择规格',
  PRIMARY KEY (`item_id`) USING BTREE,
  INDEX `idx_item_order`(`order_id` ASC) USING BTREE,
  INDEX `idx_item_dish`(`dish_id` ASC) USING BTREE,
  INDEX `idx_item_meal`(`meal_id` ASC) USING BTREE,
  INDEX `idx_item_status`(`status` ASC) USING BTREE,
  INDEX `idx_item_rush`(`is_rush` ASC) USING BTREE,
  CONSTRAINT `fk_item_dish` FOREIGN KEY (`dish_id`) REFERENCES `sys_dish` (`dish_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_item_meal` FOREIGN KEY (`meal_id`) REFERENCES `sys_set_meal` (`meal_id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_item_order` FOREIGN KEY (`order_id`) REFERENCES `sys_order` (`order_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_order_item
-- ----------------------------
INSERT INTO `sys_order_item` VALUES (4, 5, 2, NULL, NULL, 1, 45.00, 45.00, NULL, 1, 1, NULL, NULL, NULL);
INSERT INTO `sys_order_item` VALUES (6, 5, 3, NULL, NULL, 1, 10.00, 10.00, NULL, 1, 0, NULL, NULL, NULL);

-- ----------------------------
-- Table structure for sys_payment
-- ----------------------------
DROP TABLE IF EXISTS `sys_payment`;
CREATE TABLE `sys_payment`  (
  `payment_id` bigint NOT NULL AUTO_INCREMENT COMMENT '支付ID（主键）',
  `order_id` bigint NOT NULL COMMENT '关联订单ID',
  `payment_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '支付流水号（唯一）',
  `member_id` bigint NULL DEFAULT NULL COMMENT '会员ID（可空）',
  `pay_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '支付金额',
  `pay_type` tinyint NOT NULL COMMENT '支付方式（1-微信；2-支付宝；3-现金；4-储值卡；5-优惠券）',
  `third_platform` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '第三方平台（如\"美团\"，自付时为空）',
  `third_order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '第三方订单号（外卖平台用）',
  `status` tinyint NOT NULL COMMENT '状态（1-待支付；2-支付成功；3-支付失败）',
  `pay_time` datetime NULL DEFAULT NULL COMMENT '支付时间',
  `coupon_id` bigint NULL DEFAULT NULL COMMENT '优惠券ID（可空）',
  `store_account_id` bigint NOT NULL COMMENT '收款账户ID（公司账户）',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`payment_id`) USING BTREE,
  UNIQUE INDEX `uk_payment_no`(`payment_no` ASC) USING BTREE,
  INDEX `idx_payment_order`(`order_id` ASC) USING BTREE,
  INDEX `idx_payment_member`(`member_id` ASC) USING BTREE,
  INDEX `idx_payment_type`(`pay_type` ASC) USING BTREE,
  INDEX `idx_payment_platform`(`third_platform` ASC) USING BTREE,
  INDEX `idx_payment_status`(`status` ASC) USING BTREE,
  INDEX `idx_payment_time`(`pay_time` ASC) USING BTREE,
  INDEX `idx_payment_account`(`store_account_id` ASC) USING BTREE,
  CONSTRAINT `fk_payment_order` FOREIGN KEY (`order_id`) REFERENCES `sys_order` (`order_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '支付记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_payment
-- ----------------------------

-- ----------------------------
-- Table structure for sys_permission
-- ----------------------------
DROP TABLE IF EXISTS `sys_permission`;
CREATE TABLE `sys_permission`  (
  `permission_id` bigint NOT NULL AUTO_INCREMENT COMMENT '权限ID（主键）',
  `permission_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限名称（如\"订单管理\"）',
  `permission_router` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '权限路由',
  `permission_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限标识（如\"order:manage\"）',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT '父权限ID（用于层级）',
  `permission_icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '图标',
  PRIMARY KEY (`permission_id`) USING BTREE,
  UNIQUE INDEX `uk_permission_key`(`permission_key` ASC) USING BTREE,
  INDEX `idx_permission_parent`(`parent_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 54 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '权限表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_permission
-- ----------------------------
INSERT INTO `sys_permission` VALUES (1, '数据概览', NULL, 'dashboard', 0, '/src/assets/数据概览.png');
INSERT INTO `sys_permission` VALUES (2, '桌台管理', NULL, 'tableManagement', 0, '/src/assets/桌台.png');
INSERT INTO `sys_permission` VALUES (3, '排队叫号', NULL, 'queueManagement', 0, '/src/assets/排队叫号.png');
INSERT INTO `sys_permission` VALUES (4, '菜品管理', NULL, 'dishManagement', 0, '/src/assets/菜品管理.png');
INSERT INTO `sys_permission` VALUES (5, '订单管理', NULL, 'orderManagement', 0, '/src/assets/订单管理.png');
INSERT INTO `sys_permission` VALUES (6, '厨房管理', NULL, 'kitchenManagement', 0, '/src/assets/厨房管理.png');
INSERT INTO `sys_permission` VALUES (7, '库存管理', NULL, 'inventoryManagement', 0, '/src/assets/库存管理.png');
INSERT INTO `sys_permission` VALUES (8, '会员管理', NULL, 'memberManagement', 0, '/src/assets/会员管理.png');
INSERT INTO `sys_permission` VALUES (9, '促销管理', NULL, 'promotionManagement', 0, '/src/assets/促销管理.png');
INSERT INTO `sys_permission` VALUES (10, '支付管理', NULL, 'paymentManagement', 0, '/src/assets/支付管理.png');
INSERT INTO `sys_permission` VALUES (11, '数据分析', NULL, 'statisticsAnalysis', 0, '/src/assets/数据分析.png');
INSERT INTO `sys_permission` VALUES (12, '系统设置', NULL, 'systemSetting', 0, '/src/assets/系统设置.png');
INSERT INTO `sys_permission` VALUES (13, '核心指标看板', 'DashboardIndex', 'dashboard-index', 1, '/src/assets/首页.png');
INSERT INTO `sys_permission` VALUES (14, '桌台列表', 'TableList', 'table-list', 2, '/src/assets/桌台.png');
INSERT INTO `sys_permission` VALUES (15, '桌台布局可视化', 'TableLayout', 'table-layout', 2, '/src/assets/桌台布局.png');
INSERT INTO `sys_permission` VALUES (16, '转桌/并桌操作', 'TransferTable', 'transfer-table', 2, '/src/assets/桌台.png');
INSERT INTO `sys_permission` VALUES (18, '排队列表', 'QueueList', 'queue-list', 3, '/src/assets/排队列表.png');
INSERT INTO `sys_permission` VALUES (19, '排队规则设置', 'QueueSetting', 'queue-setting', 3, '/src/assets/排队设置.png');
INSERT INTO `sys_permission` VALUES (20, '菜品列表', 'DishList', 'dish-list', 4, '/src/assets/菜品列表.png');
INSERT INTO `sys_permission` VALUES (21, '菜品分类', 'DishCategory', 'dish-category', 4, '/src/assets/菜品分类.png');
INSERT INTO `sys_permission` VALUES (22, '菜品规格配置', 'DishSpec', 'dish-spec', 4, '/src/assets/菜品规格.png');
INSERT INTO `sys_permission` VALUES (23, '套餐管理', 'SetMeal', 'set-meal', 4, '/src/assets/套餐管理.png');
INSERT INTO `sys_permission` VALUES (24, '订单列表', 'OrderList', 'order-list', 5, '/src/assets/订单列表.png');
INSERT INTO `sys_permission` VALUES (25, '新建订单', 'CreateOrder', 'create-order', 5, '/src/assets/新建订单.png');
INSERT INTO `sys_permission` VALUES (26, '订单详情', 'OrderDetail', 'order-detail', 5, '/src/assets/订单详情.png');
INSERT INTO `sys_permission` VALUES (27, '账单分拆', 'SplitBill', 'split-bill', 5, '/src/assets/账单分拆.png');
INSERT INTO `sys_permission` VALUES (28, '厨房看板', 'KitchenBoard', 'kitchen-board', 6, '/src/assets/厨房看板.png');
INSERT INTO `sys_permission` VALUES (29, '出餐记录表', 'OutMealRecord', 'out-meal-record', 6, '/src/assets/出餐记录.png');
INSERT INTO `sys_permission` VALUES (30, '原材料列表', 'MaterialList', 'material-list', 7, '/src/assets/原材料列表.png');
INSERT INTO `sys_permission` VALUES (31, '损耗记录', 'LossRecord', 'loss-record', 7, '/src/assets/损耗记录.png');
INSERT INTO `sys_permission` VALUES (32, '采购单管理', 'PurchaseOrder', 'purchase-order', 7, '/src/assets/采购单.png');
INSERT INTO `sys_permission` VALUES (33, '库存预警', 'StockWarning', 'stock-warning', 7, '/src/assets/库存预警.png');
INSERT INTO `sys_permission` VALUES (34, '会员列表', 'MemberList', 'member-list', 8, '/src/assets/会员列表.png');
INSERT INTO `sys_permission` VALUES (35, '储值记录', 'RechargeRecord', 'recharge-record', 8, '/src/assets/储值记录.png');
INSERT INTO `sys_permission` VALUES (38, '促销活动列表', 'PromotionList', 'promotion-list', 9, '/src/assets/促销列表.png');
INSERT INTO `sys_permission` VALUES (40, '优惠券管理', 'CouponManagement', 'coupon-management', 9, '/src/assets/优惠卷管理.png');
INSERT INTO `sys_permission` VALUES (41, '支付记录', 'PaymentRecord', 'payment-record', 10, '/src/assets/支付记录.png');
INSERT INTO `sys_permission` VALUES (42, '发票管理', 'InvoiceManagement', 'invoice-management', 10, '/src/assets/发票管理.png');
INSERT INTO `sys_permission` VALUES (43, '收款账户设置', 'AccountSetting', 'account-setting', 10, '/src/assets/账户设置.png');
INSERT INTO `sys_permission` VALUES (44, '销售分析', 'SalesAnalysis', 'sales-analysis', 11, '/src/assets/销售分析.png');
INSERT INTO `sys_permission` VALUES (45, '成本分析', 'CostAnalysis', 'cost-analysis', 11, '/src/assets/成本分析.png');
INSERT INTO `sys_permission` VALUES (46, '客流分析', 'CustomerAnalysis', 'customer-analysis', 11, '/src/assets/客流分析.png');
INSERT INTO `sys_permission` VALUES (47, '门店对比', 'StoreComparison', 'store-comparison', 11, '/src/assets/门店对比.png');
INSERT INTO `sys_permission` VALUES (48, '员工管理', 'StaffManagement', 'staff-management', 12, '/src/assets/员工管理.png');
INSERT INTO `sys_permission` VALUES (49, '角色权限', 'RolePermission', 'role-permission', 12, '/src/assets/角色权限.png');
INSERT INTO `sys_permission` VALUES (50, '门店设置', 'StoreSetting', 'store-setting', 12, '/src/assets/门店设置.png');
INSERT INTO `sys_permission` VALUES (51, '数据备份', 'DataBackup', 'data-backup', 12, '/src/assets/数据备份.png');
INSERT INTO `sys_permission` VALUES (52, '厨房管理', 'KitchenManagement', 'Kitchen-list', 6, '/src/assets/菜品规格.png');
INSERT INTO `sys_permission` VALUES (53, '核心指标报表', 'CoreKPIReport', 'CoreKPIReport', 1, '/src/assets/数据概览.png');

-- ----------------------------
-- Table structure for sys_promotion
-- ----------------------------
DROP TABLE IF EXISTS `sys_promotion`;
CREATE TABLE `sys_promotion`  (
  `promotion_id` bigint NOT NULL AUTO_INCREMENT COMMENT '活动ID（主键）',
  `store_id` bigint NULL DEFAULT NULL COMMENT '门店ID（0-全门店）',
  `promotion_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '活动名称',
  `type` tinyint NOT NULL COMMENT '类型（1-时段优惠；2-节日套餐；3-满减；4-老带新）',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NOT NULL COMMENT '结束时间',
  `rule` json NOT NULL COMMENT '活动规则（如{\"满减\":[{\"满200\":\"减30\"},...]}）',
  `applicable_scope` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '适用范围（菜品/套餐ID，逗号分隔）',
  `status` tinyint NOT NULL COMMENT '状态（1-未开始；2-进行中；3-已结束）',
  PRIMARY KEY (`promotion_id`) USING BTREE,
  INDEX `idx_promotion_store`(`store_id` ASC) USING BTREE,
  INDEX `idx_promotion_type`(`type` ASC) USING BTREE,
  INDEX `idx_promotion_time`(`start_time` ASC, `end_time` ASC) USING BTREE,
  INDEX `idx_promotion_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '促销活动表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_promotion
-- ----------------------------
INSERT INTO `sys_promotion` VALUES (1, 2, '满200减20', 0, '2025-08-12 00:00:00', '2025-08-28 00:00:00', '\"\"', '111', 1);
INSERT INTO `sys_promotion` VALUES (3, 2, '11', 0, '2025-08-04 00:00:00', '2025-08-06 00:00:00', '\"\"', '111', 0);
INSERT INTO `sys_promotion` VALUES (7, 0, '111', 0, '2025-08-03 00:00:00', '2025-08-04 00:00:00', '\"\"', '111', 2);

-- ----------------------------
-- Table structure for sys_purchase_order
-- ----------------------------
DROP TABLE IF EXISTS `sys_purchase_order`;
CREATE TABLE `sys_purchase_order`  (
  `po_id` bigint NOT NULL AUTO_INCREMENT COMMENT '采购单ID（主键）',
  `store_id` bigint NOT NULL COMMENT '门店ID',
  `po_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '采购单号',
  `supplier_id` bigint NOT NULL COMMENT '供应商ID',
  `order_time` datetime NOT NULL COMMENT '下单时间',
  `expect_arrival_time` datetime NOT NULL COMMENT '预计到货时间',
  `actual_arrival_time` datetime NULL DEFAULT NULL COMMENT '实际到货时间',
  `total_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '采购总金额',
  `status` tinyint NOT NULL COMMENT '状态（1-待确认；2-已确认；3-已到货；4-已取消）',
  `operator_id` bigint NOT NULL COMMENT '下单员工ID',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`po_id`) USING BTREE,
  UNIQUE INDEX `uk_po_no`(`po_no` ASC) USING BTREE,
  INDEX `idx_po_store`(`store_id` ASC) USING BTREE,
  INDEX `idx_po_supplier`(`supplier_id` ASC) USING BTREE,
  INDEX `idx_po_order_time`(`order_time` ASC) USING BTREE,
  INDEX `idx_po_arrival`(`expect_arrival_time` ASC) USING BTREE,
  INDEX `idx_po_status`(`status` ASC) USING BTREE,
  CONSTRAINT `fk_po_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_po_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `sys_supplier` (`supplier_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '采购单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_purchase_order
-- ----------------------------

-- ----------------------------
-- Table structure for sys_queue
-- ----------------------------
DROP TABLE IF EXISTS `sys_queue`;
CREATE TABLE `sys_queue`  (
  `queue_id` bigint NOT NULL AUTO_INCREMENT COMMENT '排队ID（主键）',
  `store_id` bigint NOT NULL COMMENT '所属门店ID',
  `customer_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '顾客姓名',
  `customer_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '顾客电话',
  `party_size` int NOT NULL DEFAULT 1 COMMENT '用餐人数',
  `queue_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '排队号（如\"A001\"）',
  `queue_time` datetime NOT NULL COMMENT '取号时间',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态（1-等待中；2-已叫号；3-过号；4-已入座）',
  `overtime_remind` tinyint NOT NULL DEFAULT 0 COMMENT '过号提醒状态（0-未提醒；1-已提醒）',
  `table_id` bigint NULL DEFAULT NULL COMMENT '入座桌台ID（关联后更新）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`queue_id`) USING BTREE,
  UNIQUE INDEX `uk_queue_no`(`queue_no` ASC) USING BTREE,
  INDEX `idx_queue_store`(`store_id` ASC) USING BTREE,
  INDEX `idx_queue_status`(`status` ASC) USING BTREE,
  INDEX `idx_queue_phone`(`customer_phone` ASC) USING BTREE,
  INDEX `idx_queue_time`(`queue_time` ASC) USING BTREE,
  INDEX `fk_queue_table`(`table_id` ASC) USING BTREE,
  CONSTRAINT `fk_queue_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_queue_table` FOREIGN KEY (`table_id`) REFERENCES `sys_restaurant_table` (`table_id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '排队叫号表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_queue
-- ----------------------------

-- ----------------------------
-- Table structure for sys_raw_material
-- ----------------------------
DROP TABLE IF EXISTS `sys_raw_material`;
CREATE TABLE `sys_raw_material`  (
  `material_id` bigint NOT NULL AUTO_INCREMENT COMMENT '原材料ID（主键）',
  `store_id` bigint NOT NULL COMMENT '所属门店ID（0-通用）',
  `material_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '原材料名称（如\"鸡肉\"）',
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分类（生鲜/调料/粮油）',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '单位（kg/个/升）',
  `purchase_price` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '采购单价',
  `warning_threshold` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '低库存预警阈值',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态（1-启用；0-禁用）',
  PRIMARY KEY (`material_id`) USING BTREE,
  INDEX `idx_material_store`(`store_id` ASC) USING BTREE,
  INDEX `idx_material_name`(`material_name` ASC) USING BTREE,
  INDEX `idx_material_category`(`category` ASC) USING BTREE,
  CONSTRAINT `fk_material_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '原材料表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_raw_material
-- ----------------------------

-- ----------------------------
-- Table structure for sys_reservation
-- ----------------------------
DROP TABLE IF EXISTS `sys_reservation`;
CREATE TABLE `sys_reservation`  (
  `reservation_id` bigint NOT NULL AUTO_INCREMENT COMMENT '预订ID',
  `store_id` bigint NOT NULL COMMENT '门店ID',
  `table_id` bigint NOT NULL COMMENT '预订桌台ID',
  `reservation_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '预订编号（唯一）',
  `reservation_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '预订人姓名',
  `reservation_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '预订人电话',
  `reservation_time` datetime NOT NULL COMMENT '预订时间',
  `reservation_capacity` int NOT NULL COMMENT '预订人数',
  `status` tinyint NOT NULL COMMENT '状态（1-已确认；2-已取消；3-已到店；4-已过期）',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '预订备注',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`reservation_id`) USING BTREE,
  UNIQUE INDEX `uk_reservation_no`(`reservation_no` ASC) USING BTREE,
  INDEX `idx_reservation_store`(`store_id` ASC) USING BTREE,
  INDEX `idx_reservation_table`(`table_id` ASC) USING BTREE,
  INDEX `idx_reservation_time`(`reservation_time` ASC) USING BTREE,
  INDEX `idx_reservation_status`(`status` ASC) USING BTREE,
  CONSTRAINT `fk_reservation_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_reservation_table` FOREIGN KEY (`table_id`) REFERENCES `sys_restaurant_table` (`table_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '预订信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_reservation
-- ----------------------------

-- ----------------------------
-- Table structure for sys_restaurant_table
-- ----------------------------
DROP TABLE IF EXISTS `sys_restaurant_table`;
CREATE TABLE `sys_restaurant_table`  (
  `table_id` bigint NOT NULL AUTO_INCREMENT COMMENT '桌台ID（主键）',
  `store_id` bigint NOT NULL COMMENT '所属门店ID',
  `table_no` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '桌台编号（如\"1号桌\"）',
  `capacity` int NOT NULL DEFAULT 0 COMMENT '可容纳人数',
  `table_type` int NULL DEFAULT NULL COMMENT '类型（散台/包间/吧台）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态（1-空闲；2-占用；3-预订；4-清洁中）',
  `min_consumption` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '最低消费（包间专用）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `order_id` int NULL DEFAULT NULL COMMENT '订单id',
  `desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '桌台描述',
  PRIMARY KEY (`table_id`) USING BTREE,
  INDEX `idx_table_store`(`store_id` ASC) USING BTREE,
  INDEX `idx_table_status`(`status` ASC) USING BTREE,
  INDEX `idx_table_no`(`table_no` ASC) USING BTREE,
  CONSTRAINT `fk_table_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '桌台信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_restaurant_table
-- ----------------------------
INSERT INTO `sys_restaurant_table` VALUES (1, 2, 'A01', 4, NULL, 1, 0.00, '1900-01-01 00:00:00', '1900-01-01 00:00:00', NULL, '四人桌（一楼大厅）');
INSERT INTO `sys_restaurant_table` VALUES (2, 2, 'A02', 2, NULL, 1, 0.00, '1900-01-01 00:00:00', '1900-01-01 00:00:00', NULL, NULL);
INSERT INTO `sys_restaurant_table` VALUES (3, 2, 'B01', 6, NULL, 2, 0.00, '1900-01-01 00:00:00', '1900-01-01 00:00:00', NULL, '四人桌（一楼大厅）');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID（主键）',
  `role_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称（店长/收银员/厨师）',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色描述',
  PRIMARY KEY (`role_id`) USING BTREE,
  UNIQUE INDEX `uk_role_name`(`role_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '管理员', '管理所有功能');
INSERT INTO `sys_role` VALUES (3, '员工', '负责订单处理');

-- ----------------------------
-- Table structure for sys_role_permission
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_permission`;
CREATE TABLE `sys_role_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '关联ID（主键）',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `permission_id` bigint NOT NULL COMMENT '权限ID',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_role_permission_role`(`role_id` ASC) USING BTREE,
  INDEX `idx_role_permission_permission`(`permission_id` ASC) USING BTREE,
  CONSTRAINT `fk_role_permission_permission` FOREIGN KEY (`permission_id`) REFERENCES `sys_permission` (`permission_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_role_permission_role` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`role_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 900 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色权限关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role_permission
-- ----------------------------
INSERT INTO `sys_role_permission` VALUES (803, 1, 1);
INSERT INTO `sys_role_permission` VALUES (804, 1, 13);
INSERT INTO `sys_role_permission` VALUES (805, 1, 53);
INSERT INTO `sys_role_permission` VALUES (806, 1, 2);
INSERT INTO `sys_role_permission` VALUES (807, 1, 14);
INSERT INTO `sys_role_permission` VALUES (808, 1, 15);
INSERT INTO `sys_role_permission` VALUES (809, 1, 16);
INSERT INTO `sys_role_permission` VALUES (810, 1, 3);
INSERT INTO `sys_role_permission` VALUES (811, 1, 18);
INSERT INTO `sys_role_permission` VALUES (812, 1, 19);
INSERT INTO `sys_role_permission` VALUES (813, 1, 4);
INSERT INTO `sys_role_permission` VALUES (814, 1, 20);
INSERT INTO `sys_role_permission` VALUES (815, 1, 21);
INSERT INTO `sys_role_permission` VALUES (816, 1, 22);
INSERT INTO `sys_role_permission` VALUES (817, 1, 23);
INSERT INTO `sys_role_permission` VALUES (818, 1, 5);
INSERT INTO `sys_role_permission` VALUES (819, 1, 24);
INSERT INTO `sys_role_permission` VALUES (820, 1, 25);
INSERT INTO `sys_role_permission` VALUES (821, 1, 26);
INSERT INTO `sys_role_permission` VALUES (822, 1, 27);
INSERT INTO `sys_role_permission` VALUES (823, 1, 6);
INSERT INTO `sys_role_permission` VALUES (824, 1, 28);
INSERT INTO `sys_role_permission` VALUES (825, 1, 29);
INSERT INTO `sys_role_permission` VALUES (826, 1, 52);
INSERT INTO `sys_role_permission` VALUES (827, 1, 7);
INSERT INTO `sys_role_permission` VALUES (828, 1, 30);
INSERT INTO `sys_role_permission` VALUES (829, 1, 31);
INSERT INTO `sys_role_permission` VALUES (830, 1, 32);
INSERT INTO `sys_role_permission` VALUES (831, 1, 33);
INSERT INTO `sys_role_permission` VALUES (832, 1, 8);
INSERT INTO `sys_role_permission` VALUES (833, 1, 34);
INSERT INTO `sys_role_permission` VALUES (834, 1, 35);
INSERT INTO `sys_role_permission` VALUES (835, 1, 9);
INSERT INTO `sys_role_permission` VALUES (836, 1, 38);
INSERT INTO `sys_role_permission` VALUES (837, 1, 40);
INSERT INTO `sys_role_permission` VALUES (838, 1, 10);
INSERT INTO `sys_role_permission` VALUES (839, 1, 41);
INSERT INTO `sys_role_permission` VALUES (840, 1, 42);
INSERT INTO `sys_role_permission` VALUES (841, 1, 43);
INSERT INTO `sys_role_permission` VALUES (842, 1, 11);
INSERT INTO `sys_role_permission` VALUES (843, 1, 44);
INSERT INTO `sys_role_permission` VALUES (844, 1, 45);
INSERT INTO `sys_role_permission` VALUES (845, 1, 46);
INSERT INTO `sys_role_permission` VALUES (846, 1, 47);
INSERT INTO `sys_role_permission` VALUES (847, 1, 12);
INSERT INTO `sys_role_permission` VALUES (848, 1, 48);
INSERT INTO `sys_role_permission` VALUES (849, 1, 49);
INSERT INTO `sys_role_permission` VALUES (850, 1, 50);
INSERT INTO `sys_role_permission` VALUES (851, 1, 51);
INSERT INTO `sys_role_permission` VALUES (852, 3, 1);
INSERT INTO `sys_role_permission` VALUES (853, 3, 13);
INSERT INTO `sys_role_permission` VALUES (854, 3, 53);
INSERT INTO `sys_role_permission` VALUES (855, 3, 2);
INSERT INTO `sys_role_permission` VALUES (856, 3, 14);
INSERT INTO `sys_role_permission` VALUES (857, 3, 15);
INSERT INTO `sys_role_permission` VALUES (858, 3, 16);
INSERT INTO `sys_role_permission` VALUES (859, 3, 3);
INSERT INTO `sys_role_permission` VALUES (860, 3, 18);
INSERT INTO `sys_role_permission` VALUES (861, 3, 19);
INSERT INTO `sys_role_permission` VALUES (862, 3, 4);
INSERT INTO `sys_role_permission` VALUES (863, 3, 20);
INSERT INTO `sys_role_permission` VALUES (864, 3, 21);
INSERT INTO `sys_role_permission` VALUES (865, 3, 22);
INSERT INTO `sys_role_permission` VALUES (866, 3, 23);
INSERT INTO `sys_role_permission` VALUES (867, 3, 5);
INSERT INTO `sys_role_permission` VALUES (868, 3, 24);
INSERT INTO `sys_role_permission` VALUES (869, 3, 25);
INSERT INTO `sys_role_permission` VALUES (870, 3, 26);
INSERT INTO `sys_role_permission` VALUES (871, 3, 27);
INSERT INTO `sys_role_permission` VALUES (872, 3, 6);
INSERT INTO `sys_role_permission` VALUES (873, 3, 28);
INSERT INTO `sys_role_permission` VALUES (874, 3, 29);
INSERT INTO `sys_role_permission` VALUES (875, 3, 52);
INSERT INTO `sys_role_permission` VALUES (876, 3, 7);
INSERT INTO `sys_role_permission` VALUES (877, 3, 30);
INSERT INTO `sys_role_permission` VALUES (878, 3, 31);
INSERT INTO `sys_role_permission` VALUES (879, 3, 32);
INSERT INTO `sys_role_permission` VALUES (880, 3, 33);
INSERT INTO `sys_role_permission` VALUES (881, 3, 8);
INSERT INTO `sys_role_permission` VALUES (882, 3, 34);
INSERT INTO `sys_role_permission` VALUES (883, 3, 35);
INSERT INTO `sys_role_permission` VALUES (884, 3, 9);
INSERT INTO `sys_role_permission` VALUES (885, 3, 38);
INSERT INTO `sys_role_permission` VALUES (886, 3, 40);
INSERT INTO `sys_role_permission` VALUES (887, 3, 10);
INSERT INTO `sys_role_permission` VALUES (888, 3, 41);
INSERT INTO `sys_role_permission` VALUES (889, 3, 42);
INSERT INTO `sys_role_permission` VALUES (890, 3, 43);
INSERT INTO `sys_role_permission` VALUES (891, 3, 11);
INSERT INTO `sys_role_permission` VALUES (892, 3, 44);
INSERT INTO `sys_role_permission` VALUES (893, 3, 45);
INSERT INTO `sys_role_permission` VALUES (894, 3, 46);
INSERT INTO `sys_role_permission` VALUES (895, 3, 47);
INSERT INTO `sys_role_permission` VALUES (896, 3, 48);
INSERT INTO `sys_role_permission` VALUES (897, 3, 49);
INSERT INTO `sys_role_permission` VALUES (898, 3, 50);
INSERT INTO `sys_role_permission` VALUES (899, 3, 51);

-- ----------------------------
-- Table structure for sys_set_meal
-- ----------------------------
DROP TABLE IF EXISTS `sys_set_meal`;
CREATE TABLE `sys_set_meal`  (
  `meal_id` bigint NOT NULL AUTO_INCREMENT COMMENT '套餐ID（主键）',
  `store_id` bigint NOT NULL COMMENT '所属门店ID',
  `meal_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '套餐名称（如\"双人套餐\"）',
  `price` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '套餐售价',
  `original_price` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '原价（单品总价）',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '套餐描述',
  `is_fixed` tinyint NOT NULL DEFAULT 1 COMMENT '是否固定套餐（1-固定；0-自定义组合）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态（1-在售；0-下架）',
  `start_time` datetime NOT NULL COMMENT '生效时间（用于节日套餐）',
  `end_time` datetime NOT NULL COMMENT '失效时间',
  PRIMARY KEY (`meal_id`) USING BTREE,
  INDEX `idx_meal_store`(`store_id` ASC) USING BTREE,
  INDEX `idx_meal_name`(`meal_name` ASC) USING BTREE,
  INDEX `idx_meal_status`(`status` ASC) USING BTREE,
  INDEX `idx_meal_time`(`start_time` ASC, `end_time` ASC) USING BTREE,
  INDEX `idx_meal_fixed`(`is_fixed` ASC) USING BTREE,
  CONSTRAINT `fk_meal_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '套餐信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_set_meal
-- ----------------------------
INSERT INTO `sys_set_meal` VALUES (1, 2, '1111', 111.00, 11.00, '', 1, 1, '2025-07-31 16:00:00', '2025-08-30 16:00:00');

-- ----------------------------
-- Table structure for sys_set_meal_item
-- ----------------------------
DROP TABLE IF EXISTS `sys_set_meal_item`;
CREATE TABLE `sys_set_meal_item`  (
  `item_id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID（主键）',
  `meal_id` bigint NOT NULL COMMENT '所属套餐ID',
  `dish_id` bigint NOT NULL COMMENT '包含菜品ID',
  `spec_id` bigint NULL DEFAULT NULL COMMENT '菜品规格ID（可空）',
  `quantity` int NOT NULL DEFAULT 1 COMMENT '数量',
  `is_replaceable` tinyint NULL DEFAULT 0 COMMENT '是否可替换（1-是；0-否）',
  `replaceable_dishes` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '可替换菜品ID（逗号分隔）',
  `meal_group` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '套餐组合名称',
  PRIMARY KEY (`item_id`) USING BTREE,
  INDEX `idx_meal_item_meal`(`meal_id` ASC) USING BTREE,
  INDEX `fk_meal_item_dish`(`dish_id` ASC) USING BTREE,
  INDEX `fk_meal_item_spec`(`spec_id` ASC) USING BTREE,
  CONSTRAINT `fk_meal_item_dish` FOREIGN KEY (`dish_id`) REFERENCES `sys_dish` (`dish_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_meal_item_meal` FOREIGN KEY (`meal_id`) REFERENCES `sys_set_meal` (`meal_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_meal_item_spec` FOREIGN KEY (`spec_id`) REFERENCES `sys_dish_spec` (`spec_id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '套餐包含菜品表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_set_meal_item
-- ----------------------------
INSERT INTO `sys_set_meal_item` VALUES (1, 1, 2, 1, 1, 0, NULL, '');
INSERT INTO `sys_set_meal_item` VALUES (2, 1, 3, NULL, 1, 0, NULL, '');

-- ----------------------------
-- Table structure for sys_staff
-- ----------------------------
DROP TABLE IF EXISTS `sys_staff`;
CREATE TABLE `sys_staff`  (
  `staff_id` bigint NOT NULL AUTO_INCREMENT COMMENT '员工ID（主键）',
  `store_id` bigint NOT NULL COMMENT '所属门店ID（0-总部）',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录账号',
  `password` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '加密密码',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `position` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '职位（服务员/厨师/店长）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态（1-在职；0-离职）',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `Salt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `IsDelete` tinyint NOT NULL DEFAULT 1,
  PRIMARY KEY (`staff_id`) USING BTREE,
  UNIQUE INDEX `uk_staff_username`(`username` ASC) USING BTREE,
  INDEX `idx_staff_store`(`store_id` ASC) USING BTREE,
  INDEX `idx_staff_position`(`position` ASC) USING BTREE,
  INDEX `idx_staff_status`(`status` ASC) USING BTREE,
  CONSTRAINT `fk_staff_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '员工表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_staff
-- ----------------------------
INSERT INTO `sys_staff` VALUES (2, 1, 'admin', '8pgVn7BnedAGOKthCSdIUifitpQsAWfKSDDFoz5R8oM=', '管理员', '18433646699', '店长', 1, '2025-08-30 11:45:41', 'SOMMsmOVbHI38x1hUkWfiQ==', 1);
INSERT INTO `sys_staff` VALUES (6, 2, 'lq', 'jv77mITf0Nl7Vpz1iyPSAszCDwLxq4lU11UnEOn4q6U=', 'lq', '11111111111', '服务员', 1, '2025-08-25 17:06:20', 'PzBgx3X4Rqt+GDPMcm2ekw==', 1);

-- ----------------------------
-- Table structure for sys_staff_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_staff_role`;
CREATE TABLE `sys_staff_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '关联ID（主键）',
  `staff_id` bigint NOT NULL COMMENT '员工ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_staff_role_staff`(`staff_id` ASC) USING BTREE,
  INDEX `idx_staff_role_role`(`role_id` ASC) USING BTREE,
  CONSTRAINT `fk_staff_role_role` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`role_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_staff_role_staff` FOREIGN KEY (`staff_id`) REFERENCES `sys_staff` (`staff_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '员工角色关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_staff_role
-- ----------------------------
INSERT INTO `sys_staff_role` VALUES (1, 2, 1);
INSERT INTO `sys_staff_role` VALUES (7, 6, 3);

-- ----------------------------
-- Table structure for sys_store
-- ----------------------------
DROP TABLE IF EXISTS `sys_store`;
CREATE TABLE `sys_store`  (
  `store_id` bigint NOT NULL AUTO_INCREMENT COMMENT '门店ID（主键）',
  `store_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '门店名称',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '门店地址',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系电话',
  `business_hours` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '营业时间（如\"10:00-22:00\"）',
  `total_tables` int NOT NULL DEFAULT 0 COMMENT '总桌台数',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态（1-营业中；0-停业）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`store_id`) USING BTREE,
  INDEX `idx_store_status`(`status` ASC) USING BTREE,
  INDEX `idx_store_name`(`store_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '门店信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_store
-- ----------------------------
INSERT INTO `sys_store` VALUES (1, '管理员', '管理员', '111', '111', 0, 1, '2025-08-11 11:40:29', '2025-08-11 11:49:52');
INSERT INTO `sys_store` VALUES (2, '旗舰店', '2244', '111', '111', 20, 1, '2025-08-11 15:21:45', '2025-08-11 21:42:16');

-- ----------------------------
-- Table structure for sys_supplier
-- ----------------------------
DROP TABLE IF EXISTS `sys_supplier`;
CREATE TABLE `sys_supplier`  (
  `supplier_id` bigint NOT NULL AUTO_INCREMENT COMMENT '供应商ID（主键）',
  `supplier_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '供应商名称',
  `contact_person` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系人',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系电话',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '地址',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态（1-合作中；0-已停用）',
  PRIMARY KEY (`supplier_id`) USING BTREE,
  INDEX `idx_supplier_name`(`supplier_name` ASC) USING BTREE,
  INDEX `idx_supplier_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '供应商表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_supplier
-- ----------------------------

-- ----------------------------
-- Table structure for sys_table_transfer
-- ----------------------------
DROP TABLE IF EXISTS `sys_table_transfer`;
CREATE TABLE `sys_table_transfer`  (
  `transfer_id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID（主键）',
  `order_id` bigint NOT NULL COMMENT '关联订单ID',
  `old_table_id` bigint NOT NULL COMMENT '原桌台ID',
  `new_table_id` bigint NOT NULL COMMENT '新桌台ID',
  `transfer_time` datetime NOT NULL COMMENT '转桌/并桌时间',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作员工ID',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '转桌原因',
  `type` int NOT NULL COMMENT '1:转桌；2并桌',
  PRIMARY KEY (`transfer_id`) USING BTREE,
  INDEX `idx_transfer_order`(`order_id` ASC) USING BTREE,
  INDEX `idx_transfer_time`(`transfer_time` ASC) USING BTREE,
  INDEX `fk_transfer_old_table`(`old_table_id` ASC) USING BTREE,
  INDEX `fk_transfer_new_table`(`new_table_id` ASC) USING BTREE,
  CONSTRAINT `fk_transfer_new_table` FOREIGN KEY (`new_table_id`) REFERENCES `sys_restaurant_table` (`table_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_transfer_old_table` FOREIGN KEY (`old_table_id`) REFERENCES `sys_restaurant_table` (`table_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '桌台转桌并桌记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_table_transfer
-- ----------------------------
INSERT INTO `sys_table_transfer` VALUES (2, 5, 1, 3, '2025-08-20 10:47:19', 0, NULL, 1);

-- ----------------------------
-- Table structure for sys_timertask
-- ----------------------------
DROP TABLE IF EXISTS `sys_timertask`;
CREATE TABLE `sys_timertask`  (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `TimerName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '定时器名称',
  `TimerClass` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '定时器服务类',
  `CreateTime` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `BeginTime` datetime NULL DEFAULT NULL COMMENT '运行开始时间',
  `EndTime` datetime NULL DEFAULT NULL COMMENT '运行结束时间',
  `AddUser` bigint NULL DEFAULT NULL COMMENT '创建人',
  `OrgId` bigint NULL DEFAULT NULL COMMENT '组织',
  `IsStart` int NULL DEFAULT NULL COMMENT '运行状态：0，未启动，1，启动运行，2，暂停',
  `isDelete` int NULL DEFAULT NULL COMMENT '是否删除：0，删除，1，运行',
  `Corn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设置运行时段',
  `StartNumber` bigint NULL DEFAULT NULL COMMENT '运行次数',
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '定时器管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_timertask
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
