local utils = pandoc.utils

local function bold_name_in_inlines(inlines)
  local out = pandoc.List:new()
  local i = 1

  local function add_strong(text)
    out:insert(pandoc.Strong({ pandoc.Str(text) }))
  end

  while i <= #inlines do
    local a, b, c = inlines[i], inlines[i+1], inlines[i+2]

    -- Pattern: Émile Vadboncoeur(,?)
    if a and b and c
      and a.t == "Str" and a.text == "Émile"
      and b.t == "Space"
      and c.t == "Str" and c.text:match("^Vadboncoeur") then
        local suffix = c.text:sub(#"Vadboncoeur" + 1) -- keep punctuation like comma
        add_strong("Émile Vadboncoeur")
        if suffix ~= "" then out:insert(pandoc.Str(suffix)) end
        i = i + 3

    -- Pattern: É. Vadboncoeur(,?)
    elseif a and b and c
      and a.t == "Str" and a.text == "É."
      and b.t == "Space"
      and c.t == "Str" and c.text:match("^Vadboncoeur") then
        local suffix = c.text:sub(#"Vadboncoeur" + 1)
        add_strong("É. Vadboncoeur")
        if suffix ~= "" then out:insert(pandoc.Str(suffix)) end
        i = i + 3

    -- Pattern: Vadboncoeur, Émile(,?)
    elseif a and b and c
      and a.t == "Str" and a.text:match("^Vadboncoeur,?$")
      and b.t == "Space"
      and c.t == "Str" and (c.text == "Émile" or c.text == "Émile," or c.text == "É." or c.text == "É.,") then
        local last = a.text
        local suffix = c.text:sub(#(c.text:gsub(",","")) + 1)
        add_strong(last .. " " .. c.text:gsub(",",""))
        if suffix ~= "" then out:insert(pandoc.Str(suffix)) end
        i = i + 3

    else
      out:insert(a)
      i = i + 1
    end
  end

  return out
end

local function bold_in_block(block)
  return pandoc.walk_block(block, {
    Para = function(p)
      p.content = bold_name_in_inlines(p.content)
      return p
    end,
    Plain = function(p)
      p.content = bold_name_in_inlines(p.content)
      return p
    end
  })
end

local function year_from_block(block)
  local t = utils.stringify(block)
  -- Try to grab the bibliography year (the first "YYYY." in the entry)
  local y = t:match("(%d%d%d%d)%.%s") or t:match("(%d%d%d%d)%.")
  return tonumber(y) or 0
end

return {
  Div = function(div)
    if not (div.identifier == "refs" or div.classes:includes("references")) then
      return nil
    end

    -- Collect + bold
    local groups = {}
    for _, blk in ipairs(div.content) do
      local b = bold_in_block(blk)
      local y = year_from_block(b)
      groups[y] = groups[y] or pandoc.List:new()
      groups[y]:insert(b)
    end

    -- Sort years descending
    local years = {}
    for y,_ in pairs(groups) do
      if y ~= 0 then table.insert(years, y) end
    end
    table.sort(years, function(a,b) return a > b end)

    -- Rebuild bibliography with year headings (### 2025, ### 2024, ...)
    local new_content = pandoc.List:new()
    for _, y in ipairs(years) do
      new_content:insert(pandoc.Header(3, tostring(y)))
      for _, blk in ipairs(groups[y]) do
        new_content:insert(blk)
      end
    end

    div.content = new_content
    return div
  end
}
