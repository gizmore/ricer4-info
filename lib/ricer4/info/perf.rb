module Ricer4::Plugins::Info
  class Perf < Ricer4::Plugin

    trigger_is :perf
    
    def plugin_init
      @@max_memory = 0
      @@max_mem_time = Time.now
      memory_peak
      arm_subscribe('ricer/triggered') do
        memory_peak
      end
    end
    
    def memory
      OS.rss_bytes * 1024
    end

    def memory_peak
      mem = memory
      if mem >= @@max_memory
        @@max_memory = mem
        @@max_mem_time = Time.now
      end
      bot.log.debug("Info/Perf#memory_peak is at #{@@max_memory}")
      @@max_memory
    end
    
    has_usage
    def execute
      memory = memory_peak
      adapter = ActiveRecord::ConnectionAdapters::AbstractAdapter
      queries = adapter.querycount
      db_time = adapter.querytime
      pool_now = pool_max = pool_peak = ActiveRecord::Base.connection_pool.connections.size
      rply(:msg_performance,
        queries: queries, qps: human_fraction(queries/bot.uptime.to_f, 2),
        db_time: human_duration(db_time), uptime: human_duration(bot.uptime),
        pool_now: pool_now, pool_peak: pool_peak, pool_max: pool_max,
        threads: Ricer4::Thread.count, max_threads: Ricer4::Thread.peak,
        memory: human_filesize(memory), max_memory: human_filesize(@@max_memory),
        pid: Process.pid, cpu: human_fraction(cpu_usage, 2),
      )
    end
    
    def cpu_usage
      OS.posix? ? `ps -o %cpu= -p #{Process.pid}`.to_f : "?.??(Win)"
    end
    
  end
end
