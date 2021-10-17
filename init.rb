=begin
  Gosu Game Jam October 2021
  Theme : Chaos

  logistique / transport :
  - des camions arrivent avec du vrac à décharger / trier ?
  - mécanique similaire à l'autre jeu où il faut prendre les colis par 1/2/3 ?
  - lancé de colis ? avec peut être notion risk / reward ? (colis endommagé)
  - colis par couleur pour représenter une zone de destination ?
  - possibilité d'utiliser une chaine ?
=end

require 'gosu'

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
    @@gfx.draw(@position.x, @position.y, @position.z)
    slice = 0
    height = 0
    x, y = 0, -3
    @parcels.each_with_index do |parcel, i|
      parcel.draw(Position.new(@position.x + x, @position.y + y, 0))
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
    super(640, 480, false)
    self.caption = 'Gosu Game JAM - October 2021 - Theme : Chaos'
  end

  def button_down(id)
    super
    close! if id == Gosu::KB_ESCAPE

    if id == Gosu::KB_SPACE
      colors = [Gosu::Color::RED, Gosu::Color::GREEN, Gosu::Color::BLUE]
      @pallet.add_parcel(Parcel.new(colors.sample, Position.new))
    end
  end

  def update
    unless defined?(@pallet)
      @pallet = Pallet.new(Position.new(16, 48, 0))
    end
  end

  def draw
    scale(4, 4) do
      @pallet.draw
    end
  end
end

Window.new.show
