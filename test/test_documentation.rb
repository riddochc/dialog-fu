#!/usr/bin/env ruby

require_relative '../lib/dialog'
require 'pry'

Dialog.autosetup  # Figure out what implementation to use

class FoodShop
  attr_reader :members, :default

  def initialize(default)
    @members = [:sandwich, :soup, :salad]
    @default = default
  end

  def text_of(s)
    {sandwich: "Sandwich", soup: "Soup of the day", salad: "Garden Salad"}[s]
  end

  def sandwich()
    puts "Making a sandwich"
  end

  def soup()
    soups = %w{Tomato Cheese Tortilla}
    puts "Making a bowl of #{soups.sample}"
  end

  def salad()
    puts "Making a salad"
  end
end

fs = FoodShop.new(:sandwich)
Dialog.checkboxes(fs, label: "What'll it be?") {|food|  # Suppose the user selects soup and salad
  puts "You mean a #{food.inspect}?"
}
### This prints:
#    # You mean a :soup?
#    # You mean a :salad?

