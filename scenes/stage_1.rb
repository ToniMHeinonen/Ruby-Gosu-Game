# Encoding: UTF-8

require "gosu"

class Stage1 < Gosu::Window
    # Size of the window
    WIDTH = 1024
    HEIGHT = 576
    
    def initialize
        super WIDTH, HEIGHT

        # Title for the window
        self.caption = "Gosu Game"

        # Load assets
        @background = Gosu::Image.new("../media/background.png", tileable: true)
    end

    def update
        
    end

    def draw
        # Draw background starting from corner
        @background.draw 0, 0, 0
    end
end

# Show the game window
Stage1.new.show