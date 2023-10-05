class Game
  class BowlingError < StandardError
  end

  def initialize
    @frames = [Frame.new, Frame.new, Frame.new, Frame.new, Frame.new, Frame.new, Frame.new, Frame.new, Frame.new, Frame.new, Frame.new, Frame.new]
    @frame_idx = 0
  end
  
  def roll(pins = 0)
    handle_roll_errors(pins)
    frame = @frames[@frame_idx]
    if !frame.closed
      frame.points << pins
      frame.rolls += 1
      if frame.points.sum == 10
        @frame_idx += 1
        if frame.rolls == 1
          frame.strike = true
          return
        elsif frame.rolls == 2
          frame.spare = true
          return
        end
      elsif frame.points.sum > 10
        raise Game::BowlingError, "Pins in frame cannot sum to greater than 10" 
      end
    end

    if frame.rolls == 2 
      frame.closed = true
      @frame_idx += 1      
    end
  end

  def score
    handle_score_errors
    total = 0
    for idx in 0...10
      frame = @frames[idx]
      total += frame.points.sum
      if frame.strike
        total += score_strike(idx + 1)
      elsif frame.spare
        next_frame = @frames[idx + 1]
        total += next_frame.points[0]
      end
    end
    total 
  end

  def score_strike(next_frame_idx)
    next_frame = @frames[next_frame_idx]
    sum = next_frame.points[0]
    if next_frame.strike
      sum += @frames[next_frame_idx + 1].points[0]
    else 
      sum += next_frame.points[1]
    end
  end

  def handle_roll_errors(pins)
    raise Game::BowlingError if @frames[9].strike && @frames.slice(10,11).sum{|frame| frame.points.size} > 1
    raise Game::BowlingError if @frames[9].spare && @frames[10].points.size > 0
    raise Game::BowlingError if @frame_idx > 9 && !(@frames[9].spare || @frames[9].strike)
    raise Game::BowlingError, "Pins cannot be greater than 10 or less than 0" if pins < 0 || pins > 10
  end

  def handle_score_errors
    raise Game::BowlingError if @frames[10].points.size == 0 &&  (@frames[9].spare || @frames[9].strike)
    if @frames[9].strike
      raise Game::BowlingError if @frames.slice(10,11).sum{|frame| frame.points.size} < 2
    end 
    raise Game::BowlingError if @frame_idx < 10
  end
end

class Frame
  def initialize
    @closed = false
    @rolls = 0 
    @points = []
    @strike = false
    @spare = false

  end
  attr_accessor :closed
  attr_accessor :rolls
  attr_accessor :points
  attr_accessor :strike
  attr_accessor :spare
end
