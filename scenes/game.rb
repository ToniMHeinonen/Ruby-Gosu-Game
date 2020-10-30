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

class Game < Gosu::Window

    # Size of the window
    WIDTH = 1024
    HEIGHT = 576
    
    def initialize
        super WIDTH, HEIGHT

        # Title for the window
        self.caption = "Gosu Game"
        # Load text fonts
        @font = Gosu::Font.new(30)

        

        # Init texts
        largeSize = 100
        mediumSize = 70
        @gameOver = Gosu::Image.from_text("GAME OVER", largeSize, {:align => :center})
        @restartText = Gosu::Image.from_text("Press R to restart", mediumSize, {:align => :center})
        @gameFinished = Gosu::Image.from_text("Congratulations!", largeSize, {:align => :center})
        @thanksForPlaying = Gosu::Image.from_text("Thanks for playing", mediumSize, {:align => :center})

        # Load background image
        @background = Gosu::Image.new("../media/background.png", tileable: true)
        # Initialize map
        @map = Map.new
        startGame()
        # Setup camera
        @cameraX = 0
        @cameraY = @map.height * Tiles::TILE_SIZE - HEIGHT

        # Play music
        song = Gosu::Song.new("../media/music.mp3")
        song.volume = 0.3
        song.play(true)
    end

    def startGame
        @player = Player.new(@map)
        @map.startGame(@player)
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
        @font.draw_text("Score: #{@player.score}", 60, 10, DRAW_ORDER::UI, 1.0, 1.0, Gosu::Color::WHITE)

        if (!@player.isAlive)
            # Draw game over
            drawCentered(@gameOver, true)
            drawCentered(@restartText, false)
        end

        if (@map.finalStage)
            # Draw congratulations text
            drawCentered(@gameFinished, true)
            drawCentered(@thanksForPlaying, false)
        end
    end

    # Draws texts in center of the screen
    def drawCentered(text, heading)
        if heading 
            # Heading
            text.draw_rot(WIDTH / 2, HEIGHT / 2 - 100, DRAW_ORDER::UI, center_x = 0.5, center_y = 0.5)
        else 
            # Subheading
            text.draw_rot(WIDTH / 2, HEIGHT / 2, DRAW_ORDER::UI, center_x = 0.5, center_y = 0.5) 
        end
    end

    # These will only be called once
    def button_down(id)
        @player.buttonDown(id)
        
        case id
        when Gosu::KB_ESCAPE
            # Close the game
            close
        when Gosu::KB_R
            # Restart the game
            startGame() if !@player.isAlive
        else
            super
        end
    end
end

# Show the game window
Game.new.show