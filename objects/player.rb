require_relative "character"
require_relative "collectible"
require_relative "portal"
require_relative "enemy"

class Player < Character
    attr_reader :score, :isAlive

    WIDTH = 42
    HEIGHT = 50
    SPEED = 5
    JUMP_HEIGHT = 20

    def initialize(map)
        # Load all animations to player character
        @standing, @walk1, @walk2, @jump = *Gosu::Image.load_tiles("media/player_char.png", WIDTH, HEIGHT)
        @score = 0
        @isAlive = true
        @deathUp = nil

        # Sound effects
        @jumpSound = Gosu::Sample.new("media/jump.wav")
        @deathSound = Gosu::Sample.new("media/death.mp3")
        @collectSound = Gosu::Sample.new("media/collect.wav")

        super(WIDTH, HEIGHT, map, 0, 0)
        # Start player at facing right
        @dir = :right
    end

    # Positions the player to provided coordinates
    # Used when stage is changed
    def reposition(x, y)
        @x = x
        @y = y
    end

    def update
        # If player is dead, control the death animation and skip rest
        if !@isAlive
            controlDeathAnimation()
            return
        end
        
        checkMovement()
        checkCollisions()
        super
    end

    def draw
        # If player is dead, draw only the death animation
        if !@isAlive
            drawDeathAnimation()
            return
        end

        super
    end

    def controlDeathAnimation
        # If death animation has just started
        if @deathUp == nil
            @originalY = @y
            @deathUp = true
        end
        
        if @deathUp == true
            # Moving up when takes hit
            @y -= 10
            if @y < @originalY - 200
                @deathUp = false
            end
        else
            # Moving down out of screen
            @y += 3
            if @y > Game::HEIGHT + 100
                # Game over when out of screen
                # Do nothing special at the moment
            end
        end
    end

    def drawDeathAnimation
        # Draw upside down when going down in death animation
        factor = @deathUp ? 1.0 : -1.0
        offsetY = @deathUp ? -(@height / 2) : @height / 2
        
        @curImage.draw( @x - @width / 2, @y + offsetY, DRAW_ORDER::UI - 1, 1.0, factor, Gosu::Color::RED.dup)
    end

    # Move the player
    def checkMovement
        moveX = 0
        # Gosu.button_down? needs to be called every frame for movement
        moveX -= SPEED if Gosu.button_down? Gosu::KB_LEFT or Gosu.button_down? Gosu::KB_A
        moveX += SPEED if Gosu.button_down? Gosu::KB_RIGHT or Gosu.button_down? Gosu::KB_D

        moveCharacter(moveX) # Super
    end

    # Controls jumping
    def jump
        @collision.checkPosition(@x, @y + 1)

        # If one pixel below character is solid, jumping is allowed
        if @map.solidTileAt?(collision.center_bottom[0], collision.center_bottom[1]) or 
            @map.solidTileAt?(collision.bottom_left[0], collision.bottom_left[1]) or
            @map.solidTileAt?(collision.bottom_right[0], collision.bottom_right[1])
            @verticalVelocity = -JUMP_HEIGHT
            @jumpSound.play
        end
    end

    # These will only be called once
    def buttonDown(id)
        case id
        when Gosu::KB_UP, Gosu::KB_W
            jump()
        end
    end

    def die
        @isAlive = false
        @deathSound.play
    end

    def checkCollisions
        # Remove diamonds on collision
        before = @map.diamonds.length
        @map.diamonds.reject! do |c|
            if @collision.checkCollision?(c.collision)
                @score += 1
                @collectSound.play
                true
            else
                false
            end
        end

        # Die if collision with enemy
        @map.enemies.each do |enemy|
            die() if @collision.checkCollision?(enemy.collision)
        end

        # Change stage on portal collision
        @map.nextStage if @collision.checkCollision?(@map.portal.collision)

        # If player falls of the map, die
        die() if @y > Game::HEIGHT + @height
    end
end