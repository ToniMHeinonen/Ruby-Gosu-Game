require_relative "../tools/collision"

class Character
    attr_reader :x, :y, :width, :height, :collision

    def initialize(width, height, map, x, y)
        @x, @y = x, y
        @map = map
        @collision = Collision.new(self)

        @width = width
        @height = height
        @drawZ = DRAW_ORDER::CHARACTER

        @dir = :left
        # Velocity gets adjusted when jumping and falling
        @verticalVelocity = 0
        # Image to draw
        @curImage = @standing
    end

    def draw
        # Flip vertically when facing to the left
        # Add offset so the image does not jump around when turning
        if @dir == :left
            offsetX = -(@width / 2)
            factor = 1.0
        else
            offsetX = @width / 2
            factor = -1.0
        end
        
        
        @curImage.draw( @x + offsetX,
                        @y - @height - 1 * Math.sin(Gosu.milliseconds / 250.0), # Make slight floating animation up and down
                        @drawZ, 
                        factor, # factor flips the image horizontally
                        1.0)
    end

    def update()
        controlYMovement()
    end

    # Moves the character horizontally
    def moveCharacter(moveX)
        # Change direction based on movement and move character speed amount of times
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
            # If character is moving up, change to jumping animation
            @curImage = @jump
        elsif (@verticalVelocity > 0)
            # Else if character is moving down, change to standing animation
            @curImage = @standing
        end
    end

    # Moves character vertically
    def controlYMovement
        # Acceleration/gravity
        # By adding 1 each frame, character falls down
        @verticalVelocity += 1
        # Vertical movement
        if @verticalVelocity > 0
            @verticalVelocity.times { if movementAllowed?(@x, @y + 1) then @y += 1 else @verticalVelocity = 0 end }
        elsif @verticalVelocity < 0
            # Convert velocity to positive number
            (-@verticalVelocity).times { if movementAllowed?(@x, @y - 1) then @y -= 1 else @verticalVelocity = 0 end }
        end
    end

    # Checks if character is allowed to move to given position
    def movementAllowed?(x, y)
        # If character has not tried to move, skip code
        if x == @x and y == @y
            return
        end

        @collision.checkPosition(x, y)

        @collision.collisions.each do |col|
            if @map.solidTileAt?(col[0], col[1])
                return false
            end
        end
    end

end