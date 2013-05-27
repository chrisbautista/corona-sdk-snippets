--- Various useful curves.
--
-- A few of the curves are denoted as **_Shifted**. These shift the base
-- curve's domain: importantly, _t_ &isin; [0, 1] &rarr; [-1, +1].

--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--
-- [ MIT license: http://www.opensource.org/licenses/mit-license.php ]
--

-- Standard library imports --
local abs = math.abs
local ipairs = ipairs
local sin = math.sin
local sqrt = math.sqrt
local unpack = unpack

-- Exports --
local M = {}

--- Maps a 4-vector by the B�zier matrix.
-- TODO: DOCME more
function M.Bezier_Eval (coeffs, a, b, c, d)
	coeffs.a = a - 3 * (b - c) - d
	coeffs.b = 3 * (b - 2 * c + d)
	coeffs.c = 3 * (c - d)
	coeffs.d = d
end

-- "Inverted" eval functions --
-- General idea: Given geometry matrix [P1 P2 P3 P4], and eval matrix (i.e. what gets
-- multiplied by [a, b, c, d]), compute a row of the 2x4 product matrix. Reorder the
-- components (since the quadrature uses [t^3, t^2, t, 1], and drop the last one since
-- it gets culled by differentiation.
local Invert = {}

-- Inverted Bezier
Invert[M.Bezier_Eval] = function(a, b, c, d)
	local B = 3 * (b - a)
	local C = 3 * (a + c - 2 * b)
	local D = -a + 3 * (b - c) + d

	return D, C, B
end

--- Converts coefficients from B�zier to Hermite form.
-- (P1, Q1, Q2, P2) -> (P1, P2, T1, T2)
-- TODO: DOCME more
function M.BezierToHermite (src1, src2, src3, src4, dst1, dst2, dst3, dst4)
	dst1, dst2, dst3, dst4 = dst1 or src1, dst2 or src2, dst3 or src3, dst4 or src4

	local t1x, t1y = (src2.x - src1.x) * 3, (src2.y - src1.y) * 3
	local t2x, t2y = (src4.x - src3.x) * 3, (src4.y - src3.y) * 3

	dst1.x, dst1.y = src1.x, src1.y
	dst2.x, dst2.y = src4.x, src4.y
	dst3.x, dst3.y = t1x, t1y
	dst4.x, dst4.y = t2x, t2y
end

--- Converts coefficients from Catmull-Rom to Hermite form.
-- (P1, P2, P3, P4) -> (P2, P3, T1, T2)
-- TODO: DOCME more
function M.CatmullRomToHermite (src1, src2, src3, src4, dst1, dst2, dst3, dst4)
	dst1, dst2, dst3, dst4 = dst1 or src1, dst2 or src2, dst3 or src3, dst4 or src4

	local t1x, t1y = src3.x - src1.x, src3.y - src1.y
	local t2x, t2y = src4.x - src2.x, src4.y - src2.y

	dst1.x, dst1.y = src2.x, src2.y
	dst2.x, dst2.y = src3.x, src3.y
	dst3.x, dst3.y = t1x, t1y
	dst4.x, dst4.y = t2x, t2y
end


--- Maps a 4-vector by the Catmull-Rom matrix.
-- TODO: DOCME more
function M.CatmullRom_Eval (coeffs, a, b, c, d)
	coeffs.a = .5 * (-b + 2 * c - d)
	coeffs.b = .5 * (2 * a - 5 * c + 3 * d)
	coeffs.c = .5 * (b + 4 * c - 3 * d)
	coeffs.d = .5 * (-c + d)
end

-- Inverted Catmull-Rom
Invert[M.CatmullRom_Eval] = function(a, b, c, d)
	local B = .5 * (-a + c)
	local C = .5 * (2 * a - 5 * b + 4 * c - d)
	local D = .5 * (-a + 3 * (b - c) + d)

	return D, C, B
end

--- Evaluates curve coefficents, for use with @{M.MapToCurve}.
-- @callable eval Evaluator function, with signature as per @{M.Bezier_Eval}.
-- @param pos If present, position coefficients to evaluate at _t_.
-- @param tan If present, tangent to evaluate at _t_.
-- number t Time along curve, &isin [0, 1].
-- TODO: Meaningful types for above?
function M.EvaluateCurve (eval, pos, tan, t)
	local t2 = t * t

	if pos then
		eval(pos, 1, t, t2, t2 * t)
	end

	if tan then
		eval(tan, 0, 1, 2 * t, 3 * t2)
	end
end

--- Computes a figure 8 displacement.
--
-- The underlying curve is a [Lissajous figure](http://en.wikipedia.org/wiki/Lissajous_figure)
-- with a = 1, b = 2, &delta; = 0.
-- @number angle An angle, in radians.
-- @treturn number Unit x-displacement...
-- @treturn number ...and y-displacement.
function M.Figure8 (angle)
	return sin(angle), sin(angle * 2)
end

--- Maps a 4-vector by the Hermite matrix.
-- TODO: DOCME more
function M.Hermite_Eval (coeffs, a, b, c, d)
	coeffs.a = a - 3 * c + 2 * d
	coeffs.b = 3 * c - 2 * d
	coeffs.c = b - 2 * c + d
	coeffs.d = -c + d
end

-- Inverted Hermite
Invert[M.Hermite_Eval] = function(a, b, c, d)
	local B = c
	local C = 3 * (b - a) - 2 * c - d
	local D = 2 * (a - b) + c + d

	return D, C, B
end

-- Tangent scale factor --
local Div = 1 / 3

--- Converts coefficients from Hermite to B�zier form.
-- (P1, P2, T1, T2) -> (P1, Q1, Q2, P2)
-- DOCME more
function M.HermiteToBezier (src1, src2, src3, src4, dst1, dst2, dst3, dst4)
	dst1, dst2, dst3, dst4 = dst1 or src1, dst2 or src2, dst3 or src3, dst4 or src4

	local q1x, q1y = src1.x + src3.x * Div, src1.y + src3.y * Div
	local q2x, q2y = src2.x - src4.x * Div, src2.y - src4.y * Div

	dst1.x, dst1.y = src1.x, src1.y
	dst4.x, dst4.y = src2.x, src2.y
	dst2.x, dst2.y = q1x, q1y
	dst3.x, dst3.y = q2x, q2y
end

--- Converts coefficients from Hermite to Catmull-Rom form.
-- (P1, P2, T1, T2) -> (P0, P1, P2, P3)
-- DOCME more
function M.HermiteToCatmullRom (src1, src2, src3, src4, dst1, dst2, dst3, dst4)
	dst1, dst2, dst3, dst4 = dst1 or src1, dst2 or src2, dst3 or src3, dst4 or src4

	local p1x, p1y = src2.x - src3.x, src2.y - src3.y
	local p4x, p4y = src4.x - src1.x, src4.y - src1.y

	dst3.x, dst3.y = src2.x, src2.y
	dst2.x, dst2.y = src1.x, src1.y
	dst1.x, dst1.y = p1x, p1y
	dst4.x, dst4.y = p4x, p4y
end

-- Length via quadrature
do
	local Poly = {}

	--
	local function Length (t)
		return sqrt(t * (t * (t * (t * Poly[1] + Poly[2]) + Poly[3]) + Poly[4]) + Poly[5])
	end

	-- Quadrature offsets and weights --
	local X = { 0.1488743389, 0.4333953941, 0.6794095692, 0.8650633666, 0.9739065285 }
	local W = { 0.2966242247, 0.2692667193, 0.2190863625, 0.1494513491, 0.0666713443 }

	--
	local function Integrate (t1, t2)
		local midt = .5 * (t1 + t2)
		local diff = .5 * (t2 - t1)
		local len = 0

		for i = 1, 5 do
			local dx = diff * X[i]

			len = len + W[i] * (Length(midt - dx) + Length(midt + dx))
		end

		return len * diff
	end

	--
	local function Subdivide (t1, t2, len, tolerance)
		local midt = .5 * (t1 + t2)
		local llen = Integrate(t1, midt)
		local rlen = Integrate(midt, t2)

		if abs(len - (llen + rlen)) > tolerance then
			return Subdivide(t1, midt, llen, tolerance) + Subdivide(midt, t2, rlen, tolerance)
		else
			return llen + rlen
		end
	end

	--- Computes a curve length
	-- @callable eval Evaluator function
	-- @param coeffs Control coefficients
	-- @number t1 Parameter #1
	-- @number t2 Parameter #2
	-- @number tolerance Evaluation tolerance
	-- @treturn number Length of curve
	-- TODO: DOCME better
	function M.CurveLength (eval, coeffs, t1, t2, tolerance)
		local inverted, a, b, c, d = Invert[eval], unpack(coeffs)

		-- Given curve Ax^3 + Bx^2 + Cx + D, the derivative is 3Ax^2 + 2Bx + C, which
		-- when squared (in the arc length formula) yields these coefficients. 
		local ax, bx, cx = inverted(a.x, b.x, c.x, d.x)
		local ay, by, cy = inverted(a.y, b.y, c.y, d.y)

		Poly[1] = 9 * (ax * ax + ay * ay)
		Poly[2] = 12 * (ax * bx + ay * by)
		Poly[3] = 6 * (ax * cx + ay * cy) + 4 * (bx * bx + by * by)
		Poly[4] = 4 * (bx * cx + by * cy)
		Poly[5] = cx * cx + cy * cy

		return Subdivide(t1, t2, Integrate(t1, t2), tolerance)
	end
end

-- Length via split method
do
	--[[
		Adapted from Earl Boebert, http://steve.hollasch.net/cgindex/curves/cbezarclen.html

		The last suggestion by Gravesen is pretty nifty, and I think it's a candidate for the
		next Graphics Gems. I hacked out the following quick implementation, using the .h and
		libraries definitions from Graphics Gems I (If you haven't got that book then you have
		no business mucking with with this stuff :-)) The function "bezsplit" is lifted
		shamelessly from Schneider's Bezier curve-fitter.
	]]

	-- --
	local Temp = {}

	for i = 1, 4 do
		Temp[i] = {}

		for j = 1, 4 do
			Temp[i][j] = j <= 5 - i and {}
		end
	end

	-- --
	local V, Top = {}

	--
	local function AddPoint (point)
		V[Top + 1], V[Top + 2], Top = point.x, point.y, Top + 2
	end

	-- Split a cubic bezier in two
	local function BezSplit ()
		-- Copy control points.
		local base = Top + 1

		for _, temp in ipairs(Temp[1]) do
			temp.x, temp.y, base = V[base], V[base + 1], base + 2
		end

		-- Triangle computation.
		local prev_row = Temp[1]

		for i = 2, 4 do
			local row = Temp[i]

			for j = 1, 5 - i do
				local r, pr1, pr2 = row[j], prev_row[j], prev_row[j + 1]

				r.x, r.y = .5 * (pr1.x + pr2.x), .5 * (pr1.y + pr2.y)
			end

			prev_row = row
		end

		-- L
		for i = 1, 4 do
			AddPoint(Temp[i][1])
		end

		-- R
		for i = 1, 4 do
			AddPoint(Temp[5 - i][i])
		end
	end

	-- Add polyline length if close enough
	local function AddIfClose (length, err)
		Top = Top - 8

		local base = Top + 1
		local x, y = V[base], V[base + 1]
		local dx, dy = V[base + 6] - x, V[base + 7] - y

		local len, main_len = 0, sqrt(dx * dx + dy * dy)

		for _ = 1, 3 do
			dx, dy = V[base + 2] - x, V[base + 3] - y
			len = len + sqrt(dx * dx + dy * dy)
			base, x, y = base + 2, x + dx, y + dy
		end

		--
		if len - main_len > err then
			BezSplit()

			local ll = AddIfClose(length, err)
			local lr = AddIfClose(length, err)
			
			len = ll + lr
		end

		return len
	end

	--- Computes a B�zier curve's length
	-- @param coeffs Control coefficients
	-- @number tolerance Evaluation tolerance
	-- @treturn number Length of curve
	-- TODO: DOCME better
	function M.BezierLength (coeffs, tolerance)
		Top = 0

		for i = 1, 4 do
			AddPoint(coeffs[i])
		end

		return AddIfClose(0, tolerance)
	end
end

--- Given some pre-computed coefficients, maps vectors to a curve.
-- @param coeffs Coefficients generated e.g. by @{M.EvaluateCurve}.
-- @param a Vector #1...
-- @param b ...#2...
-- @param c ...#3...
-- @param d ...and #4.
-- @treturn number Curve x-coordinate...
-- @treturn number ...and y-coordinate.
-- TODO: Meaningful types
function M.MapToCurve (coeffs, a, b, c, d)
	local x = coeffs.a * a.x + coeffs.b * b.x + coeffs.c * c.x + coeffs.d * d.x
	local y = coeffs.a * a.y + coeffs.b * b.y + coeffs.c * c.y + coeffs.d * d.y

	return x, y
end

-- Remaps a curve's domain (namely, [0, 1] -> [-1, +1])
local function Remap (curve)
	return function(t)
		return curve(2 * (t - .5))
	end
end

-- Remap that always uses a positive time
local function RemapAbs (curve)
	return function(t)
		return curve(2 * abs(t - .5))
	end
end

---@number t Curve parameter.
-- @treturn number 1 - _t_ &sup2;.
function M.OneMinusT2 (t)
	return 1 - t * t
end

--- Shifted variant of @{OneMinusT2}.
-- @function OneMinusT2_Shifted
-- @number t Curve parameter.
-- @treturn number 1 - _t'_ &sup2;.
M.OneMinusT2_Shifted = Remap(M.OneMinusT2)

---@number t Curve parameter.
-- @treturn number 1 - _t_ &sup3;.
function M.OneMinusT3 (t)
	return 1 - t * t * t
end

--- Shifted variant of @{OneMinusT3}
-- @function OneMinusT3_Shifted
-- @number t Curve parameter.
-- @treturn number 1 - _t'_ &sup3;.
M.OneMinusT3_Shifted = Remap(M.OneMinusT3)

--- Shifted positive variant of @{OneMinusT3}.
-- @function OneMinusT3_ShiftedAbs
-- @number t Curve parameter.
-- @treturn number 1 - |_t'_| &sup3;.
M.OneMinusT3_ShiftedAbs = RemapAbs(M.OneMinusT3)

--- A curve used in [Improved Perlin noise](http://mrl.nyu.edu/~perlin/paper445.pdf).
-- @number t Curve parameter.
-- @treturn number Curve value at _t_.
function M.Perlin (t)
	return t * t * t * (t * (t * 6 - 15) + 10)
end

-- Remaps a curve's domain (namely, [-1, +1] -> [0, 1])
local function Narrow (t)
	return 2 * t - 1
end

--- A cubic curve with double point, cf. [Wikipedia](http://en.wikipedia.org/wiki/File:Cubic_with_double_point.svg).
-- @number t Curve parameter. (**N.B.** Remapped s.t. [-1, +1] &rarr; [0, 1].)
-- @treturn number Unit x-displacement...
-- @treturn number ...and y-displacement.
function M.SingularCubic (t)
	t = Narrow(t)

	local x = -M.OneMinusT2(t)

	return x, t * x
end

-- Cached coefficient --
local Sqrt3 = math.sqrt(3)

--- The [Tschirnhausen cubic](http://en.wikipedia.org/wiki/Tschirnhausen_cubic), with a = 1.
-- @number t Curve parameter. (**N.B.** Remapped s.t. [-&radic;3, +&radic;3] &rarr; [0, 1].)
-- @treturn number Unit x-displacement...
-- @treturn number ...and y-displacement.
function M.Tschirnhausen (t)
	t = Narrow(t)

	local x = 3 - M.T2(Sqrt3 * t)

	return 3 * x, t * x
end

---@number t Curve parameter.
-- @treturn number _t_ &sup2;.
function M.T2 (t)
	return t * t
end

--- Shifted variant of @{T2}.
-- @function T2_Shifted
-- @number t Curve parameter.
-- @treturn number _t'_ &sup2;.
M.T2_Shifted = Remap(M.T2)

---@number t Curve parameter.
-- @treturn number _t_ &sup3;.
function M.T3 (t)
	return t * t * t
end

--- Shifted variant of @{T3}.
-- @function T3_Shifted
-- @number t Curve parameter.
-- @treturn number _t'_ &sup3;.
M.T3_Shifted = Remap(M.T3)

--- Shifted positive variant of @{T3}.
-- @function T3_ShiftedAbs
-- @number t Curve parameter.
-- @treturn number |_t'_| &sup3;.
M.T3_ShiftedAbs = RemapAbs(M.T3)

--- DOCME
-- @callable curve
-- @number t
-- @number dt
-- @treturn number X
-- @treturn number Y
function M.UnitTangent (curve, t, dt)
	dt = dt or .015

	local x1, y1 = curve(t - dt)
	local x2, y2 = curve(t + dt)
	local dx, dy = x2 - x1, y2 - y1
	local len = sqrt(dx * dx + dy * dy)

	return dx / len, dy / len
end

-- Export the module.
return M
--[[
-- TODO: Try Romberg? http://www.geometrictools.com/Documentation/NumericalIntegration.pdf
]]