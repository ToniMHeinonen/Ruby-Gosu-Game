require_relative "../tools/collision"

class Portal
    attr_reader :x, :y, :width, :height, :collision

    WIDTH = 50
    HEIGHT = 50
    OFFSET = 5
    DRAW_Z = 1

    def initialize(x, y)
        @x, @y = x, y
        @width = WIDTH - OFFSET
        @height = HEIGHT - OFFSET
        
        # Load all animations to portal
        @animation = *Gosu::Image.load_tiles("../media/portal.png", WIDTH, HEIGHT)
        
        @collision = Collision.new(self)
    end

    def draw
        # Animate the image
        img = @animation[Gosu.milliseconds / 100 % @animation.size]
        img.draw(@x - @width / 2, @y - @height / 2, DRAW_Z)
    end
end