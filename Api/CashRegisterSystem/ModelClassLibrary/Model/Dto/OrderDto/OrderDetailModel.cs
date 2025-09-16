using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ModelClassLibrary.Model.Dto.OrderDto
{
    public class OrderDetailModel
    {
        public int orderId { get; set; }
         public int tableId { get; set; }
        public string tableNumber { get; set; }
        public string desc { get; set; }
        public decimal totalAmount { get; set; }
        public decimal receivedAmount { get; set; }
        public decimal zeroAmount { get; set; }
        public string orderNumber { get; set; }
        public string changeTable { get; set; }
        public string mergedTable { get; set; }
        public decimal totalOrderAmount { get; set; }
        public decimal nonDiscountAmount { get; set; }
        public decimal consumeAmount { get; set; }
        public int? table_capacity { get; set; }

        public DateTime createTime { get; set; }

        public List<detail> items { get; set; }
    }


    public class detail
    {
        public string orderItemId { get; set; }
        public string name { get; set; }
        public decimal price { get; set; }
        public int quantity { get; set; }
        public string unit { get; set; } = "份";
        public decimal amount { get; set; }
        public string action { get; set; } = "退款";
    }

}
