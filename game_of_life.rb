require 'colorize'
require 'byebug'
require 'awesome_print'

class Space
  
  class OutOfBound < StandardError
    
    def message
      "argument out of bounds"
    end
  end
  
  attr_accessor :buffer
  
  def initialize(height, width)
    @height = height
    @width = width
    @buffer = create_buffer('O')
    @generation = 0
  end
  
  def print_buffer
    puts @generation
    @buffer.each do |row|
      row.each_with_index do |cell, index|
        if index == 0
          print "|".green
        end
        cell != 'O' ? print(" #{cell}".red) : print(" #{cell}".green)
        print " |".green
        if index == (row.size) - 1
          print "\n"
          print ("----" * row.size).green
          print "\n"
        end
      end
    end
  end
  
  def set(x, y, val)
    if x > @width - 1 || y > @height - 1
      raise OutOfBound
    else
      buffer[x][y] = val
    end
  end
  
  def animate
    puts `clear`
    print_buffer
    sleep 0.5
    while (true)
      puts `clear`
      @buffer = next_generation
      print_buffer
      sleep 0.5
    end
  end
  
  private
  
  def create_buffer(value)
    Array.new(@height) { initialize_row(value) }
  end
  
  def initialize_row(value)
    Array.new(@width) { value }
  end
  
  def set_random
    rand((0..(@height * @width))).times do
      set(rand(0..@width - 1), rand(0..@height - 1), ('A'..'Z').to_a.sample)
    end
  end
  
  def next_generation
    @generation += 1
    result = create_buffer('O')
    @buffer.each_with_index do |row, row_index|
      row.each_with_index do |cell, column_index|
        neighbour_count = live_neighbours_count(row_index, column_index)
        if cell == 'O'
          if neighbour_count == 3
            result[row_index][column_index] = 'X'
          end
        else
          if [2, 3].include? neighbour_count
            result[row_index][column_index] = 'X'
          else
            result[row_index][column_index] = 'O'
          end
        end
      end
    end
    result
  end
  
  def alive?(x, y)
    @buffer[x][y] != 0
  end
  
  def dead?(x, y)
    @buffer[x, y] == 0
  end
  
  def neighbours(x, y)
    apparent_neighbours(x, y).select { |point| in_bounds?(point) }
  end
  
  def live_neighbours_count(x, y)
    neighbours(x, y).select { |i, j| @buffer[i][j] != 'O' }.count
  end
  
  def apparent_neighbours(x, y)
    [[x - 1, y - 1], [x, y - 1], [x + 1, y - 1], [x - 1, y], [x + 1, y], [x - 1, y + 1], [x, y + 1], [x + 1, y + 1]]
  end
  
  def in_bounds?(point)
    x = point[0]
    y = point[1]
    !(x < 0 || y < 0 || x > @width - 1 || y > @height - 1)
  end

end

space = Space.new(3, 3)
space.set(0, 1, 'X')
space.set(1, 1, 'X')
space.set(2, 1, 'X')

space.animate
