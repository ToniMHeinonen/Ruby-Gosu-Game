require_relative "character"
require_relative "../tools/collision"

class Enemy < Character

    WIDTH = 42
    HEIGHT = 31
    SPEED = 5

    def initialize(animation, map, x, y)
        # Load all animations to enemy
        @standing, @walk1, @walk2, @jump = animation 

        super(WIDTH, HEIGHT, map, x, y)  
    end

    def update()
        # Move enemy left or right
        moveX = @dir == :left ? -SPEED : SPEED
        moveCharacter(moveX) # Super

        super
    end

    # Checks if enemy is allowed to move to given position
    def movementAllowed?(x, y)
        @collision.checkPosition(x, y)

        # If tile at left, turn right
        if @map.solidTileAt?(@collision.center_left[0], @collision.center_left[1])
            @dir = :right
            return false
        end
        
        # If tile at right, turn left
        if @map.solidTileAt?(@collision.center_right[0], @collision.center_right[1])    # Center-right
            @dir = :left
            return false
        end

        super(x, y)
    end
end