class Player
    attr_reader :x, :y

    WIDTH = 42
    HEIGHT = 50
    DRAW_Z = 5

    def initialize(x, y)
        @x, @y = x, y
        @dir = :left
        # Velocity gets adjusted when jumping and falling
        @verticalVelocity = 0
        # Load all animations to player character
        @standing, @walk1, @walk2, @jump = *Gosu::Image.load_tiles("../media/player_char.png", WIDTH, HEIGHT)
        # Image to draw
        @curImage = @standing    
    end

    def draw
        @curImage.draw(@x, @y, DRAW_Z)
    end

    def update
        
    end
end