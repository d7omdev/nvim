return {
  {
    "nvim-mini/mini.hipatterns",
    event = "BufReadPre",
    opts = function()
      local hi = require("mini.hipatterns")

      -- Helper function to convert OKLCH to RGB
      local function oklch_to_rgb(l, c, h)
        -- Convert to OKLab
        local a = c * math.cos(math.rad(h))
        local b = c * math.sin(math.rad(h))

        -- OKLab to linear RGB (simplified conversion)
        local l_ = l + 0.3963377774 * a + 0.2158037573 * b
        local m_ = l - 0.1055613458 * a - 0.0638541728 * b
        local s_ = l - 0.0894841775 * a - 1.2914855480 * b

        local l3 = l_ * l_ * l_
        local m3 = m_ * m_ * m_
        local s3 = s_ * s_ * s_

        local r = 4.0767416621 * l3 - 3.3077115913 * m3 + 0.2309699292 * s3
        local g = -1.2684380046 * l3 + 2.6097574011 * m3 - 0.3413193965 * s3
        local b_ = -0.0041960863 * l3 - 0.7034186147 * m3 + 1.7076147010 * s3

        -- Clamp and convert to 0-255
        local function clamp(x)
          return math.max(0, math.min(1, x))
        end

        r = math.floor(clamp(r) * 255 + 0.5)
        g = math.floor(clamp(g) * 255 + 0.5)
        b_ = math.floor(clamp(b_) * 255 + 0.5)

        return string.format("#%02x%02x%02x", r, g, b_)
      end

      return {
        highlighters = {
          -- Highlight hex colors
          hex_color = hi.gen_highlighter.hex_color(),

          -- Highlight OKLCH colors
          oklch = {
            pattern = "oklch%([^%)]+%)",
            group = function(_, match)
              -- Extract L, C, H values
              local l, c, h = match:match("oklch%(%s*([%d%.]+)%%?%s+([%d%.]+)%s+([%d%.]+)")

              if not l then
                -- Try with alpha channel
                l, c, h = match:match("oklch%(%s*([%d%.]+)%%?%s+([%d%.]+)%s+([%d%.]+)%s*/")
              end

              if not l or not c or not h then
                return nil
              end

              l = tonumber(l)
              c = tonumber(c)
              h = tonumber(h)

              if not l or not c or not h then
                return nil
              end

              -- Normalize lightness to 0-1 if it's a percentage
              if match:match("%%") then
                l = l / 100
              end

              local hex = oklch_to_rgb(l, c, h)
              return hi.compute_hex_color_group(hex, "bg")
            end,
            extmark_opts = { priority = 2000 },
          },
        },
      }
    end,
  },
}
