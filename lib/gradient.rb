class Gradient
  attr_accessor :resolution, :R0, :G0, :B0, :R1, :G1, :B1

  def initialize(start, stop, resolution)
    @resolution = Float(resolution)

    @R0 = (start & 0xff0000) >> 16;
    @G0 = (start & 0x00ff00) >> 8;
    @B0 = (start & 0x0000ff) >> 0;

    @R1 = (stop & 0xff0000) >> 16;
    @G1 = (stop & 0x00ff00) >> 8;
    @B1 = (stop & 0x0000ff) >> 0;
  end

  def gradient(step_interval)
    r = interpolate(@R0, @R1, step_interval);
    g = interpolate(@G0, @G1, step_interval);
    b = interpolate(@B0, @B1, step_interval);

    (((r << 8) | g) << 8) | b;
  end

  def interpolate(start, stop, step_interval)
    if (start < stop)
      return (((stop - start) * (step_interval / @resolution)) + start).round;
    else
      return (((start - stop) * (1 - (step_interval / @resolution))) + stop).round;
    end
  end
end
