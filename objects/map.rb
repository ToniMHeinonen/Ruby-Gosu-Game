require_relative "enemy"
require_relative "portal"
require_relative "collectible"

# All different kinds of tiles
module Tiles
    TILE_SIZE = 50
    TILE_CENTER = TILE_SIZE / 2

    Grass = 0
    Earth = 1
end

# Map class holds and draws tiles and gems.
class Map
    attr_reader :width, :height, :diamonds, :diamondsAmount, :enemies, :portal, :finalStage

    # Size of tiles in file
    TILE_WIDTH = 60
    TILE_HEIGHT = 60
    STARTING_STAGE = 1 # Used for testing different stages
  
    def initialize()
        @tileset = Gosu::Image.load_tiles("media/tileset.png", TILE_WIDTH, TILE_HEIGHT, tileable: true)

        # Load images here so they will only be loaded once per game
        @enemyAnimation = *Gosu::Image.load_tiles("media/enemy_char.png", Enemy::WIDTH, Enemy::HEIGHT)
        @portalAnimation = *Gosu::Image.load_tiles("media/portal.png", Portal::WIDTH, Portal::HEIGHT)
        @diamondImg = Gosu::Image.new("media/diamond.png")

        # Load all the stages in to an array
        @stages = Dir.glob('stages/*').select { |e| File.file? e }
        @finalStage = false
    end

    def startGame(player)
        @diamondsAmount = 0 # Reset collected diamonds
        @player = player
        # -2 since index starts at 0 and nextStage() adds +1 to the value
        @currentStageIndex = STARTING_STAGE - 2
        nextStage()
    end

    # Changes the stage to the next one
    def nextStage
        @currentStageIndex += 1
        createMap(@stages[@currentStageIndex])
        @finalStage = true if @stages.length == @currentStageIndex + 1
    end

    def createMap(filename)
        # Load all lines from the given file
        lines = File.readlines(filename).map { |line| line.chomp }
        # Height is the size of rows
        @height = lines.size
        # Width is the lenght of first row
        @width = lines[0].size

        # Initialize enemies
        @enemies = []

        # Initialize diamonds
        @diamonds = []

        # Initialize portal
        @portal = nil

        # Create an array of tiles
        @tiles = Array.new(@width) do |x|
            Array.new(@height) do |y|
                case lines[y][x, 1]
                when '*'
                    Tiles::Grass
                when '#'
                    Tiles::Earth
                when 'E'
                    # Spawn enemy at the middle of position
                    @enemies.push(Enemy.new(@enemyAnimation, self, x * Tiles::TILE_SIZE + Tiles::TILE_CENTER , y * Tiles::TILE_SIZE + Tiles::TILE_CENTER))
                    nil
                when 'C'
                    # Spawn diamond at the middle of position
                    @diamonds.push(Collectible.new(@diamondImg, x * Tiles::TILE_SIZE + Tiles::TILE_CENTER, y * Tiles::TILE_SIZE + Tiles::TILE_CENTER))
                    @diamondsAmount += 1
                    nil
                when 'P'
                    # Spawn portal at the middle of position
                    @portal = Portal.new(@portalAnimation, x * Tiles::TILE_SIZE + Tiles::TILE_CENTER, y * Tiles::TILE_SIZE + Tiles::TILE_CENTER)
                    nil
                when 'U'
                    # Spawn player at the middle of position
                    @player.reposition(x * Tiles::TILE_SIZE + Tiles::TILE_CENTER, y * Tiles::TILE_SIZE + Tiles::TILE_CENTER)
                    nil
                else
                    # Add null value so it does not draw anything on there
                    nil
                end
            end
        end
    end

    def update
        # Remove enemies which fall of the stage
        @enemies.reject! do |e|
            e.y > Game::HEIGHT + 100
        end

        # Update all enemies
        @enemies.each { |e| e.update }
    end
  
    def draw
        offset = 5
        # Draws all the tiles
        @height.times do |y|
            @width.times do |x|
                # Get the tile from x and y position
                tile = @tiles[x][y]
                if tile
                    # Draw the tile with an offset (tile images have some overlap)
                    @tileset[tile].draw(x * Tiles::TILE_SIZE - offset, y * Tiles::TILE_SIZE - offset, DRAW_ORDER::TILES)
                end
            end
        end

        # Draws all enemies
        @enemies.each { |e| e.draw }

        # Draws all diamonds
        @diamonds.each { |c| c.draw }

        # Draws portal
        @portal.draw
    end

    # Checks if there is a solid tile at the position
    def solidTileAt?(x, y)
        # If pixel is at the bottom of the map
        # Or there is a tile at the given position
        y < 0 || @tiles[x / Tiles::TILE_SIZE][y / Tiles::TILE_SIZE]
    end
end