/*
 Navicat Premium Data Transfer

 Source Server         : localhostMysql
 Source Server Type    : MySQL
 Source Server Version : 80042
 Source Host           : localhost:3306
 Source Schema         : cashiersystem

 Target Server Type    : MySQL
 Target Server Version : 80042
 File Encoding         : 65001

 Date: 05/08/2025 00:04:07
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
  UNIQUE INDEX `uk_bill_no`(`bill_no`) USING BTREE,
  INDEX `idx_bill_order`(`order_id`) USING BTREE,
  INDEX `idx_bill_parent`(`parent_bill_id`) USING BTREE,
  INDEX `idx_bill_type`(`bill_type`) USING BTREE,
  INDEX `idx_bill_close_time`(`close_time`) USING BTREE,
  INDEX `idx_bill_invoice`(`invoice_status`) USING BTREE,
  CONSTRAINT `fk_bill_order` FOREIGN KEY (`order_id`) REFERENCES `sys_order` (`order_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '账单表' ROW_FORMAT = Dynamic;

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
  UNIQUE INDEX `uk_coupon_no`(`coupon_no`) USING BTREE,
  INDEX `idx_coupon_store`(`store_id`) USING BTREE,
  INDEX `idx_coupon_type`(`type`) USING BTREE,
  INDEX `idx_coupon_status`(`status`) USING BTREE,
  INDEX `idx_coupon_valid`(`valid_start`, `valid_end`) USING BTREE,
  CONSTRAINT `fk_coupon_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '优惠券表' ROW_FORMAT = Dynamic;

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
  INDEX `idx_dish_category`(`category_id`) USING BTREE,
  INDEX `idx_dish_name`(`dish_name`) USING BTREE,
  INDEX `idx_dish_status`(`status`) USING BTREE,
  INDEX `idx_dish_recommend`(`is_recommend`) USING BTREE,
  INDEX `idx_dish_temporary`(`is_temporary`) USING BTREE,
  CONSTRAINT `fk_dish_category` FOREIGN KEY (`category_id`) REFERENCES `sys_dish_category` (`category_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品信息表' ROW_FORMAT = Dynamic;

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
  INDEX `idx_category_store`(`store_id`) USING BTREE,
  CONSTRAINT `fk_category_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品分类表' ROW_FORMAT = Dynamic;

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
  INDEX `idx_formula_dish`(`dish_id`) USING BTREE,
  INDEX `idx_formula_material`(`material_id`) USING BTREE,
  INDEX `fk_formula_spec`(`spec_id`) USING BTREE,
  CONSTRAINT `fk_formula_dish` FOREIGN KEY (`dish_id`) REFERENCES `sys_dish` (`dish_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_formula_material` FOREIGN KEY (`material_id`) REFERENCES `sys_raw_material` (`material_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_formula_spec` FOREIGN KEY (`spec_id`) REFERENCES `sys_dish_spec` (`spec_id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品配方表（原材料消耗规则）' ROW_FORMAT = Dynamic;

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
  INDEX `idx_spec_dish`(`dish_id`) USING BTREE,
  CONSTRAINT `fk_spec_dish` FOREIGN KEY (`dish_id`) REFERENCES `sys_dish` (`dish_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜品规格表' ROW_FORMAT = Dynamic;

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
  INDEX `idx_inventory_store`(`store_id`) USING BTREE,
  INDEX `idx_inventory_material`(`material_id`) USING BTREE,
  INDEX `idx_inventory_batch`(`batch_no`) USING BTREE,
  INDEX `idx_inventory_purchase`(`purchase_time`) USING BTREE,
  INDEX `idx_inventory_expiry`(`expiry_date`) USING BTREE,
  INDEX `idx_inventory_supplier`(`supplier_id`) USING BTREE,
  INDEX `idx_material_expiry`(`material_id`, `expiry_date`) USING BTREE,
  CONSTRAINT `fk_inventory_material` FOREIGN KEY (`material_id`) REFERENCES `sys_raw_material` (`material_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_inventory_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '库存表' ROW_FORMAT = Dynamic;

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
  INDEX `idx_loss_store`(`store_id`) USING BTREE,
  INDEX `idx_loss_material`(`material_id`) USING BTREE,
  INDEX `idx_loss_batch`(`batch_no`) USING BTREE,
  INDEX `idx_loss_type`(`loss_type`) USING BTREE,
  INDEX `idx_loss_time`(`loss_time`) USING BTREE,
  CONSTRAINT `fk_loss_material` FOREIGN KEY (`material_id`) REFERENCES `sys_raw_material` (`material_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_loss_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '库存损耗表' ROW_FORMAT = Dynamic;

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
  UNIQUE INDEX `uk_kitchen_item`(`item_id`) USING BTREE,
  INDEX `idx_kitchen_store`(`store_id`) USING BTREE,
  INDEX `idx_kitchen_type`(`kitchen_type`) USING BTREE,
  INDEX `idx_kitchen_status`(`status`) USING BTREE,
  INDEX `idx_kitchen_time`(`create_time`) USING BTREE,
  INDEX `idx_kitchen_overtime`(`overtime_warn`) USING BTREE,
  INDEX `idx_store_kitchen_status_time`(`store_id`, `kitchen_type`, `status`, `create_time`) USING BTREE,
  CONSTRAINT `fk_kitchen_item` FOREIGN KEY (`item_id`) REFERENCES `sys_order_item` (`item_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_kitchen_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '厨房订单表（KDS系统同步）' ROW_FORMAT = Dynamic;

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
  UNIQUE INDEX `uk_member_no`(`member_no`) USING BTREE,
  UNIQUE INDEX `uk_member_phone`(`phone`) USING BTREE,
  INDEX `idx_member_status`(`status`) USING BTREE,
  INDEX `idx_member_register`(`register_time`) USING BTREE,
  INDEX `idx_member_birthday`(`birthday`) USING BTREE,
  INDEX `idx_member_referrer`(`referrer_id`) USING BTREE,
  CONSTRAINT `fk_member_referrer` FOREIGN KEY (`referrer_id`) REFERENCES `sys_member` (`member_id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会员表' ROW_FORMAT = Dynamic;

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
  INDEX `idx_balance_member`(`member_id`) USING BTREE,
  INDEX `idx_balance_time`(`recharge_time`) USING BTREE,
  INDEX `fk_balance_payment`(`payment_id`) USING BTREE,
  CONSTRAINT `fk_balance_member` FOREIGN KEY (`member_id`) REFERENCES `sys_member` (`member_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_balance_payment` FOREIGN KEY (`payment_id`) REFERENCES `sys_payment` (`payment_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '会员储值记录表' ROW_FORMAT = Dynamic;

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
  INDEX `index`(`UserId`, `ActionType`, `ModuleName`, `OrgId`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 554 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统操作日志' ROW_FORMAT = DYNAMIC;

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
  UNIQUE INDEX `uk_order_no`(`order_no`) USING BTREE,
  INDEX `idx_order_store`(`store_id`) USING BTREE,
  INDEX `idx_order_table`(`table_id`) USING BTREE,
  INDEX `idx_order_member`(`member_id`) USING BTREE,
  INDEX `idx_order_type`(`order_type`) USING BTREE,
  INDEX `idx_order_source`(`source_type`) USING BTREE,
  INDEX `idx_order_status`(`status`) USING BTREE,
  INDEX `idx_order_start_time`(`start_time`) USING BTREE,
  INDEX `idx_order_pay_time`(`pay_time`) USING BTREE,
  INDEX `idx_store_status_time`(`store_id`, `status`, `start_time`) USING BTREE,
  CONSTRAINT `fk_order_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_order_table` FOREIGN KEY (`table_id`) REFERENCES `sys_restaurant_table` (`table_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单主表' ROW_FORMAT = Dynamic;

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
  INDEX `idx_item_order`(`order_id`) USING BTREE,
  INDEX `idx_item_dish`(`dish_id`) USING BTREE,
  INDEX `idx_item_meal`(`meal_id`) USING BTREE,
  INDEX `idx_item_status`(`status`) USING BTREE,
  INDEX `idx_item_rush`(`is_rush`) USING BTREE,
  CONSTRAINT `fk_item_dish` FOREIGN KEY (`dish_id`) REFERENCES `sys_dish` (`dish_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_item_meal` FOREIGN KEY (`meal_id`) REFERENCES `sys_set_meal` (`meal_id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_item_order` FOREIGN KEY (`order_id`) REFERENCES `sys_order` (`order_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单明细表' ROW_FORMAT = Dynamic;

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
  UNIQUE INDEX `uk_payment_no`(`payment_no`) USING BTREE,
  INDEX `idx_payment_order`(`order_id`) USING BTREE,
  INDEX `idx_payment_member`(`member_id`) USING BTREE,
  INDEX `idx_payment_type`(`pay_type`) USING BTREE,
  INDEX `idx_payment_platform`(`third_platform`) USING BTREE,
  INDEX `idx_payment_status`(`status`) USING BTREE,
  INDEX `idx_payment_time`(`pay_time`) USING BTREE,
  INDEX `idx_payment_account`(`store_account_id`) USING BTREE,
  CONSTRAINT `fk_payment_order` FOREIGN KEY (`order_id`) REFERENCES `sys_order` (`order_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '支付记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sys_permission
-- ----------------------------
DROP TABLE IF EXISTS `sys_permission`;
CREATE TABLE `sys_permission`  (
  `permission_id` bigint NOT NULL AUTO_INCREMENT COMMENT '权限ID（主键）',
  `permission_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限名称（如\"订单管理\"）',
  `permission_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '权限标识（如\"order:manage\"）',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT '父权限ID（用于层级）',
  PRIMARY KEY (`permission_id`) USING BTREE,
  UNIQUE INDEX `uk_permission_key`(`permission_key`) USING BTREE,
  INDEX `idx_permission_parent`(`parent_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '权限表' ROW_FORMAT = Dynamic;

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
  INDEX `idx_promotion_store`(`store_id`) USING BTREE,
  INDEX `idx_promotion_type`(`type`) USING BTREE,
  INDEX `idx_promotion_time`(`start_time`, `end_time`) USING BTREE,
  INDEX `idx_promotion_status`(`status`) USING BTREE,
  CONSTRAINT `fk_promotion_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '促销活动表' ROW_FORMAT = Dynamic;

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
  UNIQUE INDEX `uk_po_no`(`po_no`) USING BTREE,
  INDEX `idx_po_store`(`store_id`) USING BTREE,
  INDEX `idx_po_supplier`(`supplier_id`) USING BTREE,
  INDEX `idx_po_order_time`(`order_time`) USING BTREE,
  INDEX `idx_po_arrival`(`expect_arrival_time`) USING BTREE,
  INDEX `idx_po_status`(`status`) USING BTREE,
  CONSTRAINT `fk_po_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_po_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `sys_supplier` (`supplier_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '采购单表' ROW_FORMAT = Dynamic;

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
  UNIQUE INDEX `uk_queue_no`(`queue_no`) USING BTREE,
  INDEX `idx_queue_store`(`store_id`) USING BTREE,
  INDEX `idx_queue_status`(`status`) USING BTREE,
  INDEX `idx_queue_phone`(`customer_phone`) USING BTREE,
  INDEX `idx_queue_time`(`queue_time`) USING BTREE,
  INDEX `fk_queue_table`(`table_id`) USING BTREE,
  CONSTRAINT `fk_queue_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_queue_table` FOREIGN KEY (`table_id`) REFERENCES `sys_restaurant_table` (`table_id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '排队叫号表' ROW_FORMAT = Dynamic;

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
  INDEX `idx_material_store`(`store_id`) USING BTREE,
  INDEX `idx_material_name`(`material_name`) USING BTREE,
  INDEX `idx_material_category`(`category`) USING BTREE,
  CONSTRAINT `fk_material_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '原材料表' ROW_FORMAT = Dynamic;

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
  INDEX `idx_table_store`(`store_id`) USING BTREE,
  INDEX `idx_table_status`(`status`) USING BTREE,
  INDEX `idx_table_no`(`table_no`) USING BTREE,
  CONSTRAINT `fk_table_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '桌台信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID（主键）',
  `role_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称（店长/收银员/厨师）',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '角色描述',
  PRIMARY KEY (`role_id`) USING BTREE,
  UNIQUE INDEX `uk_role_name`(`role_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sys_role_permission
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_permission`;
CREATE TABLE `sys_role_permission`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '关联ID（主键）',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `permission_id` bigint NOT NULL COMMENT '权限ID',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_role_permission_role`(`role_id`) USING BTREE,
  INDEX `idx_role_permission_permission`(`permission_id`) USING BTREE,
  CONSTRAINT `fk_role_permission_permission` FOREIGN KEY (`permission_id`) REFERENCES `sys_permission` (`permission_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_role_permission_role` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`role_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色权限关联表' ROW_FORMAT = Dynamic;

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
  INDEX `idx_meal_store`(`store_id`) USING BTREE,
  INDEX `idx_meal_name`(`meal_name`) USING BTREE,
  INDEX `idx_meal_status`(`status`) USING BTREE,
  INDEX `idx_meal_time`(`start_time`, `end_time`) USING BTREE,
  INDEX `idx_meal_fixed`(`is_fixed`) USING BTREE,
  CONSTRAINT `fk_meal_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '套餐信息表' ROW_FORMAT = Dynamic;

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
  INDEX `idx_meal_item_meal`(`meal_id`) USING BTREE,
  INDEX `fk_meal_item_dish`(`dish_id`) USING BTREE,
  INDEX `fk_meal_item_spec`(`spec_id`) USING BTREE,
  CONSTRAINT `fk_meal_item_dish` FOREIGN KEY (`dish_id`) REFERENCES `sys_dish` (`dish_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_meal_item_meal` FOREIGN KEY (`meal_id`) REFERENCES `sys_set_meal` (`meal_id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_meal_item_spec` FOREIGN KEY (`spec_id`) REFERENCES `sys_dish_spec` (`spec_id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '套餐包含菜品表' ROW_FORMAT = Dynamic;

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
  PRIMARY KEY (`staff_id`) USING BTREE,
  UNIQUE INDEX `uk_staff_username`(`username`) USING BTREE,
  INDEX `idx_staff_store`(`store_id`) USING BTREE,
  INDEX `idx_staff_position`(`position`) USING BTREE,
  INDEX `idx_staff_status`(`status`) USING BTREE,
  CONSTRAINT `fk_staff_store` FOREIGN KEY (`store_id`) REFERENCES `sys_store` (`store_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '员工表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sys_staff_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_staff_role`;
CREATE TABLE `sys_staff_role`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '关联ID（主键）',
  `staff_id` bigint NOT NULL COMMENT '员工ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_staff_role_staff`(`staff_id`) USING BTREE,
  INDEX `idx_staff_role_role`(`role_id`) USING BTREE,
  CONSTRAINT `fk_staff_role_role` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`role_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_staff_role_staff` FOREIGN KEY (`staff_id`) REFERENCES `sys_staff` (`staff_id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '员工角色关联表' ROW_FORMAT = Dynamic;

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
  INDEX `idx_store_status`(`status`) USING BTREE,
  INDEX `idx_store_name`(`store_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '门店信息表' ROW_FORMAT = Dynamic;

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
  INDEX `idx_supplier_name`(`supplier_name`) USING BTREE,
  INDEX `idx_supplier_status`(`status`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '供应商表' ROW_FORMAT = Dynamic;

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
  INDEX `idx_transfer_order`(`order_id`) USING BTREE,
  INDEX `idx_transfer_time`(`transfer_time`) USING BTREE,
  INDEX `fk_transfer_old_table`(`old_table_id`) USING BTREE,
  INDEX `fk_transfer_new_table`(`new_table_id`) USING BTREE,
  CONSTRAINT `fk_transfer_new_table` FOREIGN KEY (`new_table_id`) REFERENCES `sys_restaurant_table` (`table_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_transfer_old_table` FOREIGN KEY (`old_table_id`) REFERENCES `sys_restaurant_table` (`table_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '桌台转桌记录表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '定时器管理' ROW_FORMAT = DYNAMIC;

SET FOREIGN_KEY_CHECKS = 1;
