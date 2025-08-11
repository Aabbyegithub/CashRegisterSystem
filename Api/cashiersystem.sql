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

 Date: 11/08/2025 17:30:59
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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '账单表' ROW_FORMAT = DYNAMIC;

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
  INDEX `idx_coupon_valid`(`valid_start` ASC, `valid_end` ASC) USING BTREE,
  CONSTRAINT `fk_coupon_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '优惠券表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_coupon
-- ----------------------------

-- ----------------------------
-- Table structure for sys_dish
-- ----------------------------
DROP TABLE IF EXISTS `sys_dish`;
CREATE TABLE `sys_dish`  (
  `dish_id` bigint NOT NULL AUTO_INCREMENT COMMENT '菜品ID（主键）',
  `category_id` bigint NOT NULL COMMENT '所属分类ID',
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
  PRIMARY KEY (`dish_id`) USING BTREE,
  INDEX `idx_dish_category`(`category_id` ASC) USING BTREE,
  INDEX `idx_dish_name`(`dish_name` ASC) USING BTREE,
  INDEX `idx_dish_status`(`status` ASC) USING BTREE,
  INDEX `idx_dish_recommend`(`is_recommend` ASC) USING BTREE,
  INDEX `idx_dish_temporary`(`is_temporary` ASC) USING BTREE,
  CONSTRAINT `fk_dish_category` FOREIGN KEY (`category_id`) REFERENCES `sys_dish_category` (`category_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dish
-- ----------------------------

