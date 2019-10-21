--https://pandoc.org/lua-filters.html

-- Links ----------------------------------------------------------------------
function Link(el)
  if FORMAT:match"html" then
    el.target = el.target:gsub("%.md$",".html")
  end
  return el
end

-- Kbd ------------------------------------------------------------------------
local kbd = '<span class="nowrap">%s</span>'
function Subscript(el)
  if FORMAT:match"html" then
    if #el.c==1 then
      return pandoc.RawInline("html",kbd:format(el.c[1].text:gsub("[^+]+","<kbd>%0</kbd>")))
    end
  else
    --return pandoc...
  end
  return el
end

-- Typographics ---------------------------------------------------------------
local typo = {
  ["=>"]="⟹",
  ["->"]="⟶",
  [">="]="≥",
  ["<="]="≤",
  ["~="]="≠",
  ["=="]="≡",
  ["%.%.%."]="…",
  ["-,"]="—,",
  ["-/"]="—/",
}

function Str(el)
  local text = el.text
  for k,v in pairs(typo) do
    text = text:gsub(k,typo)
  end
  if text=="-" then text = "—" end
  el.text = text
  return el
end

--⇒
--➡
--≤
--≥
--≠
--→
--"⟶"	U27F6 # LONG RIGHTWARDS ARROW
--"⟹"	U27F9 # LONG RIGHTWARDS DOUBLE ARROW


-- code blocks with numbered lines --------------------------------------------
local N = 4
function CodeBlock(el)
  if #el.classes==1 and select(2,el.text:gsub("\n","\n"))>=N then
    table.insert(el.classes,"numberLines")
  end
  return el
end

-- pagetitle from header ------------------------------------------------------
local function inlines_tostring (inlines) 
  local strs = {} 
  for i = 1, #inlines do 
    strs[i] = tostring(inlines[i]) 
  end 
  return table.concat(strs) 
end 

for k, v in pairs(pandoc.Inline.constructor) do 
  v.__tostring = function (inln) 
    return ((inln.content and inlines_tostring(inln.content)) 
        or (inln.caption and inlines_tostring(inln.caption)) 
        or (inln.text and inln.text) 
        or " ") 
  end
end

local title
function Header (el) 
  if not title and el.level==1 then
    title = inlines_tostring(el.content) 
  end
end 

function Meta(meta)
  meta.pagetitle = title
  return meta
end

function Div(el)
end