require "./board.rb"

class Game
  attr_accessor :board, :current_player, :moves
  
  TURN = {:red => :black, :black => :red} 
  NAV = { 'j' => [-1, 0], 'k' => [0, 1], 'l' => [1, 0], 'i' => [0, -1] } 
  
  def initialize
    @board = Board.new
    @current_player = :red
    @move = {:coordinates => [0,0], :crunch => false}
    @moves = []
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
  
  def run_new
    until @board.over?
      begin
        system("clear")
        @board.render
        puts "#{@current_player}, do ya dayam turn!"
        
        if @move[:crunch] && moves.length > 1
          do_the_move(moves)
          reset_defaults
          system("clear")
          @board.render
        end
        
        get_move
        
        
      rescue PickSpace
        @moves << @board.cursor_pos
      rescue EndSpace
        @moves << @board.cursor_pos
        @move[:crunch] = true
      rescue InvalidMoveError
        puts "You can't do that"
        reset_defaults
        retry
      rescue NachYoPeaceError
        puts "That's nach yo peaccce!"
        reset_defaults
        retry
      end
    end
  end
  
  def do_the_move(moves)
    
    start_pos = moves.shift
    start_pos = [start_pos[1], start_pos[0]]
    seq_moves = []
    
    @moves.each do |move|
      seq_moves << [move[1], move[0]]
    end
    raise InvalidMoveError if @board[start_pos].nil?
    @board[start_pos].perform_moves(seq_moves, @current_player)
    @current_player = TURN[@current_player]
  end
  
  def reset_defaults
    @move[:crunch] = false
    @moves = []
  end
  
  def get_char
    # Thanks to Jeff Fidler who thanked --> http://stackoverflow.com/questions/8142901/ruby-stdin-getc-does-not-read-char-on-reception
    begin
      system("stty raw -echo")
      str = STDIN.getc
    ensure
      system("stty -raw echo")
    end
    str.chr
  end
  
  def get_move
    print "\nUse i,j,k,l to steer the cursor. Use z to pick the checker you would like to move."
    print"\nUse the space bar to select a position to move your piece."
    print"\nYou can use z to select multiple spaces, and then space to multi jump!"
    print"\nIf you do something you are not allowed it is the next player's turn. Unforgivable!"
    command = get_char
    case command
    when ' '
      raise EndSpace
    when 'z'
      raise PickSpace
    when 'q'

    else
      @board.move_cursor(command)
      return nil
    end

    move[:coordinates] = @board.cursor_pos
  end
  
end

class PickSpace < RuntimeError
end

class EndSpace < RuntimeError
end

new_game = Game.new
new_game.run_new