# gems
require 'tty-prompt'
require 'terminal-table'
require 'colorize'

# files
require_relative 'game_helper'
require_relative 'main_ui'
require_relative '../game_logic/game'

class AppRouter
  include GameHelper
  def initialize
    @main_ui = UserInterface.new
    @game = Game.new
    @temp_prompt_selection = "0"
    @temp_prompt_response = "0"
  end

  def start_app
    @main_ui.page_title = "Main Menu"
    @main_ui.scoreboard = nil
    @main_ui.instruction =  INSTRUCTION_MENU
    @main_ui.dice_results = nil
    @main_ui.prompt = PROMPT_MENU
    @game.players = []
    @main_ui.player_list = []
  end

  def new_game_setup_0
    @main_ui.page_title = "Game Setup - Number of Players"
    @main_ui.instruction =  INSTRUCTION_SETUP_NUMBER
    @main_ui.prompt = PROMPT_SETUP_NUMBER
    @game.players = []
    @main_ui.player_list = []
  end

  def new_game_setup_1
    @main_ui.page_title = "Game Setup - Player Names"
    @main_ui.instruction =  INSTRUCTION_SETUP_PLAYER
    @main_ui.prompt = PROMPT_SETUP_PLAYER
  end

  def new_game_setup_2
    @main_ui.page_title = "Game Setup - Confirm Start"
    @main_ui.instruction =  INSTRUCTION_SETUP_CONFIRM
    @main_ui.prompt = PROMPT_CONFIRM_SETUP
  end

  def initiate_game
    @main_ui.page_title = "Game active: "
    @main_ui.scoreboard = "Scores: "
    @main_ui.instruction =  INSTRUCTION_START_ROUND
    @main_ui.dice_results = "Dice Results: "
    @main_ui.prompt = PROMPT_ROLL
    @game.randomize_players
    populate_game
  end

  def populate_game
    for i in 0..@game.number_of_players-1 do
      @main_ui.scoreboard << "#{@game.players.map{|player| player.name}[i]}: #{@game.players.map{|player| player.score}[i]} "
      if @game.players[i] == @game.active_player
        @main_ui.scoreboard << "+ [0] " 
        @main_ui.page_title << "#{@game.players.map{|player| player.name}[i]}'s turn"
      end
    end
  end

  def route_prompt_select
    case @main_ui.prompt_selection
      when nil, "exit_to_menu" then start_app
      when "tutorial" then puts "Goes to tutorial page"
      # when "new_game", "reset_game" then new_game_setup_0
      when "new_game" then 
        @game.set_player("Tom")
        @game.set_player("Dick")
        @game.set_player("Harry")
        @game.number_of_players = 3
        initiate_game
      when "start_game" then initiate_game
      when "exit_app" then exit
    end
    @temp_prompt_selection = @main_ui.prompt_selection
  end
    
  def route_prompt_ask
    case @main_ui.prompt_response
      when nil
      when "3".."6" 
        @game.number_of_players = @main_ui.prompt_response.to_i
        new_game_setup_1
      else
        @game.set_player(@main_ui.prompt_response)
        @main_ui.player_list << @main_ui.prompt_response
        new_game_setup_2 if @game.players.length == @game.number_of_players
      end
    @temp_prompt_response = @main_ui.prompt_response
  end

  def run
    loop do
      unless @temp_prompt_selection == @main_ui.prompt_selection
        route_prompt_select
      end
      unless @temp_prompt_response == @main_ui.prompt_response
        route_prompt_ask
      end
      @main_ui.populate_ui
    end
  end
end


app = AppRouter.new
app.run