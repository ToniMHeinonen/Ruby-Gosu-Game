class Character
    attr_reader :x, :y

    def initialize(width, height, drawZ, map, x, y)
        @x, @y = x, y
        @map = map

        @width = width
        @height = height
        @drawZ = drawZ

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
        
        # No idea what factor does but it makes the image not jump around
        @curImage.draw(@x + offsetX, @y - @height - 1, @drawZ, factor, 1.0)
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
        end
        if @verticalVelocity < 0
            # Convert velocity to positive number
            (-@verticalVelocity).times { if movementAllowed?(@x, @y - 1) then @y -= 1 else @verticalVelocity = 0 end }
        end
    end

    # Checks if character is allowed to move to given position
    def movementAllowed?(x, y)
        offset, xWidthFromCenter = getOffsetValues()

        # Check all the corners of character
        not @map.solidTileAt?(x - xWidthFromCenter, y) and  # Bottom-left
        not @map.solidTileAt?(x + xWidthFromCenter, y) and  # Bottom-right
        not @map.solidTileAt?(x - xWidthFromCenter, y - (@height - offset)) and  # Top-left
        not @map.solidTileAt?(x + xWidthFromCenter, y - (@height - offset)) and  # Top-right
        # Check top, bottom, left and right center of character
        not @map.solidTileAt?(x - xWidthFromCenter, y - (@height / 2)) and   # Center-left
        not @map.solidTileAt?(x + xWidthFromCenter, y - (@height / 2)) and   # Center-right
        not @map.solidTileAt?(x - xWidthFromCenter, y) and                  # Center-bottom
        not @map.solidTileAt?(x + xWidthFromCenter, y - (@height - offset))  # Center-top
    end

    def getOffsetValues
        offset = 5 # Allow the character to go little bit inside tile
        xWidthFromCenter = @width / 2 - offset

        return offset, xWidthFromCenter
    end
end