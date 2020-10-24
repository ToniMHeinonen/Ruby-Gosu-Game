require_relative "../tools/collision"

class Collectible
    attr_reader :x, :y, :width, :height, :collision

    OFFSET = 5

    def initialize(image, x, y)
        @image = image
        @x, @y = x, y
        @width = image.width - OFFSET
        @height = image.height - OFFSET
        @collision = Collision.new(self)
    end

    def draw
        # Draw, slowly rotating
        @image.draw_rot(@x, @y, 0, 10 * Math.sin(Gosu.milliseconds / 250.0))
    end
end