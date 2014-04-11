require "./piece.rb"
require 'colorize'
class Board
  attr_accessor :spaces, :pieces, :cursor_pos
  
  CURSOR = "$$".blink.blue.on_cyan
  OPP_COLOR = {:red => :black, :black => :red}
  
  def initialize(options = {})
    @spaces = Array.new(8) { Array.new(8) }
    populate_board unless options[:empty]
    @cursor_pos = [0, 0]
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
    self[pos].nil?
  end
  
  def valid_pos?(pos)
    on_board = (0..7).to_a
    on_board.include?(pos.first) && on_board.include?(pos.last)
  end
  
  def [](pos)
    raise InvalidMoveError unless valid_pos?(pos)
    i, j = pos
    @spaces[j][i]
  end
  
  def []=(pos, piece)
    @spaces[pos.last][pos.first] = piece
  end
  
  def dup_board
    dup_board = Board.new(empty: true)
    pieces.each do |piece|
      new_piece = Piece.new(piece.position.dup, dup_board, piece.color, piece.king)
      dup_board.add_piece(new_piece, piece.position)
    end
    dup_board
  end
  
  def add_piece(new_piece, pos)
    self[pos] = new_piece
  end
  
  def pieces
    @spaces.flatten.compact
  end
  
  def over?
    !(pieces_left?(:red) || pieces_left?(:black))
  end
  
  def pieces_left?(color)
    @spaces.flatten.compact.any? do |piece|
      piece.color == color
    end
  end
  
  def render
    square_color = :black
    print "  "
    puts (0..7).to_a.join(" ")
    @spaces.each_with_index do |row, i|
      print "#{i} "
      row.each_with_index do |col, j|
        if @cursor_pos == [i,j]
          print CURSOR
        elsif col == nil
          print "_ ".yellow.colorize(:background => square_color)
        elsif col.king == true
          print "K ".yellow.colorize(:background => square_color)
        elsif col.color == :black
          print "B ".white.colorize(:background => square_color)
        elsif col.color == :red
          print "R ".red.colorize(:background => square_color)
        end
        square_color = OPP_COLOR[square_color]
      end
      puts ""
      square_color = OPP_COLOR[square_color]
    end
  end
  
  def move_cursor(command_key)
      new_location = @cursor_pos.dup
      case command_key
      when 'i'
        new_location[0] -= 1
      when 'j'
        new_location[1] -= 1
      when 'k'
        new_location[0] += 1
      when 'l'
        new_location[1] += 1
      end
      @cursor_pos = new_location
    end
  
end