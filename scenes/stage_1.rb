# Encoding: UTF-8

require "gosu"

require_relative "../objects/player"
require_relative "../objects/map"

module DRAW_ORDER
    BACKGROUND = 0
    PORTAL = 1
    CHARACTER = 5
    COLLECTIBLE = 6
    TILES = 10
    UI = 100
end

class Stage1 < Gosu::Window
    # Size of the window
    WIDTH = 1024
    HEIGHT = 576
    
    def initialize
        super WIDTH, HEIGHT

        # Title for the window
        self.caption = "Gosu Game"
        # Load text font
        @font = Gosu::Font.new(25)

        # Load background image
        @background = Gosu::Image.new("../media/background.png", tileable: true)
        # Load map
        @map = Map.new("../media/stage_1.txt")
        # Load player
        @player = Player.new(@map, 100, 50)
        # Setup camera
        @cameraX = 0
        @cameraY = @map.height * Tiles::TILE_SIZE - HEIGHT
    end

    def update
        @player.update
        @map.update
        # Make camera follow player horizontally
        @cameraX = [[@player.x - WIDTH / 2, 0].max, @map.width * Tiles::TILE_SIZE - WIDTH].min
    end

    def draw
        # Draw background starting from corner
        @background.draw 0, 0, 0

        # Draw map and player relative to camera position
        Gosu.translate(-@cameraX, -@cameraY) do
            # Draw map
            @map.draw
            # Draw player in it's position
            @player.draw

            
        end

        # Draw score
        @font.draw_text("Score: #{@player.score}", 60, 10, DRAW_ORDER::UI, 1.0, 1.0, Gosu::Color::BLACK)
    end

    # These will only be called once
    def button_down(id)
        @player.buttonDown(id)
        
        case id
        when Gosu::KB_ESCAPE
            # Close the game
            close
        else
            super
        end
    end
end

# Show the game window
Stage1.new.show