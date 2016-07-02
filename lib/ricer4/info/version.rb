module Ricer4::Plugins::Info
  class Version < Ricer4::Plugin
    
    trigger_is :version

    has_usage
    def execute
      rply :msg_version,
        owner: bot.config.owner,
        version: bot_version,
        date: bot_builddate,
        ruby: RUBY_VERSION,
        os: os_signature,
        time: l(Time.now)
    end
    
    private
    
    def bot_version
      
    end

    def bot_builddate
      
    end
    
    def os_signature
      RbConfig::CONFIG["arch"] || "Unknown"
#      'Linux'
    end
    
  end
end
