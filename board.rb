require "./piece.rb"
require 'colorize'
class Board
  attr_accessor :spaces, :pieces
  
  OPP_COLOR = {:red => :black, :black => :red}
  
  def initialize(options = {})
    @spaces = Array.new(8) { Array.new(8) }
    @pieces = {:red => [], :black => []}
    populate_board unless options[:empty]
  end
  
  def populate_board
    rows = [0, 1, 2, 5, 6, 7]
    
    rows.each do |row|
      0.upto(7) do |col|
        if row.even? && col.even?
          @spaces[row][col] = Piece.new([col, row], self, :black) if row < 3
          @spaces[row][col] = Piece.new([col, row], self, :red) if row > 3
        elsif row.odd? && col.odd?
          @spaces[row][col] = Piece.new([col, row], self, :black) if row < 3
          @spaces[row][col] = Piece.new([col, row], self, :red) if row > 3
        end
      end
    end
    nil
  end
  
  def is_empty?(pos)
    @spaces[pos.last][pos.first] == nil ? true : false
  end
  
  def valid_pos?(pos)
    on_board = (0..7).to_a
    if on_board.include?(pos.first) && on_board.include?(pos.last)
      return true
    end
    false
  end
  
  def [](pos)
      raise "invalid pos" unless valid_pos?(pos)
      i, j = pos
      @spaces[j][i]
    end
  
  def []=(pos, piece)
    @spaces[pos.last][pos.first] = piece
  end
  
  def render
    print "  "
    puts (0..7).to_a.join(" ")
    @spaces.each_with_index do |row, i|
      print "#{i} "
      row.each do |col|
        if col == nil
          print "* ".yellow
        elsif col.king == true
          print "K "
        elsif col.color == :black
          print "B ".blue
        elsif col.color == :red
          print "R ".red
        end
      end
      puts ""
    end
  end
  
end

new_board = Board.new
new_board[[0,2]].perform_moves("1,3")
new_board[[3,5]].perform_moves("2,4")
new_board[[4,6]].perform_moves("3,5")
new_board[[3,5]].perform_moves("4,4")
new_board[[5,7]].perform_moves("4,6")
new_board[[1,3]].perform_moves("3,5 5,7 4,6")
# new_board[[0,2]].perform_slide([1,3])
# new_board[[3,5]].perform_slide([2,4])
# new_board[[1,3]].perform_jump([3,5])
# new_board[[4,6]].perform_jump([2,4])
# new_board[[2,4]].king = true
# new_board[[2,4]].perform_slide([4,5])
#new_board[[2,4]].perform_jump([1,3])

new_board.render
