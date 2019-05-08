/*
 Navicat Premium Data Transfer

 Source Server         : 127.0.0.1
 Source Server Type    : MySQL
 Source Server Version : 50719
 Source Host           : localhost
 Source Database       : cdib

 Target Server Type    : MySQL
 Target Server Version : 50719
 File Encoding         : utf-8

 Date: 05/08/2019 11:52:28 AM
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Table structure for `transaction_records`
-- ----------------------------
DROP TABLE IF EXISTS `transaction_records`;
CREATE TABLE `transaction_records` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
  `request_id` varchar(70) NOT NULL DEFAULT '' COMMENT '请求ID',
  `from` varchar(64) NOT NULL DEFAULT '' COMMENT '发起方',
  `to` varchar(64) NOT NULL DEFAULT '' COMMENT '接收方',
  `currency` varchar(16) NOT NULL COMMENT '货币名称',
  `amount` decimal(38,0) unsigned NOT NULL DEFAULT '0' COMMENT '转账金额',
  `gas_used` decimal(38,0) unsigned NOT NULL DEFAULT '0' COMMENT '支付手续费',
  `status` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '当前订单是否已经执行',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `rlp` text NOT NULL COMMENT 'rlp编码',
  PRIMARY KEY (`id`),
  UNIQUE KEY `request_id` (`request_id`) USING BTREE,
  KEY `currency` (`currency`) USING HASH
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
