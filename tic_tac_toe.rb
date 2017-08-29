class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def current_winning_moves
    winning_moves = []
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      markers = squares.select(&:marked?).collect(&:marker)
      if two_identical_markers?(markers)
        empty_square = line.select { |i| @squares[i].unmarked? }
        winning_moves << {
          marker: markers.first,
          empty_square: empty_square.first
        }
      end
    end
    winning_moves
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end

  def two_identical_markers?(markers)
    return false if markers.size != 2
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = " "

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  attr_accessor :points
  attr_reader :marker, :name, :reset

  def initialize
    self.points = 0
  end

  def reset
    self.points = 0
  end
end

class HumanPlayer < Player
  def initialize
    @marker = initalize_marker
    @name = initalize_name
    super
  end

  def initalize_marker
    player_marker = nil
    loop do
      puts "Please enter your marker."
      player_marker = gets.chomp
      break if valid_marker?(player_marker)
      puts "Sorry, invalid choice."
    end
    player_marker
  end

  def valid_marker?(marker)
    marker != " " &&
      marker.length == 1
  end

  def initalize_name
    player_name = nil
    loop do
      puts "Please enter your name."
      player_name = gets.chomp.strip
      break unless blank?(player_name)
      puts "Sorry, invalid choice."
    end
    player_name
  end

  def blank?(string)
    string.chars.all? { |c| c == " " }
  end
end

class ComputerPlayer < Player
  POSSIBLE_MARKERS = ['X', 'O', '*', '@']
  POSSIBLE_NAMES = ['Stanley', 'Guy Bro', 'Mr. Robot']

  def initialize
    @marker = initalize_marker
    @name = initalize_name
    super
  end

  def initalize_marker
    POSSIBLE_MARKERS.sample
  end

  def initalize_name
    POSSIBLE_NAMES.sample
  end
end

class TTTGame
  FIRST_PLAYER = 'human'
  WINNING_SCORE = 5
  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = HumanPlayer.new
    loop do
      @computer = ComputerPlayer.new
      if @computer.marker != @human.marker &&
         @computer.name != @human.name
        break
      end
    end
    @current_marker = first_player.marker
  end

  def first_player
    case FIRST_PLAYER
    when 'human' then @human
    when 'computer' then @computer
    end
  end

  def play
    clear
    display_welcome_message

    loop do
      display_board

      loop do
        play_round
        break if match_complete?
      end

      display_match_result
      break unless play_again?
      reset_match
      display_play_again_message
    end

    display_goodbye_message
  end

  private

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_board
    puts "You're a #{human.marker}. Computer is a #{computer.marker}."
    puts ""
    board.draw
    puts ""
  end

  def play_round
    play_one_round
    update_score
    display_round_result
    sleep(1.5)
    reset_round
    display_score
  end

  def play_one_round
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board
    end
  end

  def update_score
    if board.winning_marker == human.marker
      human.points += 1
    else
      computer.points += 1
    end
  end

  def display_round_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "#{human.name} won!"
    when computer.marker
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def reset_round
    board.reset
    @current_marker = first_player.marker
    clear_screen_and_display_board
  end

  def display_score
    puts "Here is the current match score:"
    puts "#{human.name} has #{human.points}."
    puts "#{computer.name} has #{computer.points}."
  end

  def match_complete?
    winning_player
  end

  def display_match_result
    puts "#{winning_player.name} won the match!"
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if ['y', 'n'].include? answer
      puts "Sorry, must be y or n"
    end

    answer == 'y'
  end

  def reset_match
    board.reset
    human.reset
    computer.reset
    @current_marker = first_player.marker
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def winning_player
    return human if human.points >= WINNING_SCORE
    return computer if computer.points >= WINNING_SCORE
    nil
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def verbose_join(array)
    case array.length
    when 1 then array[0].to_s
    when 2 then "#{array[0]} or #{array[1]}"
    else "#{array[0..-2].join(', ')}, or #{array[-1]}"
    end
  end

  def human_moves
    square_choices = verbose_join(board.unmarked_keys)
    puts "#{@human.name} please choose a square (#{square_choices}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def computer_moves
    puts "Now it's #{computer.name}'s turn."
    sleep(1.5)
    case move_choice
    when 'offense' then computer_offense_ai
    when 'defense' then computer_defense_ai
    else computer_random_move
    end
  end

  def move_choice
    markers = board.current_winning_moves.map do |winning_row|
      winning_row[:marker]
    end
    return 'offense' if markers.include? computer.marker
    return 'defense' if markers.include? human.marker
    'random'
  end

  def computer_defense_ai
    board.current_winning_moves.each do |winning_row|
      marker = winning_row[:marker]
      empty_square = winning_row[:empty_square]
      if marker == human.marker
        board[empty_square] = computer.marker
        break
      end
    end
  end

  def computer_offense_ai
    board.current_winning_moves.each do |winning_row|
      marker = winning_row[:marker]
      empty_square = winning_row[:empty_square]
      if marker == computer.marker
        board[empty_square] = computer.marker
        break
      end
    end
  end

  def computer_random_move
    board.unmarked_keys.sample
    board[board.unmarked_keys.sample] = computer.marker
  end

  def current_player_moves
    if @current_marker == human.marker
      human_moves
      @current_marker = computer.marker
    else
      computer_moves
      @current_marker = human.marker
    end
  end

  def clear
    system "clear"
  end
end

game = TTTGame.new
game.play
