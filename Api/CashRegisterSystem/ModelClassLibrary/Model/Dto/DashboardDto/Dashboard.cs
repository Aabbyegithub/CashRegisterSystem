using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ModelClassLibrary.Model.Dto.DashboardDto
{
    public class Dashboard
    {
        public class KPIDashboardDto
        {
            public double TurnoverRate { get; set; }
            public double AvgPerPerson { get; set; }
            public double AvgPerOrder { get; set; }
            public List<OrderChannelDto> OrderChannels { get; set; } = new();
            public List<PeriodFlowDto> PeakPeriod { get; set; } = new();
            public List<DishSalesDto> TopDishes { get; set; } = new();
            public List<DishSalesDto> UnsalableDishes { get; set; } = new();
            public List<DishComboDto> DishCombos { get; set; } = new();
            public List<WaiterPerformanceDto> WaiterPerformance { get; set; } = new();
            public List<StoreCompareDto> StoreCompare { get; set; } = new();
        }

        public class OrderChannelDto
        {
            public string Store { get; set; } = "";
            public int Online { get; set; }
            public int Offline { get; set; }
            public int TakeawayRate { get; set; }
        }

        public class PeriodFlowDto
        {
            public string Period { get; set; } = "";
            public int Count { get; set; }
            public string Rate { get; set; } = "";
        }

        public class DishSalesDto
        {
            public string Name { get; set; } = "";
            public int Sales { get; set; }
            public decimal Profit { get; set; }
            public bool Warning { get; set; }
        }

        public class DishComboDto
        {
            public string MainDish { get; set; } = "";
            public string ComboDish { get; set; } = "";
            public string Rate { get; set; } = "";
        }

        public class WaiterPerformanceDto
        {
            public string Name { get; set; } = "";
            public int OrderCount { get; set; }
            public string ReturnRate { get; set; } = "";
            public string Rating { get; set; } = "";
        }

        public class StoreCompareDto
        {
            public string Name { get; set; } = "";
            public decimal Revenue { get; set; }
            public decimal ProfitRate { get; set; }
            public int Rank { get; set; }
        }
    }
}
