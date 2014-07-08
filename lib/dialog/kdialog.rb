require 'open3'
require 'tempfile'

module Dialog::KDialog

  # Standard dialog boxes
  # 
  # The valid combinations of boolean parameters specifying the type of buttons available are as follows:
  #
  # [cols="4"]
  # |===
  # |*YesNo*
  # |*Cancel*
  # |*Warning*
  # |*Continue*
  #
  # | true
  # | true
  # | true
  # | false
  #
  # | true
  # | true
  # | false
  # | false
  #
  # | true
  # | false
  # | false
  # | false
  #
  # | true
  # | false
  # | true
  # | false
  #
  # | false
  # | true
  # | true
  # | true
  # |===
  #
  # @param text [String] The text presented to the user above buttons.
  # @param yesno [Boolean] If true, show "Yes" and "No" buttons.
  # @param cancel [Boolean] If true, show a "Cancel" button.
  # @param continue_btn [Boolean] If true, show a "Continue" button.
  # @param warning [Boolean] If true, the icon shown is a warning icon, not a standard question icon
  # @yield [] If the user makes a positive selection (yes or continue), the given
  #   block is called.  If not, the block is ignored.
  def dialogbox(text, yesno: true, cancel: false, continue_btn: false, warning: false)
    valid_dialogs = {"warningyesnocancel" => true, "yesnocancel" => true,
                     "yesno" => true, "warningyesno" => true,
                     "warningcontinuecancel" => true}
    cmd = ""
    cmd += "warning" if warning == true
    cmd += "yesno" if yesno == true
    cmd += "continue" if continue_btn == true
    cmd += "cancel" if cancel == true
    unless valid_dialogs.has_key?(cmd)
      raise "Can't make that kind of dialog box"
    end
    cmd = "--#{cmd}"
    out, status = *run([cmd, text])
    if block_given? and status == true
      yield()
    end
  end

  # A message box, for displaying a little text to the user.  
  # For longer, multi-line text, you may prefer to use #textbox.
  # Contrasting with the standard dialog boxes, the button presented to the user
  #   only has the effect of closing the box.
  #
  # @param type [:msgbox :sorry :error] The type of message box, affects the choice of icon shown in the box
  # @!macro [new] runreturn
  #   @return [Array<(String, Boolean)>]  the textual output of running kdialog, and whether it exited successfully
  def messagebox(text, type: :msgbox)
    unless {:msgbox => 1, :sorry => 1, :error => 1}.has_key?(type)
      raise "Can't make that kind of message box"
    end
    cmdtype = "--#{type}"
    run([cmdtype, text])
  end

  # A window for showing the user a large amount of text, potentially using
  # horizontal and vertical scrollbars.  For small amounts of text, use #messagebox
  #
  # @param text [String IO] The text to send to the user, or a readable IO object.
  # @param height [Integer] The height of the textbox area, defaults to 10
  # @param width [Integer] The width of the textbox area, defaults to 40
  # @macro runreturn
  def textbox(text, height: 10, width: 40)
    Tempfile.open('dialogfu') do |tf|
      if text.respond_to?(:read)
        tf.print(text.read)
      else
        tf.print(text)
      end
      tf.close
      run(["--textbox", path, "--height", height, "--width", width])
      tf.unlink
    end
  end

  # Present an input box.  It may be a one-line field, a password field, or a larger text-entry area potentially with scrollbars.
  #
  # @param prompt [String] The text to prompt the user, above the input fields
  # @param content [String] The initial value in the input box
  # @param height [Integer] The height of the input field.  If 1, presents a single-line input field.
  #   If larger, presents a text box that can potentially scroll vertically and horizontally.  Defaults to 1
  # @param width [Integer] The width of the input field.  Note that this does not limit the amount of text
  #   the user may return, only how much can be seen on the screen at once.
  # @param password [Boolean] When true, use a 'key' icon and only show dots in place of input characters.
  #   When this is true, the height parameter is required to be 1, otherwise this option has no effect.
  # @yieldparam input [String] the text provided by the user
  # @macro runreturn
  def inputbox(prompt: "Input some text", content: nil, height: 1, width: 40, password: false, &blk)
    if height == 1
      if password == true
        cmd = ["--password"]
      else
        cmd = ["--inputbox"]
      end
    elsif height > 1
      cmd = ["--textinputbox"]
    end
    cmd << prompt
    if password == false
      cmd << content if content
      if height > 1
        cmd += ["--height", height]
      end
      cmd += ["--width", 40]
    end

    run(cmd, &blk)
  end

  # @!macro [new] labelparam
  #   @param label [String] The text to display above input fields
  # @!macro [new] choiceparam
  #   @param choices [#members] An object with an attribute for each choice, and a +#members+ method which
  #     returns a list of those attributes to be used.

  # A dropdown box
  #
  # This is similar to a radio button selection; only one selection can be made.
  #
  # @macro choiceparam
  # @macro labelparam
  #
  def combobox(choices, label: "")
    cmd = ["--combobox", label] + choices.members.map {|k| k.to_s}
    run(cmd) {|sel|
      selected = (sel + '=').to_sym
      (choices.members - [selected]).each {|c| choices.send((c.to_s + '=').to_sym, false)}
      choices.send(selected, true)
    }
  end

  # Present a set of checkboxes to the user
  #
  # Using this method may be easier than using #selection, as you don't need to indicate you want checkboxes.
  #
  # @macro choiceparam
  # @macro labelparam
  # @!macro [new] defaultparam
  #   @param default [Array<String> String] The name of the attribute to be pre-selected for the user,
  #     or a list of such names, in the case of checkboxes.  If not provided, the attribute's value is
  #     tested, and if true, is selected.
  # @example Using a Struct for checkboxes
  #   Foodselection = Struct.new(:salad, :soup, :sandwich, :cookie, :drink)
  #   choices = Foodselection.new(false, false, true, false, true)  # sandwich and drink preselected
  #   checkboxes(choices, label: "What would you like for lunch?")
  # @macro runreturn
  #
  def checkboxes(choices, label: "", default: nil)
    selection(choices, label: label, type: :check, default: default)
  end

  # Present a set of radio buttons to the user
  #
  # Using this method may be easier than using #selection, as you don't need to indicate you want radio buttons.
  # 
  # @macro choiceparam
  # @macro labelparam
  # @macro defaultparam
  # @macro runreturn
  # @note It's the caller's responsibility to either specify a default,
  #   or make sure only one of the 'choices' attributes is true in the +choices+ parameter.
  def radiobuttons(choices, label: "", default: nil)
    selection(choices, label: label, type: :radio, default: default)
  end

  # Implementation of radiobuttons and checkboxes; user selections.
  #
  # @macro choiceparam
  # @macro labelparam
  # @macro defaultparam
  # @param type [Symbol] Either :check (for checkboxes, multiple selections allowed) or :radio, (for
  #   radio buttons, only one selection)
  # @raise UnknownSelectionType If type is something other than :check or :radio
  # @macro runreturn
  # @note If +type+ is +:radio+, it's the caller's responsibility to either specify a default,
  #   or make sure only one of the 'choices' attributes is true in the +choices+ parameter.
  def selection(choices, label: "", type: :check, default: nil)
    cmd = ["--separate-output"]
    cmd << case type
    when :check
      "--checklist"
    when :radio
      "--radiolist"
    else
      raise UnknownSelectionType, "Unknown selection type", caller
    end
    cmd << label
    choices.members.each_with_index {|c, i|
      if ((default.nil? and choices.send(c)) or (default == c) or (default.include?(c)))
          cmd += [i.to_s, c.to_s, 'on']
      else
        cmd += [i.to_s, c.to_s, 'off']
      end
    }
    run(cmd) do |sel|
      selected = sel.each_line.map{|l| l.chomp.to_i}
      choices.members.each.with_index do |box, i|
        method = (box.to_s + '=').to_sym
        if selected.include?(i)
          choices.send(method, true)
        else
          choices.send(method, false)
        end
      end
    end
  end

  # Raise a notification for the user. This doesn't bring up a window that takes focus,
  # just a little box (usually above the taskbar) in the notification area that goes away by itself.
  #
  # @param text [String] The text to show in the notification
  # @param timeout [Integer] The number of seconds to show the notification for
  def notification(text, timeout: 3)
    run(["--passivepopup", text, timeout.to_s])
  end

  # Present a file-picker box, for getting filenames or URLs from the user, for saving or opening.
  # 
  # @param action [Symbol] One of :save or :open
  # @param type [Symbol] One of :url, :file, or :directory, indicating what kind of input is expected from the user
  # @param dir [String] Directory to start the UI in, defaults to ENV['HOME']
  # @param multiple [Boolean] If true, allow the user to select multiple files. Only works when action is :open.
  # @param filter [String] A description of what types of files should be displayed in directory listings
  # @yieldparam path [Array<String> String] The path (or paths) selected by the user
  # @return [Array<String> String] The path (or paths) selected by the user
  # @todo Figure out what kinds of strings are expected of the filter parameter, write code to validate
  def filepicker(action: :save, type: :file, dir: ENV['HOME'], multiple: false, filter: nil, &blk)
    cmd = ["--separate-output"]
    cmd << "--multiple" if (multiple and action == :open)
    cmd << case [action, type]
    when [:save, :file]
      "--getsavefilename"
    when [:save, :url]
      "--getsaveurl"
    when [:open, :file]
      "--getopenfilename"
    when [:open, :url]
      "--getopenurl"
    else
      if type == :directory
        "--getexistingdirectory"
      end
    end
    cmd << dir
    cmd << filter unless (type == :directory or filter.nil?)
    if block_given?
      run(cmd) do |input|
        if multiple
          param = input.split(/\n/)
        else
          param = input
        end
        yield(param)
      end
    else
      input, status = run(cmd)
      if multiple
        input.split(/\n/)
      else
        input
      end
    end
  end

  # Icon Picker
  #
  # Allows the user to choose an icon among those available to KDE.
  #
  # @macro runreturn
  def icon()
    run(["--geticon", "--help"])
  end

  # @todo Design and implement API for using progressbar
  def progressbar()
    require 'dbus' unless DBus
    steps = 10
    out, status = Open3.capture2("kdialog", "--progressbar", "Titlebar Text", steps.to_s)
    if status != 0
      raise "kdialog exited unexpectedly"
    end
    servicename, path = *out.split(/\s+/)

    bus = DBus::SessionBus.instance
    dialogservice = bus.service(servicename)
    dialogobj =  dialogservice.object(path)
    d = dialogobj["org.kde.kdialog.ProgressDialog"]

    d.showCancelButton(true) # or false...
    r = d.wasCancelled
    r.first # the boolean.  Why it's in an array? Dunno.
    d["maximum"] # => 10
    d["autoClose"] # => false, by default
    d.setLabelText("Test")
    d["value"] # Can be assigned! Yay!  Ignored if out of range.
    d.close # When done!
  end

  # @api private
  # @param arglist [Array<String>] List of command-line arguments for kdialog
  # @raise [StandardError] Any exception raised by Open3#capture2
  # @yieldparam output [String] The output of running kdialog
  # @macro runreturn
  def run(arglist, &blk)
    cmd = ["kdialog"] + arglist
    output, code = Open3.capture2(*cmd)
    status = case code.exitstatus
             when 0 then true
             when 1 then false
             else false
             end
    if block_given? and status == true
      yield(output.chomp)
    end
    return output.chomp, status
  end
end
