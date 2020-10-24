class Collision
    attr_reader :collisions
    attr_reader :top_left
    attr_reader :top_right
    attr_reader :bottom_left
    attr_reader :bottom_right
    attr_reader :center_top
    attr_reader :center_right
    attr_reader :center_bottom
    attr_reader :center_left

    OFFSET = 5 # Make collision slightly smaller than width and height
    X = 0
    Y = 1

    def initialize(object)
        @object = object
    end

    def refresh()
        checkPosition(@object.x, @object.y)
    end

    def checkPosition(x, y)
        width = @object.width
        height = @object.height
        
        xWidthFromCenter = width / 2 - OFFSET

        @top_left = [x - xWidthFromCenter, y - (height - OFFSET)]
        @top_right = [x + xWidthFromCenter, y - (height - OFFSET)]
        @bottom_left = [x - xWidthFromCenter, y]
        @bottom_right = [x + xWidthFromCenter, y]
        @center_top = [x + xWidthFromCenter, y - (height - OFFSET)]
        @center_right = [x + xWidthFromCenter, y - (height / 2)]
        @center_bottom = [x, y]
        @center_left = [x - xWidthFromCenter, y - (height / 2)]

        @collisions = []
        @collisions += [@top_left, @top_right, @bottom_left, @bottom_right,
                        @center_top, @center_right, @center_bottom, @center_left]
    end

    def checkCollision(other)
        refresh()
        other.refresh()
        
        xMin = @center_left[X]
        xMax = @center_right[X]
        yMin = @center_bottom[Y]
        yMax = @center_top[Y]

        xMax > other.center_left[X] && xMin < other.center_right[X] && 
        yMin > other.center_top[Y] && yMax < other.center_bottom[Y]
    end
end