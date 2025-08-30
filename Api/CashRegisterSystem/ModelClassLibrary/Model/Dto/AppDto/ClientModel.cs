using MyNamespace;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ModelClassLibrary.Model.Dto.AppDto
{
    /// <summary>
    /// App相关Dto
    /// </summary>
    public class ClientModel
    {
        public long Id { get; set; }
        public string Name { get; set; }
        public int Status { get; set; }

        public int People { get; set; } = 0;
        public int Max { get; set; }
        public string bookedTime { get; set; }
    }

    public class DishCategory
    {
        public long Id { get; set; } 
        public string Name { get; set; }
        public bool active { get; set; } = false;
    }

    public class DishList
    {
        public long Id { get; set; }
        public string Name { get; set; }
        public string Desc { get; set; }
        public decimal Price { get; set; } = 0;
        /// <summary>
        /// 是否存在辣度或其他选择
        /// </summary>
        public int Spece { get; set; }
        public string Img { get; set; }

        public long DishCategoryType { get; set; }
       public List<sys_dish_spec> dish_spec{ get; set; }
    }

    public class Order
    {
        public long Id { get; set; }
        public string name { get; set; }
        public string price { get; set; }
        public string spec { get; set; }
        public string spicy { get; set; }
        public int qty { get; set; }
    }

    public class OrderDetail
    {
        public long Id { get; set; }
        public string Name { get; set; }
        public string Spec { get; set; }
        public decimal Price { get; set; }
    }

    public class OrderDetailResult
    {
        public int orderId { get; set; }
        public int tableId { get; set; }
        public int storeId { get; set; }

        public string tableName { get; set; }
        public string mergedTable { get; set; }
        public string changeTable { get; set; }
        public decimal total { get; set; }

        public List<OrderDetail> orderDetails { get; set; }
    }




}
