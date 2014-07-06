#!/usr/bin/env ruby

require_relative '../lib/dialog'
require 'pry'

include Dialog::KDialog
  
dialogbox("Hello, world.")
dialogbox("You can cancel this", cancel: true)
dialogbox("This is a warning", warning: true)
dialogbox("Are you quite sure?", warning: true, cancel: true, continue_btn: true, yesno: false)
messagebox("Just so you know,")
messagebox("oops", type: :sorry)
messagebox("Uhoh", type: :error)

textbox("Something to read...")

colorchoice = Struct.new(:blue, :green, :red, :black)
opts = colorchoice.new(false, false, true, false)
radiobuttons(opts, label: "Choose a color", default: :blue)

