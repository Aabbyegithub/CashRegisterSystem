INSERT INTO cashiersystem.sys_timertask (TimerName,TimerClass,CreateTime,BeginTime,EndTime,AddUser,OrgId,IsStart,isDelete,Corn,StartNumber) VALUES
	 ('活动/优惠卷自动开始和关闭','AutomatedTask','2025-09-16 11:45:16','2025-09-16 11:45:16','2125-09-16 11:45:16',NULL,NULL,1,1,'0 0/1 * * * ? ',NULL),
	 ('每天o点自动备份前一天的已结算的订单','BackUpTask','2025-09-16 11:45:46','2025-09-16 11:45:46','2125-09-16 11:45:46',NULL,NULL,1,1,'0 0 1 * * ? ',0),
	 ('定时清理操作日志保留半个月','ClearLogsTask','2025-09-16 14:07:09','2025-09-16 14:07:09','2125-09-16 14:07:09',NULL,NULL,1,1,'0 0 1 * * ?',NULL),
	 ('厨房菜品制作超时预警','kitchenOverTimeTask','2025-09-16 14:12:34','2025-09-16 14:12:34','2125-09-16 14:12:34',NULL,NULL,1,1,'0 0/1 * * * ?',NULL),
	 ('清洁中桌台十分钟自动变为空闲','ClearTableTask','2025-09-16 16:26:30','2025-09-16 16:26:30','2125-09-16 16:26:30',NULL,NULL,1,1,'0 0/1 0/1 * * ? ',0),
	 ('自动管理套餐的上下架','DishMealTask','2025-09-16 16:45:22','2025-09-16 16:45:22','2125-09-16 16:45:22',NULL,NULL,1,1,'0 0/1 0/1 * * ? ',0);
