using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using SqlSugar;
using MyNamespace;
using WebIServices.IServices.DashboardIServices;
using WebIServices.IBase;
using static ModelClassLibrary.Model.Dto.DashboardDto.Dashboard;

namespace WebServiceClass.Services.DashboardServices
{
    public class CoreKPIReportServices : CoreKPIReportIServices, IBaseService
    {
        private readonly ISqlHelper _dal;

        public CoreKPIReportServices(ISqlHelper dal)
        {
            _dal = dal;
        }

        public async Task<KPIDashboardDto> GetDashboardDataAsync()
        {
            var today = DateTime.Today;
            var tomorrow = today.AddDays(1);

            var dto = new KPIDashboardDto();

            // 翻台率（当日桌台使用次数 / 总桌台数）
            var totalTable = await _dal.Db.Queryable<sys_restaurant_table>().CountAsync();
            var usedTable = await _dal.Db.Queryable<sys_order>()
                .Where(x =>  x.start_time >= today && x.start_time < tomorrow)
                .Select(x => x.table_id).Distinct().CountAsync();
            dto.TurnoverRate = totalTable > 0 ? Math.Round((double)usedTable / totalTable, 2) : 0;

            // 人均消费（总金额 / 总人数）
            var totalPerson = await _dal.Db.Queryable<sys_order>()
                .Where(x =>  x.start_time >= today && x.start_time < tomorrow)
                .SumAsync(x => x.table_capacity ?? 0);
            var totalAmount = await _dal.Db.Queryable<sys_order>()
                .Where(x =>  x.start_time >= today && x.start_time < tomorrow)
                .SumAsync(x => x.total_amount);
            dto.AvgPerPerson = totalPerson > 0 ? Math.Round((double)totalAmount / totalPerson, 2) : 0;

            // 客单价（总金额 / 订单数）
            var totalOrder = await _dal.Db.Queryable<sys_order>()
                .Where(x =>  x.start_time >= today && x.start_time < tomorrow)
                .CountAsync();
            dto.AvgPerOrder = totalOrder > 0 ? Math.Round((double)totalAmount / totalOrder, 2) : 0;

            // 时段客流高峰（早餐/午餐/晚餐/其他，假设有period字段或用时间段判断）
            var peakPeriod = new List<PeriodFlowDto>();
            peakPeriod.Add(new PeriodFlowDto
            {
                Period = "早餐",
                Count = await _dal.Db.Queryable<sys_order>().Where(x =>  x.start_time >= today.AddHours(6) && x.start_time < today.AddHours(10)).CountAsync()
            });
            peakPeriod.Add(new PeriodFlowDto
            {
                Period = "午餐",
                Count = await _dal.Db.Queryable<sys_order>().Where(x =>  x.start_time >= today.AddHours(10) && x.start_time < today.AddHours(14)).CountAsync()
            });
            peakPeriod.Add(new PeriodFlowDto
            {
                Period = "晚餐",
                Count = await _dal.Db.Queryable<sys_order>().Where(x =>  x.start_time >= today.AddHours(17) && x.start_time < today.AddHours(21)).CountAsync()
            });
            peakPeriod.Add(new PeriodFlowDto
            {
                Period = "其他",
                Count = await _dal.Db.Queryable<sys_order>().Where(x => 
                    ((x.start_time >= today && x.start_time < today.AddHours(6)) ||
                     (x.start_time >= today.AddHours(14) && x.start_time < today.AddHours(17)) ||
                     (x.start_time >= today.AddHours(21) && x.start_time < tomorrow))
                ).CountAsync()
            });
            var totalPeak = peakPeriod.Sum(x => x.Count);
            peakPeriod.ForEach(x => x.Rate = totalPeak > 0 ? $"{Math.Round((double)x.Count / totalPeak * 100)}%" : "0%");
            dto.PeakPeriod = peakPeriod;

            // 畅销菜品TOP10（销量/利润）
            var topDishes = await _dal.Db.Queryable<sys_order_item>().Includes(x=>x.order).Includes(x=>x.dish)
                .Where(x => x.order.created_at >= today && x.order.created_at < tomorrow)
                .GroupBy(x => x.dish_id)
                .OrderBy("SUM(quantity) DESC")
                .Select(x => new DishSalesDto
                {
                    Name = x.dish.dish_name,
                    Sales = SqlFunc.AggregateSum(x.quantity),
                    Profit = SqlFunc.AggregateSum(x.unit_price * x.quantity) // 假设 price 字段为单价
                }).Take(10).ToListAsync();
            dto.TopDishes = topDishes;

            // 滞销菜品预警（近两周销量<10）
            var unsalableDishes = await _dal.Db.Queryable<sys_order_item>().Includes(x=>x.order).Includes(x=>x.dish)
                .Where(x => x.order.created_at >= today.AddDays(-14) && x.order.created_at < tomorrow)
                .GroupBy(x => x.dish_id)
                .Select(x => new DishSalesDto
                {
                    Name = x.dish.dish_name,
                    Sales = SqlFunc.AggregateSum(x.quantity),
                    Warning = SqlFunc.AggregateSum(x.quantity) < 10
                }).ToListAsync();
            dto.UnsalableDishes = unsalableDishes.Where(x => x.Warning).ToList();

            // 菜品搭配分析（示例：统计同单出现频率最高的组合，实际业务可优化）
            // 这里只做简单示例，实际可用复杂算法
            dto.DishCombos = new List<DishComboDto>(); // 可补充实现

            // 服务员绩效（订单量、退菜率、评价，假设有相关字段）
            var waiterPerf = await _dal.Db.Queryable<sys_order>()
                .LeftJoin<sys_staff>((order, staff) => order.operator_id == staff.staff_id)
                .Where(order => order.start_time >= today && order.start_time < tomorrow)
                .GroupBy((order, staff) => order.operator_id)
                .Select((order, staff) => new WaiterPerformanceDto
                {
                    Name = SqlFunc.AggregateMax(SqlFunc.IsNull(staff.name, "")),
                    OrderCount = SqlFunc.AggregateCount(order.order_id),
                    ReturnRate = "0%",
                    Rating = "5.0"
                })
                .ToListAsync();

            dto.WaiterPerformance = waiterPerf;

            // 门店对比（营业额、利润率、排名，假设有相关字段）
            var storeCompare = await _dal.Db.Queryable<sys_order>().Includes(x=>x.store)
                .Where(x => x.start_time >= today && x.start_time < tomorrow)
                .GroupBy(x => x.store_id)
                .Select(x => new StoreCompareDto
                {
                    Name = x.store.store_name,
                    Revenue = SqlFunc.AggregateSum(x.total_amount),
                    ProfitRate = 0, // 可根据你的利润字段或公式计算
                    Rank = 0        // 稍后排序后赋值
                }).ToListAsync();

            // 排名赋值
            storeCompare = storeCompare.OrderByDescending(x => x.Revenue).ToList();
            for (int i = 0; i < storeCompare.Count; i++)
            {
                storeCompare[i].Rank = i + 1;
            }
            dto.StoreCompare = storeCompare;

            // 外卖订单占比（order_type=2为外卖）
            var totalOrderAll = await _dal.Db.Queryable<sys_order>()
                .Where(x =>  x.start_time >= today && x.start_time < tomorrow)
                .CountAsync();
            var takeawayOrder = await _dal.Db.Queryable<sys_order>()
                .Where(x =>  x.start_time >= today && x.start_time < tomorrow && x.order_type == 2)
                .CountAsync();
            dto.OrderChannels = new List<OrderChannelDto>
            {
                new OrderChannelDto
                {
                    //Store = storeId.ToString(),
                    Online = takeawayOrder,
                    Offline = totalOrderAll - takeawayOrder,
                    TakeawayRate = totalOrderAll > 0 ? (int)Math.Round((double)takeawayOrder / totalOrderAll * 100) : 0
                }
            };

            return dto;
        }
    }
}
