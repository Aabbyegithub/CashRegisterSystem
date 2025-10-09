using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ModelClassLibrary.Model.Dto.inventoryDto
{
    public class inventory
    {
        public class InventoryAlertDto
        {
            public long material_id { get; set; }
            public string material_name { get; set; }
            public string category { get; set; }
            public string unit { get; set; }
            public decimal quantity { get; set; }
            /// <summary>
            /// Desc:入库数量
            /// Default:0.00
            /// Nullable:False
            /// </summary>           
            public decimal in_quantity { get; set; }

            /// <summary>
            /// Desc:出库数量
            /// Default:0.00
            /// Nullable:False
            /// </summary>           
            public decimal out_quantity { get; set; }
            public decimal warning_threshold { get; set; }
            public byte status { get; set; }
            public long store_id { get; set; }
        }
    }
}
