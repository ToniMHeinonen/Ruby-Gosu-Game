class Player
    attr_reader :x, :y

    WIDTH = 42
    HEIGHT = 50
    DRAW_Z = 5
    SPEED = 5

    def initialize(map, x, y)
        @x, @y = x, y
        @map = map

        @dir = :left
        # Velocity gets adjusted when jumping and falling
        @verticalVelocity = 0
        # Load all animations to player character
        @standing, @walk1, @walk2, @jump = *Gosu::Image.load_tiles("../media/player_char.png", WIDTH, HEIGHT)
        # Image to draw
        @curImage = @standing    
    end

    def draw
        # Flip vertically when facing to the left
        # Add offset so the image does not jump around when turning
        if @dir == :left
            offsetX = -(WIDTH / 2)
            factor = 1.0
        else
            offsetX = WIDTH / 2
            factor = -1.0
        end
        
        # No idea what factor does but it makes the image not jump around
        @curImage.draw(@x + offsetX, @y - HEIGHT - 1, DRAW_Z, factor, 1.0)
    end

    def update()
        movePlayer()
        controlYMovement()
    end

    # Move the player
    def movePlayer
        moveX = 0
        # Gosu.button_down? needs to be called every frame for movement
        moveX -= SPEED if Gosu.button_down? Gosu::KB_LEFT
        moveX += SPEED if Gosu.button_down? Gosu::KB_RIGHT
        
        # Change direction based on movement and move player speed amount of times
        if moveX > 0
            @dir = :right
            moveX.times { if movementAllowed?(@x + 1, @y) then @x += 1 end }
        elsif moveX < 0
            @dir = :left
            # Convert movement to positive number
            (-moveX).times { if movementAllowed?(@x - 1, @y) then @x -= 1 end }
        end

        controlAnimation(moveX)
    end

    # Select image depending on action
    def controlAnimation(moveX)
        if (moveX == 0)
            @curImage = @standing
        else
            # Loop between 2 moving animations
            @curImage = (Gosu.milliseconds / 175 % 2 == 0) ? @walk1 : @walk2
        end

        # Control jumping and falling animations
        if (@verticalVelocity < 0)
            # If player is moving up, change to jumping animation
            @curImage = @jump
        elsif (@verticalVelocity > 0)
            # Else if player is moving down, change to standing animation
            @curImage = @standing
        end
    end

    # Controls jumping
    def jump
        @verticalVelocity = -20
    end

    def controlYMovement
        # Acceleration/gravity
        # By adding 1 each frame, player falls down
        @verticalVelocity += 1
        # Vertical movement
        if @verticalVelocity > 0
            @verticalVelocity.times { if movementAllowed?(@x, @y + 1) then @y += 1 else @verticalVelocity = 0 end }
        end
        if @verticalVelocity < 0
            # Convert velocity to positive number
            (-@verticalVelocity).times { if movementAllowed?(@x, @y - 1) then @y -= 1 else @verticalVelocity = 0 end }
        end
    end

    # Checks if player is allowed to move to given position
    def movementAllowed?(x, y)
        offset = 5 # Allow the player to go little bit inside tile
        
        # Check at the bottom of the player and top of the player
        not @map.solidTileAt?(x, y) and
        not @map.solidTileAt?(x, y - (HEIGHT - offset)) and
        # Check at the left of the player and right of the player
        not @map.solidTileAt?(x - (WIDTH / 2 - offset), y) and
        not @map.solidTileAt?(x + (WIDTH / 2 - offset), y)
    end

    # These will only be called once
    def buttonDown(id)
        case id
        when Gosu::KB_UP
            jump()
        end
    end
end