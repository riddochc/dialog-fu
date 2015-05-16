module Dialog

  # Figure out which implementation of dialog to use, based on platform detection.
  # This loads the methods from more specific submodules into this Dialog module, so that
  # you can just call (for example) Dialog.messagebox("Hello, world.")
  def self.autosetup
    case RUBY_PLATFORM
    when /linux/
      if ENV.fetch('DISPLAY', "").length > 0
        kdepid = IO.popen(["pidof", "-s", "kdeinit", "kdeinit4"], 'r') do |io|
          io.read
        end
        to_run = ["kdialog", "yad", "zenity", "dialog"].map {|name|
          name if ENV['PATH'].split(/:/).detect {|dir| File.exists?(File.join(dir, name)) }
        }.compact

        if kdepid != "" and to_run.include?("kdialog")
          extend KDialog  # Already running KDE?
        else
          if to_run.include?("yad")
            extend Yad
          elsif to_run.include?("zenity")
            extend Zenity
          elsif to_run.include?("kdialog")
            extend KDialog
          elsif (to_run.include?("dialog") and $stdout.isatty)
            extend Dialog
          end
        end
      else
        extend Dialog if ($stdout.isatty and $stdin.isatty)
      end
    when /darwin/
      extend CocoaDialog
    when /mingw/
      to_run = ["yad", "zenity", "dialog"].map {|name|
        name if ENV['PATH'].split(/;/).detect {|dir| File.exists?(File.join(dir, name)) }
      }.compact
      case to_run.first
      when 'yad'
        extend Yad
      when 'zenity'
        extend Zenity
      when 'dialog'
        extend Dialog
      else
        # Not sure here, any other way to get a dialog on windows?
      end
    else
      # The user will just have to load it themselves.
    end
  end

  # If you want to use the dropdown, checkboxes, radiobuttons, or similar methods
  # and don't want to create a class for callbacks... or can't, perhaps because
  # the list of options isn't known at the time the code is written - dynamically
  # created at runtime, perhaps.
  #
  # Or if you're just going for the quick hack, use this class to provide the
  # selections to put in the lists, and then check the array returned by the
  # +selected+ method to see what was picked.
  class Choices
    attr_reader :members, :selected
    def initialize(*choices)
      @members = []
      @selected = []
      @texts = {}
      g = gensyms("choice_000") # If 3 digits isn't enough, you need a different interface anyway.
      choices.zip(gensyms("choice_000")) {|text, sym|
        @texts[sym] = text
        @members << sym
        define_singleton_method(sym) { ||
          @selected << text_of(sym)
        }
      }
    end

    def text_of(s)
      @texts[s].to_s
    end

    private
    def gensyms(initial = nil)
      Enumerator.new do |y|
        sym = initial || 7.times.map { (65 + rand(26)).chr }.join
        loop do
          y.yield(sym.intern)
          sym.succ!
        end
      end
    end
  end


end
