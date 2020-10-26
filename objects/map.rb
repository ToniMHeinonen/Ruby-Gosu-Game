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
    attr_reader :width, :height, :diamonds, :portal

    # Size of tiles in file
    TILE_WIDTH = 60
    TILE_HEIGHT = 60
  
    def initialize(filename)
        @tileset = Gosu::Image.load_tiles("../media/tileset.png", TILE_WIDTH, TILE_HEIGHT, tileable: true)

        # Load all lines from the given file
        lines = File.readlines(filename).map { |line| line.chomp }
        # Height is the size of rows
        @height = lines.size
        # Width is the lenght of first row
        @width = lines[0].size

        # Initialize enemies
        @enemies = []
        enemyAnimation = *Gosu::Image.load_tiles("../media/enemy_char.png", Enemy::WIDTH, Enemy::HEIGHT)

        # Initialize collectible image here so it only happens once
        diamondImg = Gosu::Image.new("../media/diamond.png")
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
                    # Spawn the enemy at the middle
                    @enemies.push(Enemy.new(enemyAnimation, self, x * Tiles::TILE_SIZE + Tiles::TILE_CENTER , y * Tiles::TILE_SIZE + Tiles::TILE_CENTER))
                    nil
                when 'C'
                    @diamonds.push(Collectible.new(diamondImg, x * Tiles::TILE_SIZE + Tiles::TILE_CENTER, y * Tiles::TILE_SIZE + Tiles::TILE_CENTER))
                    nil
                when 'P'
                    @portal = Portal.new(x * Tiles::TILE_SIZE + Tiles::TILE_CENTER, y * Tiles::TILE_SIZE + Tiles::TILE_CENTER)
                    nil
                else
                    # Add null value so it does not draw anything on there
                    nil
                end
            end
        end
    end

    def update
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