require_relative "character"

class Enemy < Character

    WIDTH = 42
    HEIGHT = 31
    DRAW_Z = 5
    SPEED = 5

    def initialize(map, x, y)
        # Load all animations to enemy
        @standing, @walk1, @walk2, @jump = *Gosu::Image.load_tiles("../media/enemy_char.png", WIDTH, HEIGHT) 

        super(WIDTH, HEIGHT, DRAW_Z, map, x, y)  
    end

    def update()
        # Move enemy left or right
        moveX = @dir == :left ? -SPEED : SPEED
        moveCharacter(moveX) # Super

        super
    end

    # Checks if enemy is allowed to move to given position
    def movementAllowed?(x, y)
        offset, xWidthFromCenter = getOffsetValues()

        # If tile at left, turn right
        if @map.solidTileAt?(x - xWidthFromCenter, y - (HEIGHT / 2))    # Center-left
            @dir = :right
            return false
        end
        
        # If tile at right, turn left
        if @map.solidTileAt?(x + xWidthFromCenter, y - (HEIGHT / 2))    # Center-right
            @dir = :left
            return false
        end

        super(x, y)
    end
end