-- ----------------------------
-- Table structure for sys_dish_category
-- ----------------------------
DROP TABLE IF EXISTS `sys_dish_category`;
CREATE TABLE `sys_dish_category`  (
  `category_id` bigint NOT NULL AUTO_INCREMENT COMMENT '分类ID（主键）',
  `store_id` bigint NOT NULL COMMENT '所属门店ID（支持单店特色分类）',
  `category_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分类名称（热菜/凉菜/主食）',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序序号（小在前）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态（1-启用；0-禁用）',
  PRIMARY KEY (`category_id`) USING BTREE,
  INDEX `idx_category_store`(`store_id` ASC) USING BTREE,
  CONSTRAINT `fk_category_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品分类表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dish_category
-- ----------------------------

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品配方表（原材料消耗规则）' ROW_FORMAT = DYNAMIC;

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
  `price_diff` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '价格差（相对于基础价）',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序序号',
  PRIMARY KEY (`spec_id`) USING BTREE,
  INDEX `idx_spec_dish`(`dish_id` ASC) USING BTREE,
  CONSTRAINT `fk_spec_dish` FOREIGN KEY (`dish_id`) REFERENCES `sys_dish` (`dish_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品规格表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_dish_spec
-- ----------------------------

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '库存表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '库存损耗表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_inventory_loss
-- ----------------------------

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
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态（1-待制作；2-制作中；3-已完成；4-已取餐）',
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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '厨房订单表（KDS系统同步）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_kitchen_order
-- ----------------------------

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
  PRIMARY KEY (`member_id`) USING BTREE,
  UNIQUE INDEX `uk_member_no`(`member_no` ASC) USING BTREE,
  UNIQUE INDEX `uk_member_phone`(`phone` ASC) USING BTREE,
  INDEX `idx_member_status`(`status` ASC) USING BTREE,
  INDEX `idx_member_register`(`register_time` ASC) USING BTREE,
  INDEX `idx_member_birthday`(`birthday` ASC) USING BTREE,
  INDEX `idx_member_referrer`(`referrer_id` ASC) USING BTREE,
  CONSTRAINT `fk_member_referrer` FOREIGN KEY (`referrer_id`) REFERENCES `sys_member` (`member_id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会员表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_member
-- ----------------------------

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会员储值记录表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 205 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统操作日志' ROW_FORMAT = DYNAMIC;

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
  `status` tinyint NOT NULL COMMENT '状态（1-待支付；2-已下单；3-已完成；4-已取消；5-挂单）',
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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单主表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_order
-- ----------------------------

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
  PRIMARY KEY (`item_id`) USING BTREE,
  INDEX `idx_item_order`(`order_id` ASC) USING BTREE,
  INDEX `idx_item_dish`(`dish_id` ASC) USING BTREE,
  INDEX `idx_item_meal`(`meal_id` ASC) USING BTREE,
  INDEX `idx_item_status`(`status` ASC) USING BTREE,
  INDEX `idx_item_rush`(`is_rush` ASC) USING BTREE,
  CONSTRAINT `fk_item_dish` FOREIGN KEY (`dish_id`) REFERENCES `sys_dish` (`dish_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_item_meal` FOREIGN KEY (`meal_id`) REFERENCES `sys_set_meal` (`meal_id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_item_order` FOREIGN KEY (`order_id`) REFERENCES `sys_order` (`order_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_order_item
-- ----------------------------

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '支付记录表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB AUTO_INCREMENT = 52 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '权限表' ROW_FORMAT = DYNAMIC;

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
INSERT INTO `sys_permission` VALUES (36, '会员权益配置', 'MemberRights', 'member-rights', 8, '/src/assets/会员权益.png');
INSERT INTO `sys_permission` VALUES (37, '积分商城', 'PointsMall', 'points-mall', 8, '/src/assets/积分商城.png');
INSERT INTO `sys_permission` VALUES (38, '促销活动列表', 'PromotionList', 'promotion-list', 9, '/src/assets/促销列表.png');
INSERT INTO `sys_permission` VALUES (39, '创建促销活动', 'CreatePromotion', 'create-promotion', 9, '/src/assets/创建促销.png');
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

-- ----------------------------
-- Table structure for sys_promotion
-- ----------------------------
DROP TABLE IF EXISTS `sys_promotion`;
CREATE TABLE `sys_promotion`  (
  `promotion_id` bigint NOT NULL AUTO_INCREMENT COMMENT '活动ID（主键）',
  `store_id` bigint NOT NULL COMMENT '门店ID（0-全门店）',
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
  INDEX `idx_promotion_status`(`status` ASC) USING BTREE,
  CONSTRAINT `fk_promotion_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '促销活动表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_promotion
-- ----------------------------

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '采购单表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '排队叫号表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '原材料表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_raw_material
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
  `table_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类型（散台/包间/吧台）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态（1-空闲；2-占用；3-预订；4-清洁中）',
  `min_consumption` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '最低消费（包间专用）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`) USING BTREE,
  INDEX `idx_table_store`(`store_id` ASC) USING BTREE,
  INDEX `idx_table_status`(`status` ASC) USING BTREE,
  INDEX `idx_table_no`(`table_no` ASC) USING BTREE,
  CONSTRAINT `fk_table_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '桌台信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_restaurant_table
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '管理员', '管理所有功能');
INSERT INTO `sys_role` VALUES (2, '111', '111');

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
) ENGINE = InnoDB AUTO_INCREMENT = 53 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色权限关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role_permission
-- ----------------------------
INSERT INTO `sys_role_permission` VALUES (3, 1, 1);
INSERT INTO `sys_role_permission` VALUES (4, 1, 13);
INSERT INTO `sys_role_permission` VALUES (5, 1, 2);
INSERT INTO `sys_role_permission` VALUES (6, 1, 14);
INSERT INTO `sys_role_permission` VALUES (7, 1, 15);
INSERT INTO `sys_role_permission` VALUES (8, 1, 16);
INSERT INTO `sys_role_permission` VALUES (9, 1, 3);
INSERT INTO `sys_role_permission` VALUES (10, 1, 18);
INSERT INTO `sys_role_permission` VALUES (11, 1, 19);
INSERT INTO `sys_role_permission` VALUES (12, 1, 4);
INSERT INTO `sys_role_permission` VALUES (13, 1, 20);
INSERT INTO `sys_role_permission` VALUES (14, 1, 21);
INSERT INTO `sys_role_permission` VALUES (15, 1, 22);
INSERT INTO `sys_role_permission` VALUES (16, 1, 23);
INSERT INTO `sys_role_permission` VALUES (17, 1, 5);
INSERT INTO `sys_role_permission` VALUES (18, 1, 24);
INSERT INTO `sys_role_permission` VALUES (19, 1, 25);
INSERT INTO `sys_role_permission` VALUES (20, 1, 26);
INSERT INTO `sys_role_permission` VALUES (21, 1, 27);
INSERT INTO `sys_role_permission` VALUES (22, 1, 6);
INSERT INTO `sys_role_permission` VALUES (23, 1, 28);
INSERT INTO `sys_role_permission` VALUES (24, 1, 29);
INSERT INTO `sys_role_permission` VALUES (25, 1, 7);
INSERT INTO `sys_role_permission` VALUES (26, 1, 30);
INSERT INTO `sys_role_permission` VALUES (27, 1, 31);
INSERT INTO `sys_role_permission` VALUES (28, 1, 32);
INSERT INTO `sys_role_permission` VALUES (29, 1, 33);
INSERT INTO `sys_role_permission` VALUES (30, 1, 8);
INSERT INTO `sys_role_permission` VALUES (31, 1, 34);
INSERT INTO `sys_role_permission` VALUES (32, 1, 35);
INSERT INTO `sys_role_permission` VALUES (33, 1, 36);
INSERT INTO `sys_role_permission` VALUES (34, 1, 37);
INSERT INTO `sys_role_permission` VALUES (35, 1, 9);
INSERT INTO `sys_role_permission` VALUES (36, 1, 38);
INSERT INTO `sys_role_permission` VALUES (37, 1, 39);
INSERT INTO `sys_role_permission` VALUES (38, 1, 40);
INSERT INTO `sys_role_permission` VALUES (39, 1, 10);
INSERT INTO `sys_role_permission` VALUES (40, 1, 41);
INSERT INTO `sys_role_permission` VALUES (41, 1, 42);
INSERT INTO `sys_role_permission` VALUES (42, 1, 43);
INSERT INTO `sys_role_permission` VALUES (43, 1, 11);
INSERT INTO `sys_role_permission` VALUES (44, 1, 44);
INSERT INTO `sys_role_permission` VALUES (45, 1, 45);
INSERT INTO `sys_role_permission` VALUES (46, 1, 46);
INSERT INTO `sys_role_permission` VALUES (47, 1, 47);
INSERT INTO `sys_role_permission` VALUES (48, 1, 12);
INSERT INTO `sys_role_permission` VALUES (49, 1, 48);
INSERT INTO `sys_role_permission` VALUES (50, 1, 49);
INSERT INTO `sys_role_permission` VALUES (51, 1, 50);
INSERT INTO `sys_role_permission` VALUES (52, 1, 51);

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '套餐信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_set_meal
-- ----------------------------

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
  `is_replaceable` tinyint NOT NULL DEFAULT 0 COMMENT '是否可替换（1-是；0-否）',
  `replaceable_dishes` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '可替换菜品ID（逗号分隔）',
  PRIMARY KEY (`item_id`) USING BTREE,
  INDEX `idx_meal_item_meal`(`meal_id` ASC) USING BTREE,
  INDEX `fk_meal_item_dish`(`dish_id` ASC) USING BTREE,
  INDEX `fk_meal_item_spec`(`spec_id` ASC) USING BTREE,
  CONSTRAINT `fk_meal_item_dish` FOREIGN KEY (`dish_id`) REFERENCES `sys_dish` (`dish_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_meal_item_meal` FOREIGN KEY (`meal_id`) REFERENCES `sys_set_meal` (`meal_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_meal_item_spec` FOREIGN KEY (`spec_id`) REFERENCES `sys_dish_spec` (`spec_id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '套餐包含菜品表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_set_meal_item
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '员工表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_staff
-- ----------------------------
INSERT INTO `sys_staff` VALUES (2, 1, 'admin', '87yYyL/FpfaAog73mQWkrRaohR6RXvMgHoZLvgTkqrI=', '管理员', '18433646699', '管理员', 0, '2025-08-11 03:27:07', 'fcaUL2ziMYrVznCMcKgaNQ==', 1);

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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '员工角色关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_staff_role
-- ----------------------------
INSERT INTO `sys_staff_role` VALUES (1, 2, 1);

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
INSERT INTO `sys_store` VALUES (2, '旗舰店', '2244', '111', '111', 20, 1, '2025-08-11 15:21:45', '2025-08-11 15:27:41');

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '供应商表' ROW_FORMAT = DYNAMIC;

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
  `transfer_time` datetime NOT NULL COMMENT '转桌时间',
  `operator_id` bigint NOT NULL COMMENT '操作员工ID',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '转桌原因',
  PRIMARY KEY (`transfer_id`) USING BTREE,
  INDEX `idx_transfer_order`(`order_id` ASC) USING BTREE,
  INDEX `idx_transfer_time`(`transfer_time` ASC) USING BTREE,
  INDEX `fk_transfer_old_table`(`old_table_id` ASC) USING BTREE,
  INDEX `fk_transfer_new_table`(`new_table_id` ASC) USING BTREE,
  CONSTRAINT `fk_transfer_new_table` FOREIGN KEY (`new_table_id`) REFERENCES `sys_restaurant_table` (`table_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_transfer_old_table` FOREIGN KEY (`old_table_id`) REFERENCES `sys_restaurant_table` (`table_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '桌台转桌记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_table_transfer
-- ----------------------------

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '定时器管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_timertask
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
