require 'yaml'

class WordPicker

  def self.pick_word
    word_options = []
    @content = File.readlines("5desk.txt")
    @content.each do |line|
      word = line.strip.to_s
      if word.length >= 5 && word.length <= 12
        word_options << word
      end
    end
    word_options.sample
  end
end

class Game
  attr_accessor :guessed_letters, :word

  def initialize(turns=0, word=[], guessed_letters=[])
    @turns = turns
    @word = word
    @guessed_letters = guessed_letters
    begin_game
  end

  def load_game
    directory = Dir.open("/home/terry/Desktop/odin/fileio")
    files = directory.entries
    files.delete("5desk.txt")
    puts "The available games are: #{files.join(", ")}"
    puts "Please type the name of a file to open: "
    game_to_load = gets.chomp.to_s until files.include? game_to_load
    game_file = File.open(game_to_load)
    yaml = game_file.read
    params = YAML::load(yaml)
    game_file.close
    directory.close
    return params
  end

  def save_game(game)
    puts "Type a name for the saved game: "
    file_name = gets.chomp.to_s
    yaml = YAML::dump(game)
    game_file = File.open("#{file_name}", "w")
    game_file << yaml
    game_file.close
  end

  def start_game
    puts "Do you want to start a new game [n] or load a saved game [l]?"
    choice = gets.chomp.to_s.downcase until ["n", "l"].include? choice
    return choice
  end

  def begin_game
    option = start_game
    if option == 'n'
      new_game
    else
      params = load_game
      params.play
    end        
  end

  def new_game
    print "How many turns do you want? \n>>  "
    @turns = gets.chomp.to_i
    @word = WordPicker.pick_word.downcase.split('')
    @guessed_letters = []
    play
  end    

  def display_board
    puts "Turns left: #{@turns}"
    display_array = []
    @word.each do |letter|
      if @guessed_letters.include?(letter)
        display_array << letter
      else
        display_array << "_"
      end
    end
    puts display_array.join("")
    puts "Guessed letters: #{guessed_letters.join(", ")}"
  end

  def guess
    puts "Pick your letter (or type 'save' to save): "
    input = gets.chomp.to_s.downcase
    while @guessed_letters.include?(input)
      puts "Already guessed. Pick another: "
      input = gets.chomp.to_s.downcase
    end
    if input == "save"
      save_game(self)
      puts "Exit? [y/n]"
      check_quit = gets.chomp.to_s.downcase until ['y', 'n'].include? check_quit
      if check_quit == 'y'
        exit
      end
    end    
    @guessed_letters << input
    if @word.include?(input)
      puts "Good guess!"
    else
      puts "Sorry, no good!"
      @turns -= 1
    end
  end

  def win?
    @word.each do |letter|
      return false unless @guessed_letters.include?(letter)
    end
    return true
  end

  def play
    until win? || @turns == 0
      display_board
      guess
    end
    if win?
      display_board
      puts "You won!"
    else
      display_board
      puts "Sorry, you lost! The word was #{@word.join('')}."
    end
  end
end

game = Game.new


