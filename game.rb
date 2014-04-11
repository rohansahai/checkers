require "./board.rb"

class Game
  attr_accessor :board, :current_player
  
  TURN = {:red => :black, :black => :red} 
  NAV = { 'j' => [-1, 0], 'k' => [0, 1], 'l' => [1, 0], 'i' => [0, -1] } 
  
  def initialize
    @board = Board.new
    @current_player = :red
  end
  
  def run
    
    until @board.over?
      system("clear")
      @board.render
      begin
        start_pos, move_sequence = get_input
        @board[start_pos.first].perform_moves(move_sequence, current_player)
        @current_player = TURN[@current_player]
      rescue InvalidMoveError
        puts "You can't do that"
        retry
      rescue NachYoPeaceError
        puts "That's nach yo peaccce!"
        retry
      end
    end
    
  end
  
  def get_input
    puts "What piece would you like to move you silly user?"
    start_pos = gets.chomp
    puts "Where would you like to move it? (you may put in multiple spots for multi jumps)"
    end_pos = gets.chomp
    [parse_input(start_pos), parse_input(end_pos)]
  end
  
  def parse_input(move_sequence)
    move_sequence = move_sequence.gsub(/\D/, '').split("")
    moves = []
    move_sequence.each_index do |idx|
      next if idx.odd?
      moves << [move_sequence[idx].to_i, move_sequence[idx + 1].to_i]
    end
    moves
  end
  
  def space_picker

    loop do
      @board.render
      
      begin
        system("stty raw -echo")
        str = STDIN.getc
      ensure
        system("stty -raw echo")
      end

      system("clear")

      case str
      when ' '
        return @board.cursor_pos
      end
      
      if NAV.include?(str)
        new_x = @board.cursor_pos[0] + NAV[str].first
        new_y = @board.cursor_pos[1] + NAV[str].last
        unless @board.off_board?([new_x, new_y])
          @board.cursor_pos = [new_x, new_y]
        end
      end
    end
    
  end
  
end

new_game = Game.new
new_game.run