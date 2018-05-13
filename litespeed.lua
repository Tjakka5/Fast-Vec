local Ffi = require("ffi")
local Bit = require("bit")

-- Local references for quicker access
local sqrt     = math.sqrt
local cos, sin = math.cos, math.sin
local atan2    = math.atan2

local Litespeed = {}
Litespeed.proto = Ffi.metatype([[
   struct {
      double x;
      double y;
   }
]], Litespeed)
Litespeed.sizeof = Ffi.sizeof(Litespeed.proto)

--- Checks if the object is a Vector.
-- @param v The object to check
-- @returns True if the object is a Vector. False otherwise
function Litespeed.isVector(v)
   return type(v) == "cdata" and v.x and v.y and true
end
local isVector = Litespeed.isVector

--- Creates a new Vector.
-- @param x The x component
-- @param y The y component
-- @returns The new Vector
function Litespeed.new(x, y)
   return Litespeed.proto(x, y)
end
local new = Litespeed.new

--- Creates a new Vector from a table.
-- @param t The table in the format {[1] = x, [2] = y}
-- @returns The new Vector
function Litespeed.fromArray(t)
   if type(t) == "table" and type(t[1]) == "number" and type(t[2]) == "number" then
      return Litespeed.proto(t[1], t[2])
   end
end 

-- Creates a new Vector from an angle and radius.
-- @param angle The angle of the Vector
-- @param radius Optional argument of the Vectors size.
-- @retursn The new Vector
function Litespeed.fromPolar(angle, radius)
   radius = radius or 1
   return Litespeed.proto(radius * cos(angle), radius * sin(angle))
end

--- Returns the x and y components of the Vector.
-- @returns x, y
function Litespeed:unpack()
   return self.x, self.y
end

--- Sets the x and y components in a Vector.
-- @param x The x component
-- @param y The y component
-- @returns self
function Litespeed:set(x, y)
   self.x = x or self.x
   self.y = y or self.y

   self._flags = 0

   return self
end

--- Adds a, b to the Vector
-- @param a The x component or the Vector to add
-- @param b the y component or nil
-- @returns self
function Litespeed:add(a, b)
   if isVector(a) then
      self.x = self.x + a.x
      self.y = self.y + a.y
   else
      self.x = self.x + a or 0
      self.y = self.y + b or 0
   end

   return self
end

function Litespeed:sub(a, b)
end

function Litespeed:mul(a, b)
end

function Litespeed:div(a, b)
end

function Litespeed:addTo(a, b, t)
end

function Litespeed:subTo(a, b, t)
end

function Litespeed:divTo(a, b, t)
end

function Litespeed:mulTo(a, b, t)
end

function Litespeed:distance(o)

end

function Litespeed:distance2(o)

end

function Litespeed:normalize()

end

function Litespeed:rotate(phi)
end

function Litespeed:rotated(phi)
end

--- Creates a temporary table with the Vector's components for Shader:send
-- @param out Optional table to fill
-- @returns A temporary table in the format {[1] = x, [2] = y}
local defOut = {0, 0}
function Litespeed:send(out)
   out = out or defOut

   out[1] = self.x
   out[2] = self.y
   
   return out
end

--- Creates a copy of the Vector
-- @returns A Vector with the same componnets as the original
function Litespeed:copy()
   local copy = Litespeed.proto()
   Ffi.copy(copy, self, Litespeed.sizeof)

   return copy
end

function Litespeed.__unm(a, b)
end

function Litespeed.__add(a, b)
   if isVector(a) then
      if isVector(b) then
         -- Vector + Vector
      elseif type(b) == "number" then
         -- Vector + Number
      else
         -- Vector + ?
         error("Vector + ? u fucked up")
      end
   elseif type(a) == "number" then
      -- Number + Vector
   else
      -- ? + Vector
      error("? + Vector u fucked up")
   end
end

function Litespeed.__sub(a, b)
end

function Litespeed.__mul(a, b)
end

function Litespeed.__div(a, b)
end

function Litespeed.__mod(a, b)
end

function Litespeed.__pow(a, b)
end

function Litespeed.__eq(a, b)
end

function Litespeed.__lt(a, b)
end

function Litespeed.__le(a, b)
end

--- Formats the Vector as a string.
-- @returns A string in the format: [x, y]
function Litespeed.__tostring(v)
   return string.format("[%g, %g]", v.x, v.y)
end

-- Responsible for getting special values of the Vector
function Litespeed.__index(v, key)
   -- Propagate function calls
   if Litespeed[key] then
      return Litespeed[key]
   end

   if key == "length" then
      return sqrt(v.x * v.x + v.y * v.y)
   elseif key == "length2" then
      return v.x * v.x + v.y * v.y
   elseif key == "angle" then
      return atan2(v.y, v.x)
   elseif key == "normalized" then
      local length = sqrt(v.x * v.x + v.y * v.y)
      
      return new(v.x / length, v.y / length)
   elseif key == "perpendicular" then
      return new(-v.y, v.x)
   end
end

-- Responsible for setting special values of the Vector
function Litespeed.__newindex(v, key, value)
   if key == "length" then
      local length = sqrt(v.x * v.x + v.y * v.y)
      
      v.x = v.x / length * value
      v.y = v.y / length * value
   elseif key == "angle" then
      local length = v.length

      v.x = length * cos(value)
      v.y = length * sin(value)
   else
      -- Allow the user to still edit the Vector
      rawset(v, key, value)
   end
end

-- Basic Vectors that can be used for simple math
Litespeed.zero  = new( 0,  0)
Litespeed.one   = new( 1,  1)
Litespeed.up    = new( 0, -1)
Litespeed.down  = new( 0,  1)
Litespeed.left  = new(-1,  0)
Litespeed.right = new( 1,  0)

-- Return the module
return setmetatable(Litespeed, {
   __call = function(_, x, y) return new(x, y) end,
})