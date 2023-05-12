--PHOBOSS--
--[[ 
function clampB(x, min, max) --benchmark speed: 0.076612 seconds
    return math.max(math.min(x, max), min)
end

function clampC(x, min, max) --benchmark speed: 0.030656 seconds
    return x < min and min or x > max and max or x
end

local n = 1e6
local function benchmarkingTimer(f, n)
  local clock = os.clock
  local before = clock()
  minn = -5
  maxx = 5
  for i=1,n do
    f(i,minn,maxx)
  end
  local after = clock()
  return after-before
end

print(string.format("clamp A took %f seconds", benchmarkingTimer(clampA, n)))
print(string.format("clamp B Took %f seconds", benchmarkingTimer(clampB, n)))
print(string.format("clamp C Took %f seconds", benchmarkingTimer(clampC, n)))
]]--

function clamp(x, min, max)--benchmark speed: 0.027751 seconds
    if x < min then return min end
    if x > max then return max end
    return x
end

--[[
-- fast but we can do without it returning 0
function sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end
]]--

--Thanks to rv55 from: https://stackoverflow.com/questions/1318220/lua-decimal-sign
function sign(x) --faster, caution: doesn't return 0
  return x<0 and -1 or 1
end

function clamp_vector3(vec,minn,maxx)
	return vector.new(clamp(vec.x,minn,maxx),clamp(vec.y,minn,maxx),clamp(vec.z,minn,maxx))
end

function sign_vector3(vec)
	return vector.new(sign(vec.x),sign(vec.y),sign(vec.z))
end

function abs_vector3(vec)
	return vector.new(math.abs(vec.x),math.abs(vec.y),math.abs(vec.z))
end

function roundTo(value,place)
	return math.floor(value * place)/place
end

function roundTo_vector3(value,place)
	return vector.new(math.floor(value.x * place)/place,math.floor(value.y * place)/place,math.floor(value.z * place)/place)
end

function round_vector3(value)
	return vector.new(math.floor(value.x + 0.5),math.floor(value.y + 0.5),math.floor(value.z + 0.5))
end

--distributed PWM redstone algorithm
--[[Thanks to NikZapp (discord)]]--
function pwm()
	return{
	last_output_float_error=vector.new(0,0,0),
	run=function(self,rs)
		pid_out_w_error = rs:add(self.last_output_float_error)
		output = round_vector3(pid_out_w_error)
		self.last_output_float_error = pid_out_w_error:sub(output)
		return output
	end
	}
end
