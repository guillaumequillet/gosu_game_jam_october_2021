=begin
  Gosu Game Jam October 2021
  Theme : Chaos

  camion arrive : colis tombent en vrac
  on a une chaine
  on a des palettes 
  
  gameplay :
  activer / désactiver chaine
  poser colis sur chaine
  lancer colis vers opérateur
  activer opérateur

=end

require 'gosu'

$tile_size = 16

class Position
  attr_accessor :x, :y, :z
  def initialize(x = 0, y = 0, z = 0)
    @x, @y, @z = x, y, z
  end
end

class Parcel
  @@gfx = Gosu::Image.new('./gfx/parcel.png', retro: true)
  def initialize(color, position)
    @color = color
    @position = position
  end

  def draw(position = @position)
    @@gfx.draw(position.x, position.y, position.z, 1, 1, @color)
  end
end

class Conveyor
  @@gfx = Gosu::Image.load_tiles('./gfx/conveyor.png', 16, 32, retro: true)
  @@control_panel = {
    speed_1: Gosu::Image.new('./gfx/conveyor_control_panel/speed_1.png'),
    speed_2: Gosu::Image.new('./gfx/conveyor_control_panel/speed_2.png'),
    speed_3: Gosu::Image.new('./gfx/conveyor_control_panel/speed_3.png'),
    speed_stop: Gosu::Image.new('./gfx/conveyor_control_panel/stop.png')
  }

  def initialize(window)
    @window = window
    set_speed(1)
    @current_frame = 0
    @frame_tick = Gosu::milliseconds
    @pieces_tiles = []

    @ui_position = Position.new(0, @window.height - @@control_panel[:speed_1].height, 1)
  end

  def set_speed(speed)
    @speed = speed
    @frame_duration = case speed
    when 0 then 0
    when 1 then 400
    when 2 then 200
    when 3 then 50
    end
  end

  def button_down(id)
    if id == Gosu::MS_LEFT
      if @window.mouse_in?(@ui_position.x + 58, @ui_position.y + 123, 36, 36)
        set_speed(1)
      elsif @window.mouse_in?(@ui_position.x + 101, @ui_position.y + 123, 36, 36)
        set_speed(2)
      elsif @window.mouse_in?(@ui_position.x + 144, @ui_position.y + 123, 36, 36)
        set_speed(3)
      elsif @window.mouse_in?(@ui_position.x + 188, @ui_position.y + 123, 128, 36)
        set_speed(0)
      end
    end
  end

  def add_piece(tile_position)
    @pieces_tiles.push tile_position
  end

  def update
    if @speed > 0 
      if Gosu::milliseconds - @frame_tick >= @frame_duration
        @current_frame += 1
        @current_frame = 0 if @current_frame >= @@gfx.size
        @frame_tick = Gosu::milliseconds
      end
    else
      @frame_tick = Gosu::milliseconds
    end
  end

  def draw
    @pieces_tiles.each do |coordinates|
      x = coordinates.x * $tile_size
      y = coordinates.y * $tile_size
      @@gfx[@current_frame].draw(x, y, 0)
    end
  end

  def draw_ui
    # control panel drawing
    image = case @speed
    when 0 then :speed_stop
    when 1 then :speed_1
    when 2 then :speed_2
    when 3 then :speed_3
    end
    @@control_panel[image].draw(@ui_position.x, @ui_position.y, @ui_position.z)
  end
end

class Pallet
  @@gfx = Gosu::Image.new('./gfx/pallet.png', retro: true)
  def initialize(position)
    @position = position
    @parcels = []
    @max_parcels = 30
  end

  def add_parcel(parcel)
    @parcels.push parcel if @parcels.size < @max_parcels
  end

  def draw
    @@gfx.draw(@position.x * $tile_size, @position.y * $tile_size, @position.z)
    slice = 0
    height = 0
    x, y = 0, -3
    @parcels.each_with_index do |parcel, i|
      parcel.draw(Position.new(@position.x * $tile_size + x, @position.y * $tile_size + y, 0))
      y += 5
      slice += 1
      
      # 5 boxes side by side
      if slice == 5
        x += 8
        y = -3 - height
      # we can place up to 10 boxes on one slice
      elsif slice >= 10
        slice = 0
        height += 4
        x, y = 0, -3 - height
      end
    end
  end
end

class Window < Gosu::Window
  def initialize
    super(800, 600, false)
    self.caption = 'Gosu Game JAM - October 2021 - Theme : Chaos'
    map_setup
  end

  def map_setup
    @pallet = Pallet.new(Position.new(1, 1))
    @conveyor = Conveyor.new(self)
    @conveyor.add_piece(Position.new(2, 4))
    @conveyor.add_piece(Position.new(3, 4))
    @conveyor.add_piece(Position.new(4, 4))
    @conveyor.add_piece(Position.new(5, 4))
  end

  def mouse_in?(x, y, w, h)
    self.mouse_x >= x && self.mouse_x <= x + w && self.mouse_y >= y && self.mouse_y <= y + h
  end

  def button_down(id)
    super
    close! if id == Gosu::KB_ESCAPE
    @conveyor.button_down(id)

    if id == Gosu::KB_SPACE
      colors = [Gosu::Color::RED, Gosu::Color::GREEN, Gosu::Color::BLUE]
      @pallet.add_parcel(Parcel.new(colors.sample, Position.new))
    end
  end

  def update
    @conveyor.update
  end

  def draw
    zoom = 2
    scale(zoom, zoom) do
      @pallet.draw
      @conveyor.draw
    end

    @conveyor.draw_ui
  end
end

Window.new.show
