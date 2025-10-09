using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ModelClassLibrary.Model.Dto.QueueDto
{
    public class QueueDto
    {
        public class QueueStatsDto
        {
            public int waitingCount { get; set; }
            public int averageWaitTime { get; set; }
            public int totalToday { get; set; }
            public int skippedRate { get; set; }
            public int finished { get; set; }
        }
    }
}
