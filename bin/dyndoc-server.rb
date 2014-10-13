#!mruby

module Dyndoc

  class InteractiveServer

    def initialize
      init_dyndoc
      init_uv_server
    end

    def init_dyndoc
      unless $tmpl_mngr
        $tmpl_mngr = Dyndoc::MRuby::TemplateManager.new({})
        $tmpl_mngr.init_doc({})
      end
    end

    def process_dyndoc(content)
      $tmpl_mngr.parse(content)
    end

    def init_uv_server
      @t = UV::Timer.new

      if UV::Signal.const_defined?(:SIGINT)
        UV::Signal.new.start(UV::Signal::SIGINT) do
          puts "connection closed"
          @t.stop
          @s.close
          UV::default_loop().stop
        end
      end

      @s = UV::TCP.new
      @s.bind(UV::ip4_addr('127.0.0.1', 7777))
      puts "bound to #{@s.getsockname}"

    end

    def run
      @s.listen(5) {|x|
        return if x != 0
        c = @s.accept
        puts "connected (peer: #{c.getpeername})"
        c.read_start {|b|
          data = b.to_s.strip
          ##p [:data,data]
            if data =~ /^__send_cmd__\[\[([a-z]*)\]\]__(.*)__\[\[END_TOKEN\]\]__$/m
              cmd,content = $1,$2
              ##p [:cmd,cmd,:content,content]
              if cmd == "dyndoc"
                res = process_dyndoc(content)
                c.write "__send_cmd__[[dyndoc]]__"+res+"__[[END_TOKEN]]__"
              end
            end
        }
      }

      UV::run()
    end

  end

end

Dyndoc::InteractiveServer.new.run
