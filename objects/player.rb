require_relative "character"

class Player < Character

    WIDTH = 42
    HEIGHT = 50
    DRAW_Z = 5
    SPEED = 5
    JUMP_HEIGHT = 20

    def initialize(map, x, y)
        # Load all animations to player character
        @standing, @walk1, @walk2, @jump = *Gosu::Image.load_tiles("../media/player_char.png", WIDTH, HEIGHT)

        super(WIDTH, HEIGHT, DRAW_Z, map, x, y)  
    end

    def update
        checkMovement()

        super
    end

    # Move the player
    def checkMovement
        moveX = 0
        # Gosu.button_down? needs to be called every frame for movement
        moveX -= SPEED if Gosu.button_down? Gosu::KB_LEFT
        moveX += SPEED if Gosu.button_down? Gosu::KB_RIGHT

        moveCharacter(moveX) # Super
    end

    # Controls jumping
    def jump
        @collision.refresh(self, @x, @y + 1)
        
        # If one pixel below character is solid, jumping is allowed
        if @map.solidTileAt?(collision.center_bottom[0], collision.center_bottom[1]) or 
            @map.solidTileAt?(collision.bottom_left[0], collision.bottom_left[1]) or
            @map.solidTileAt?(collision.bottom_right[0], collision.bottom_right[1])
            @verticalVelocity = -JUMP_HEIGHT
        end
    end

    # These will only be called once
    def buttonDown(id)
        case id
        when Gosu::KB_UP
            jump()
        end
    end
end