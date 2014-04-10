class Piece
  attr_accessor :position, :board, :color, :king
  
  def initialize(position, board, color, king = false)
    @position = position
    @board = board
    @color = color
    @king = king
  end
  
  def forward_dir
    (color == :red) ? -1 : 1
  end
  
  def find_valid_slides
    i, j = self.position
    valid_slides = [[i + 1, j + forward_dir], [i - 1, j + forward_dir]]
    
    if self.king
      valid_slides += [[i + 1, j - forward_dir]] + [[i - 1, j - forward_dir]]
    end

    moves = valid_slides.select do |slide_pos|
      board.valid_pos?(slide_pos) && board.is_empty?(slide_pos)
    end
  end
  
  def find_valid_jumps
    moves = []
    enemy_pos = [] #this one is to return
    i, j = self.position
    valid_jumps = [[i + 2, j + forward_dir*2], [i - 2, j + forward_dir*2]]
    enemy_positions = [[i + 1, j + forward_dir], [i - 1, j + forward_dir]]
    
    if self.king
      valid_jumps += [[i + 1, j - forward_dir*2]] + [[i - 1, j - forward_dir*2]]
      enemy_positions += [[i + 1, j - forward_dir]] + [[i - 1, j - forward_dir]]
    end
    
    valid_jumps.each_with_index do |jump_pos, idx|
      if board.valid_pos?(jump_pos) && is_enemy?(enemy_positions[idx])
        moves << jump_pos
        enemy_pos << enemy_positions[idx]
      end
    end
    [moves, enemy_pos]
  end
  
  def perform_slide(pos)
    if find_valid_slides.include?(pos)
      move_piece(pos)
    else
      raise InvalidMoveError
    end
  end
  
  def perform_jump(pos)
    valid_jumps, enemy_pos = find_valid_jumps
    if valid_jumps.include?(pos)
      idx = valid_jumps.index(pos)
      move_piece(pos, enemy_pos[idx])
    else
      raise InvalidMoveError
    end
  end
  
  def is_enemy?(pos)
    if !@board.is_empty?(pos) && @board[pos].color != self.color
      return true
    end
    false
  end
  
  #Delete when jump?
  def move_piece(pos, enemy_pos = nil)
    @board[position] = nil  #set old spot to empty
    @position[0] = pos.first  #update pieces location
    @position[1] = pos.last
    @board[pos] = self  #update board with new piece
    
    if enemy_pos !=nil
      @board[enemy_pos] = nil
    end
    maybe_promote(pos)
  end
  
  def maybe_promote(pos)
    (self.color == :black) ? king_row = 7 : king_row = 0
    if pos.last == king_row
      self.king = true
    end
  end
  
  def perform_moves(move_sequence)
    moves_array = parse_move_sequence(move_sequence)
    if valid_move_seq?(moves_array)
      perform_moves!(moves_array)
    end
  end
  
  def valid_move_seq?(moves_array)
    new_board = @board.dup_board
    begin
      new_board[@position].perform_moves!(moves_array)
    rescue InvalidMoveError
      puts "Invalid Sequence"
      return false
    end
    true
  end
  
  def perform_moves!(moves_array)
    moves_array.each_with_index do |move, idx|
      if (move.first - @position.first).abs > 1
        perform_jump(move)
      else
        break if idx > 0
        perform_slide(move)
        break
      end
    end
    
  end
  
  def parse_move_sequence(move_sequence)
    move_sequence = move_sequence.gsub(/\D/, '').split("")
    moves = []
    move_sequence.each_index do |idx|
      next if idx.odd?
      moves << [move_sequence[idx].to_i, move_sequence[idx + 1].to_i]
    end
    moves
  end
  
end

class InvalidMoveError < RuntimeError
end

# x = Piece.new([5,5], nil, :black) # 4,6  6,6   - 3, 7  7,7
# p x.valid_slides