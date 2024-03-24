require 'bundler'
Bundler.require
require_relative 'setup_dll'

TEXT = <<~TEXT
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. A erat nam at lectus urna duis. Pulvinar mattis nunc sed blandit libero volutpat sed. Elit ut aliquam purus sit amet luctus venenatis lectus. Morbi tempus iaculis urna id volutpat lacus laoreet non. Mauris pharetra et ultrices neque ornare aenean euismod elementum. Dui sapien eget mi proin sed libero enim sed faucibus. Mauris cursus mattis molestie a iaculis at erat pellentesque adipiscing. Sapien pellentesque habitant morbi tristique senectus et. Tempor id eu nisl nunc mi ipsum. Gravida quis blandit turpis cursus in hac habitasse. Diam quam nulla porttitor massa id neque aliquam.
TEXT

COLMAK_MAPPING = {
  32 => ' ',
  81 => 'q',
  87 => 'w',
  69 => 'f',
  82 => 'p',
  84 => 'b',
  89 => 'j',
  85 => 'l',
  73 => 'u',
  79 => 'y',
  80 => ';',
  91 => '[',
  93 => ']',
  65 => 'a',
  83 => 'r',
  68 => 's',
  70 => 't',
  71 => 'g',
  72 => 'k',
  74 => 'n',
  75 => 'e',
  76 => 'i',
  59 => 'o',
  39 => "'",
  90 => 'z',
  88 => 'x',
  67 => 'c',
  86 => 'd',
  66 => 'v',
  78 => 'm',
  77 => 'h',
  44 => ',',
  46 => '.',
  47 => '/',
}


SCREEN_WIDTH = 1500
SCREEN_HEIGHT = 300

FONT_SIZE = 96

ELAPSED_TIME = 120

LINE = 100

class Game
  attr_reader :doodler

  def initialize
    @state = :paused
    @cursor = 0
    @elapsed_time = ELAPSED_TIME
    @sym_per_min = 0
    @errors = 0
  end

  def run
    SetTargetFPS(60)

    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Keyboard trainer")
      @font = LoadFontEx("OpenSans-Regular.ttf", FONT_SIZE, nil, 0)
      until WindowShouldClose()
        update
        draw
      end
      UnloadFont(@font)
    CloseWindow()
  end

  def toggle_state
    @state = @state == :paused ? :running : :paused
  end

  def update
    if IsKeyPressed(KEY_SPACE) && @state == :paused
      @start_time = GetTime()
      toggle_state
    end

    if @state == :running
      time_spent = (GetTime() - @start_time)
      if time_spent >= ELAPSED_TIME
        @elapsed_time = 0.0
        @state = :end
      end

      @elapsed_time = ELAPSED_TIME - time_spent
      char = COLMAK_MAPPING[GetKeyPressed()]

      if char == TEXT[@cursor].downcase
        @cursor +=1
      else
        @errors +=1 unless char.nil? || char == ' '
      end

      @sym_per_min = 60 * @cursor / time_spent
      if @cursor == 0
        @green_line = ''
      else
        @green_line = TEXT[(@cursor - [15, @cursor].min)..(@cursor-1)]
      end

      @green_position = MeasureTextEx(@font, @green_line, FONT_SIZE, 0)
      @green_position.x = SCREEN_WIDTH / 2 - @green_position.x
      @green_position.y = 130
      @black_line = TEXT[@cursor..@cursor+15]
    end
  end

  def draw
    BeginDrawing()
      ClearBackground(WHITE)

      DrawText("Time left: %.1f" % @elapsed_time, 50, 50, 30, BLUE)
      DrawText("Errors: %d" % @errors, SCREEN_WIDTH / 2 - 100, 50, 30, RED)
      DrawText("Speed: %d sym/m" % @sym_per_min, SCREEN_WIDTH - 300, 50, 30, BLUE)

      rec = Rectangle.create( 50, 130, SCREEN_WIDTH - 100, LINE)
      DrawRectangleRounded(rec, 0.4, 10, Fade(BLUE, 0.1));
      DrawRectangleRoundedLines(rec, 0.4, 15, 3.0, BLUE)

      if @state == :running
        DrawTextEx(@font, @green_line, @green_position, FONT_SIZE, 0, DARKGREEN)
        DrawTextEx(@font, @black_line, Vector2.create(SCREEN_WIDTH/2, 130), FONT_SIZE, 0, BLACK)
      elsif @state == :paused
        DrawTextEx(@font, "Press SPACE to start", Vector2.create(400, 130), FONT_SIZE, 0, BLACK)
      else
        DrawTextEx(@font, "You are done!", Vector2.create(450, 130), FONT_SIZE, 0, BLACK)
      end
    EndDrawing()
  end
end

Game.new.run
# This is the method to start game
