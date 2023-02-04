local item_page = {}

local utils = requirep('genwiki', 'utils.lua')

local function titleCase(phrase)
    phrase = string.replace(phrase, '_', ' ')
    local result = string.gsub( phrase, "(%a)([%w_']*)",
        function(first, rest)
            return first:upper() .. rest:lower()
        end
    )
    return result
end


local function recipeTable(page, recipe)
    local out = '<table class="table table-sm table-bordered">'
    out = out .. '<tr><th>Item</th><th>Count</th></tr>'
    for _, ingredient in ipairs(recipe.ingredients) do
        out = out .. '<tr><td>' .. page:a('item/' .. ingredient.item, ingredient.item) .. '</td><td>' .. ingredient.count .. '</td></tr>'
    end
    out = out .. '</table>'
    return out
end

local function attributesTable(page, attributes)
    local out = '<table class="table table-sm">'
    for _, key in ipairs(attributes:keys()) do
        out = out .. '<tr><th><code>' .. key .. '</code></th><td><code>' .. to_str(attributes[key]) .. '</code></td></tr>'
    end
    out = out .. '</table>'
    return out
end

local function listHTML(list)
    local out = '<ul>'
    for _, trait in ipairs(list) do
        out = out .. '<li>' .. trait .. '</li>'
    end
    out = out .. '</ul>'
    return out
end

local function traitInfo(page, item, trait)
    local out = '<h4>' .. trait.name .. '</h4><br />'
    local stats = trait.stats
    if #keys(stats) > 0 then
        out = out .. '<ul>'
        for _, stat in pairs(trait.stats) do
            out = out .. '<li>'

            local icon = stat.icon
            local icon_v = Visual.new()
            icon_v.sprite = icon
            icon_v.color = Color.fromStr('black'):native()
            out = out .. utils.spriteHTML(page, icon_v)

            out = out .. '&nbsp;<b>' .. stat.name .. '</b>'
            if stat.has_value then
                local value = item.attr[stat.key]
                if value == nil then
                    out = out .. ': <i>none</i>'
                else
                    out = out .. ': ' .. item.attr[stat.key]
                end
            end
            out = out .. '</li>'
        end
        out = out .. '</ul>'

    end
    return out
end


function item_page.makeItemPage(page, item_id)
    local item = game.items.makeItem(item_id)
    local spriteHTML = utils.spriteHTML
    local listHTML = listHTML

    -- Navbar
    table.insert(page.nav_items, page:a('items', 'Items'))

    local quick_facts = f[[
        <div class="card">
            <div class="card-header">
                {item.name}
            </div>
            <div class="center" style="padding:1em">
                {spriteHTML(page, item.visual, 7, "class='card-img-top'")}
            </div>
            <div class="card-body" style="border-top: solid 1px #ccc">
                <b>ID:</b> {item_id}
            </div>
            <div class="card-body" style="border-top: solid 1px #ccc">
                <h6>Traits</h6>
                {listHTML(keys(item.traits))}
            </div>
            <div class="card-body" style="border-top: solid 1px #ccc">
                <h6>Actions</h6>
                {listHTML(item:getActions())}
            </div>
        </div>
    ]]
    
    page:add('<hr>')
    page:add([[
        <div class="row">
            <div class="col-lg-8">
    ]])
    page:add(f'<h3>{item.name}</h3>')
    page:add(f'<p>{item.desc}</p>')


    local recipes = game.items.findRecipes(item_id)
    if #recipes > 0 then
        page:add('<h3>Crafting</h3>')
        for _, recipe in ipairs(recipes) do
            page:add('This item is crafted at a ' ..  
                     page:a('workbench/' .. recipe.workbench, recipe.workbench) ..
                     '. It yeilds ' .. recipe.count .. ' item')
            if recipe.count > 1 then page:add('s') end
            page:add('.<br /><br />')

            page:add(recipeTable(page, recipe))
        end
    end

    local traits = item.traits
    if #keys(traits) > 0 then
        page:add('<h3>Traits</h3>')
        for _, trait in pairs(traits) do
            page:add(traitInfo(page, item, trait))
        end
    end

    page:add('<h3>Default Attributes</h3>')
    page:add(attributesTable(page, item.attr))

    page:add([[
            </div>
            <div class="col">
    ]])

    page:add(quick_facts);

    page:add([[
            </div>
        </div>
    ]])

    page:write()
end

return item_page