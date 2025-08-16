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
    }
}
