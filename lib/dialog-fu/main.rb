#!/usr/bin/env ruby

require 'rubygems'
require 'escape'
require 'date'
require 'tempfile'

def run_cmd(cmdline)
  user_input = ""
  IO.popen(cmdline) do |pipe|
    user_input = pipe.read(nil)
  end
  retval = $?.to_i
  user_input.strip!
  return user_input, retval
end

def shell_option(options_hash, symbol)
  unless options_hash[symbol].nil?
    value = options_hash[symbol]
    if block_given?
      retval = yield symbol, value
      if (retval.is_a?(Array) and retval.length == 2)
        "--#{retval[0].to_s}=#{Escape.shell_single_word(retval[1].to_s)} "
      else
        retval
      end
    else
      "--#{symbol.to_s}=#{Escape.shell_single_word(value.to_s)} "
    end
  else
    ""
  end
end

def general_zenity_opts(options = {})
  [:width, :height, :timeout, :title].map {|opt|
    shell_option(options, opt)
  }.join(' ')
end


def calendar(options = {})
  cmd = "zenity --calendar "
  cmd << general_zenity_opts(options)
  
  cmd << " --date-format=\"%Y %m %d\" "
  
  cmd << shell_option(options, :text)

  cmd << shell_option(options, :initial_date) do |sym, date|
    out = ""
    out << " --year " << date.year.to_s if date.respond_to?(:year)
    out << " --month " << date.month.to_s if date.respond_to?(:month)
    out << " --day " << date.mday.to_s if date.respond_to?(:mday)
    out
  end
  
  puts "Running: #{cmd}" if options[:debug] == true
  output, retval = run_cmd(cmd)
  if retval != 0
    return nil
  else
    datelist = output.split(' ').map {|s| s.to_i}
    year, month, day = *datelist
    selected_date = case options[:date].class.to_s
                      when "DateTime"
                        DateTime.new(*datelist)
                      when "Time"
                        Time.local(*datelist)
                      else 
                        Date.new(*datelist)
                      end
    return selected_date
  end
end

def text_entry(options = {})
  cmd = "zenity --entry "
  cmd << general_zenity_opts(options)

  under_to_hyphen = lambda {|symbol, value|
    changed_symbol = symbol.to_s.gsub(/_/, '-')
    [changed_symbol, value]
  }
  
  cmd << shell_option(options, :text)
  cmd << shell_option(options, :entry_text, &under_to_hyphen)
  cmd << shell_option(options, :hide_text, &under_to_hyphen)
  
  puts "Running: #{cmd}" if options[:debug] == true
  output, retval = run_cmd(cmd)
  if retval != 0
    return nil
  else
    return output
  end
end

def dialogbox(options = {})
  cmd = "zenity "
  cmd << shell_option(options, :type) {|sym, val| "--" << val }

  cmd << general_zenity_opts(options)
  
  cmd << shell_option(options, :text)
  cmd << shell_option(options, :no_wrap) {|sym, val| "--no-wrap"}
  
  puts "Running: #{cmd}" if options[:debug] == true
  output, retval = run_cmd(cmd)
  if retval != 0
    return nil
  else
    return output
  end
end

def error(options = {})
  options[:type] = 'error'
  dialogbox(options)
end

def info(options = {})
  options[:type] = 'info'
  dialogbox(options)
end

def warning(options = {})
  options[:type] = 'warning'
  dialogbox(options)
end

def question(options = {})
  cmd = "zenity --question "

  under_to_hyphen = lambda {|symbol, value|
    changed_symbol = symbol.to_s.gsub(/_/, '-')
    [changed_symbol, value]
  }

  cmd << general_zenity_opts(options)
  cmd << shell_option(options, :text)
  cmd << shell_option(options, :no_wrap) {|sym, val| "--no-wrap"}
  cmd << shell_option(options, :ok_label, &under_to_hyphen)
  cmd << shell_option(options, :cancel_label, &under_to_hyphen)
  
  puts "Running: #{cmd}" if options[:debug] == true
  output, retval = run_cmd(cmd)
  if retval != 0
    return :cancel
  else
    return :ok
  end
end

def file_selection(options = {})
  cmd = "zenity --file-selection "
  cmd << general_zenity_opts(options)
  
  separator = "\v"
  multiple = options[:multiple]
  
  unless multiple.nil?
    cmd << shell_option(options, :multiple) {|sym, val| "--multiple"}
    cmd << " --separator=\"#{separator}\" "
  end
  
  cmd << shell_option(options, :filename)
  cmd << shell_option(options, :directory) {|sym, val| "--directory"}
  cmd << shell_option(options, :save) {|sym, val| "--save"}
  cmd << shell_option(options, :confirm_overwrite) {|sym, val| "--confirm-overwrite"}
  cmd << shell_option(options, :file_filter)
  
  puts "Running: #{cmd}" if options[:debug] == true
  output, retval = run_cmd(cmd)
  if retval != 0
    return nil
  else
    output.split(separator)
  end
