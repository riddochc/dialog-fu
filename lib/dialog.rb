module Dialog
  VERSION='0.2.1'
end

require 'date'
require_relative "dialog/dialog"
require_relative "dialog/kdialog"
require_relative "dialog/zenity"
require_relative "dialog/yad"
require_relative "dialog/cocoadialog"
require_relative "dialog/main" # needs to be loaded last, so things can be imported properly.
