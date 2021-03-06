#!/usr/bin/env ruby

require_relative '../lib/dialog'
require 'pry'

Dialog.autosetup  # Figure out what implementation to use

FoodChoices = Struct.new(:sandwich, :soup, :salad)

class DialogTests
  attr_reader :members
  def initialize()
    @tests = {dialogbox_return: "Dialog Box return value",
              dialogbox_block: "Dialog Box with block",
              dialogbox_cancelable: "Dialog Box with cancel button",
              dialogbox_warning: "Dialog Box in warning style",
              dropdown_return: "Dropdown return value",
              messagebox_normal: "Normal message box",
              messagebox_badarg: "Message box with invalid argument",
              messagebox_sorry: "Message box in 'sorry' style",
              messagebox_error: "Message box in 'error' style",
              checkboxes_yield: "Checkboxes with block",
              checkboxes_choices: "Checkboxes with the Choices class",
              inputtest: "Input box",
              input_largetest: "Larger input box",
              }
    @members = @tests.keys
  end

  def text_of(sym)
    @tests[sym]
  end

  def dialogbox_return
    retval = Dialog.dialogbox("Hello, world.")
    puts "Return value is: #{retval.inspect}"
  end

  def dialogbox_block
    Dialog.dialogbox("Hello, world.") {|| puts "I concur!"}
    puts "You should have seen 'I concur!' if you pressed 'ok'"
  end

  def dialogbox_cancelable
    retval = Dialog.dialogbox("You can cancel this.", cancel: true)
    puts "#{retval.inspect} - false if you pressed cancel."
  end

  def dialogbox_warning
    retval = Dialog.dialogbox("This should be a warning box", warning: true)
    puts "#{retval.inspect} - true if you pressed Yes, false otherwise."
  end

  def dropdown_return
    fc = FoodChoices.new()
    retval = Dialog.dropdown(fc)
    puts "Choices object is: #{fc.inspect}"
    puts "#{retval.inspect} - true if you chose something, false otherwise."
  end

  def messagebox_normal
    retval = Dialog.messagebox("Fact: kittens are cute")
    puts "#{retval.inspect} - should be true, unless something strange happened"
  end

  def messagebox_badarg
    begin
      retval = Dialog.messagebox("Fact: kittens are cute", type: :foo)
    rescue ArgumentError
      puts "Properly caught an argument error for using the wrong type."
    end
  end

  def messagebox_sorry
    Dialog.messagebox("Oops.", type: :sorry)
  end

  def messagebox_error
    Dialog.messagebox("Error! On purpose, so it's not really", type: :error)
  end

  def checkboxes_yield
    fc = FoodChoices.new()
    retval = Dialog.checkboxes(fc, label: "Choose some food!") {|c|
      puts "You checked #{c}"
    }
    puts "You should've seen a 'You checked x' line for each thing you checked."
  end

  def checkboxes_choices
    c = Dialog::Choices.new("soup", "salad", "sandwich")
    Dialog.checkboxes(c, label: "Choose some food!")
    puts "You checked:\n"
    puts c.selected.join("\n")
  end

  def inputtest
    input = Dialog.inputbox(prompt: "What did you have for lunch?")
    puts "You entered:"
    puts input
  end

  def input_largetest
    input = Dialog.inputbox(prompt: "Write a couple lines:", height: 2)
    puts "You entered:"
    puts input
  end
end

tests = DialogTests.new
while Dialog.radiobuttons(tests, label: "Choose a test")
  # Nothing in particular needed here.
end

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

#fs = Struct.new(:sandwich, :soup, :salad).new()
#Dialog.checkboxes(fs, label: "What'll it be?")
#puts fs.inspect

#Dialog.calendar() {|date|
#  puts "The day of week for #{date} is #{Date::DAYNAMES[date.wday]}"
#}
#day = Dialog.calendar()
#puts "The day of week for #{day} is #{Date::DAYNAMES[day.wday]}"

#n = Dialog.slider(label: "Pick a number", range: 1..25 ) #  {|n| puts "You chose #{n}" }
#puts "You chose #{n}"