end

def grid_list(selections, options = {})
  cmd = "zenity --list --print-column=ALL "
  cmd << general_zenity_opts(options)
  
  separator = "\v"
  cmd << " --separator=\"#{separator}\" --print=column=1"
  
  cmd << shell_option(options, :text)
  cmd << shell_option(options, :checklist)
  cmd << shell_option(options, :radiolist)
  cmd << shell_option(options, :multiple)
  cmd << shell_option(options, :editable)

  header_row = selections.shift
  header_row.each {|h|
    cmd << " --column=" << Escape.shell_single_word(h) << " "
    # cmd << shell_option(options, :column) {|key, val| ["--column", h]}
  }

  selections.each {|row|
    row.each {|x|
      cmd << " " << Escape.shell_single_word(x) << " "
    }
  }
  
  puts "Running: #{cmd}" if options[:debug] == true
  output, retval = run_cmd(cmd)
  if retval != 0
    return nil
  else
    output.split(separator)
  end
end

def selection_list(selections, options = {})
  cmd = "zenity --list "
  cmd << general_zenity_opts(options)
  
  separator = "\v"
  cmd << " --separator=\"#{separator}\" "
  unless (options[:checklist].nil? and options[:radiolist].nil?)
    cmd << " --column=\"\" --column=\"\" --print-column=2 "
  else
    cmd << " --column=\"\" "
  end

 unless options[:checklist].nil?
    options[:multiple] = true
  end
  
  cmd << shell_option(options, :text)
  cmd << shell_option(options, :multiple)
  cmd << shell_option(options, :editable)
  cmd << shell_option(options, :checklist)
  cmd << shell_option(options, :radiolist)
  
  selections.each {|s|
    unless (options[:checklist].nil? and options[:radiolist].nil?)
      cmd << " \"\" "
    end
    cmd << " " << Escape.shell_single_word(s)
  }
  
  puts "Running: #{cmd}" if options[:debug] == true
  output, retval = run_cmd(cmd)
  if retval != 0
    return nil
  else
    results = output.split(separator)
    if options[:multiple].nil?
      return results[0]
    else
      return results
    end
  end
end

def textbox(initial_text, options = {})
  cmd = "zenity --text-info "
  cmd << general_zenity_opts(options)
  
  tf = Tempfile.new("zenitytemp")
  tf.puts(initial_text)
  tf.close
    
  cmd << " --filename=" << tf.path << " "
  cmd << shell_option(options, :editable)
  
  puts "Running: #{cmd}" if options[:debug] == true
  output, retval = run_cmd(cmd)
  if retval != 0
    return nil
  else
    return output
  end
end

def range(range, options = {})
  cmd = "zenity --scale "
  cmd << general_zenity_opts(options)

  cmd << " --min-value=" << Escape.shell_single_word(range.begin.to_s) << " "
  cmd << " --max-value=" << Escape.shell_single_word(range.end.to_s) << " "
  
  under_to_hyphen = lambda {|symbol, value|
    changed_symbol = symbol.to_s.gsub(/_/, '-')
    [changed_symbol, value]
  }

  if options[:value].nil?
    cmd << " --value=" << Escape.shell_single_word(range.begin.to_s) << " "
  else
    cmd << shell_option(options, :value)
  end

  cmd << shell_option(options, :text)
  cmd << shell_option(options, :step)
  cmd << shell_option(options, :hide_value, &under_to_hyphen)
  cmd << shell_option(options, :print_partial, &under_to_hyphen)
  
  puts "Running: #{cmd}" if options[:debug] == true
  output, retval = run_cmd(cmd)
  if retval != 0
    return nil
  else
    return output
  end
end

#t = calendar(:width => 480, :title => "Date entry thingie", :text => "Enter some weird date...", :initial_date => DateTime.new(2009,1,1))
#
#puts "Selected: " << t.to_s
#puts "Returned value is a " << t.class.to_s
#
#t = text_entry(:width => 800, :entry_text => "Foo things")
#puts "Returned value: " << t
#
#t = info(:debug => true, :text => "Something you should know about...")
#puts "Returned value: " << t
#
#t = file_selection(:filename => "/home/socket/", :multiple => true)
#t.each {|f| puts f }
#
#t = selection_list(["one", "two", "three"])
#puts t.inspect
#
#t = textbox("Hello, world!\nFine day, isn't it?", :editable => true)
#puts t
#
#t = range(1..10, :debug => true)
#puts t
