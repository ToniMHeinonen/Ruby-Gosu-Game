# All different kinds of tiles
module Tiles
    Grass = 0
    Earth = 1
end

# Map class holds and draws tiles and gems.
class Map
    attr_reader :width, :height

    # Size of tiles in file
    TILE_WIDTH = 60
    TILE_HEIGHT = 60
    # Size of tiles to make them overlap
    TRUE_WIDTH = 50
    TRUE_HEIGHT = 50
    
    DRAW_Z = 10
  
    def initialize(filename)
        @tileset = Gosu::Image.load_tiles("../media/tileset.png", TILE_WIDTH, TILE_HEIGHT, tileable: true)

        # Load all lines from the given file
        lines = File.readlines(filename).map { |line| line.chomp }
        # Height is the size of rows
        @height = lines.size
        # Width is the lenght of first row
        @width = lines[0].size

        # Create an array of tiles
        @tiles = Array.new(@width) do |x|
            Array.new(@height) do |y|
                case lines[y][x, 1]
                when '*'
                    Tiles::Grass
                when '#'
                    Tiles::Earth
                else
                    # Add null value so it does not draw anything on there
                    nil
                end
            end
        end
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
                    @tileset[tile].draw(x * TRUE_WIDTH - offset, y * TRUE_HEIGHT - offset, DRAW_Z)
                end
            end
        end
    end
end