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
    }
}
