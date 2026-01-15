str = pandoc.utils.stringify

local function highlight_author_filter(auths)
  return {
    Para = function(el)
      for k,_ in ipairs(el.content) do
        for _, val in ipairs(auths) do
          local first_part = val.family .. ","
          local full = val.family .. ", " .. val.given

          -- split given into pieces (e.g., "É." or "E. V.")
          local given_initials = {}
          for w in val.given:gmatch("%S+") do
            table.insert(given_initials, w)
          end

          if #given_initials == 1 then
            if el.content[k].t == "Str" and el.content[k].text == first_part
              and el.content[k+1] and el.content[k+1].t == "Space"
              and el.content[k+2] and el.content[k+2].t == "Str"
              and el.content[k+2].text:find(given_initials[1]) then
                local _,e = el.content[k+2].text:find(given_initials[1])
                local rest = el.content[k+2].text:sub(e+1)
                el.content[k] = pandoc.Strong { pandoc.Str(full) }
                el.content[k+1] = pandoc.Str(rest)
                table.remove(el.content, k+2)
            end
          end
        end
      end
      return el
    end
  }
end

local function get_auth_name(auths)
  return {
    Meta = function(m)
      if m['bold-auth-name'] == nil then return end
      for _, val in ipairs(m['bold-auth-name']) do
        table.insert(auths, { family = str(val.family), given = str(val.given) })
      end
    end
  }
end

local function highlight_author_name(auths)
  return {
    Div = function(el)
      if el.classes:includes("references") then
        return el:walk(highlight_author_filter(auths))
      end
    end
  }
end

function Pandoc(doc)
  local bold_auth_name = {}
  doc:walk(get_auth_name(bold_auth_name))
  return doc:walk(highlight_author_name(bold_auth_name))
end
