#!/usr/bin/env ruby

require_relative '../lib/dialog'
require 'pry'

Dialog.autosetup  # Figure out what implementation to use
  
#Dialog.dialogbox("Hello, world.")
#dialogbox("You can cancel this", cancel: true)
#dialogbox("This is a warning", warning: true)
#dialogbox("Are you quite sure?", warning: true, cancel: true, continue_btn: true, yesno: false)
#Dialog.messagebox("Just so you know,")
#messagebox("oops", type: :sorry)
#messagebox("Uhoh", type: :error)
#textbox("Something to read...")
#file = Dialog.filepicker(action: :open, multiple: true)
#puts "You chose: #{file.inspect}"
Dialog.notification("Hello, world.")

#colorchoice = Struct.new(:blue, :green, :red, :black)
#opts = colorchoice.new(false, false, true, false)
#radiobuttons(opts, label: "Choose a color", default: :blue)

