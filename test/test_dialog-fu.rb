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
#Dialog.notification("Hello, world.")
#puts Dialog.color().inspect

#Dialog.progressbar(steps: 10) {|pb|
#  binding.pry
#}
#  0.upto(25) {|i|
#    n = i*4
#    pb.set(n)
#    if n.between?(0,25)
#      pb.label("Getting started")
#    elsif n.between?(25,75)
#      pb.label("In the middle of working...")
#    elsif n.between?(75,99)
#      pb.label("Finishing up...")
#    end
#    sleep 0.5
#  }
#}
#puts "Done!"

#colorchoice = Struct.new(:blue, :green, :red, :black)
#opts = colorchoice.new(false, false, true, false)
#radiobuttons(opts, label: "Choose a color", default: :blue)

#class FoodShop
#  attr_reader :members, :default
#
#  def initialize(default)
#    @members = [:sandwich, :soup, :salad]
#    @default = default
#  end
#
#  def text_of(s)
#    {sandwich: "Sandwich", soup: "Soup of the day", salad: "Garden Salad"}[s]
#  end
#
#  def sandwich()
#    puts "Making a sandwich"
#  end
#
#  def soup()
#    soups = %w{Tomato Cheese Tortilla}
#    puts "Making a bowl of #{soups.sample}"
#  end
#
#  def salad()
#    puts "Making a salad"
#  end
#end

fs = Struct.new(:sandwich, :soup, :salad).new()
Dialog.radiobuttons(fs, label: "What'll it be?")
puts fs.inspect
