local sys = game.sys

local Page = require_pkg('Page.lua')
local item_page = requirep('genwiki', 'item_page.lua')
local utils = requirep('genwiki', 'utils.lua')


local function itemTable(page, item_ids)
    local items_table = [[
        <table border="1" cellpadding="2" cellspacing="0" style="border-collapse:collapse;">
        <tr>
            <th><!--Sprite--></th>
            <th>Name</th>
            <th>Traits</th>
            <th>Workbench</th>
        </tr>
    ]]
    for _, item_id in ipairs(item_ids) do
        if item_id:sub(1,1) ~= '_' and #item_id > 1 then
            local item = game.items.makeItem(item_id)
            local sprite = utils.spriteHTML(page, item.visual)

            local traits = ''
            for _,trait in ipairs(keys(item.traits)) do
                traits = traits .. page:a(f'trait/{trait}', trait) .. '<br />'
            end

            local workbench_ids = game.items.findRecipes(item_id)
            workbench_ids = list.map(workbench_ids, function(r) return r.workbench end)
            workbench_ids = list.unique(workbench_ids)
            local workbench = ''
            for _, wb in ipairs(workbench_ids) do
                workbench = workbench .. page:a(f'workbench/{wb}', wb) .. '<br />'
            end

            local item_link = page:a(f'item/{item_id}', item.attr.name)
            items_table = items_table .. f[[<tr>
                <td>{sprite}</td>
                <td>{item_link}</td>
                <td>{traits}</td>
                <td>{workbench}</td>
            </tr>]]
        end
    end
    items_table = items_table .. '</table>'
    return items_table
end

--
-- Items
--
local function genItemsPages()
    local page = Page('items', 'Items')

    -- Generate table
    page:add(itemTable(page, game.items.list()))
    page:write()

    -- Generate item pages
    sys.mkdir('wiki/item')
    for _, item_id in ipairs(game.items.list()) do
        local ip = Page(f'item/{item_id}', item_id)
        item_page.makeItemPage(ip, item_id)
        ip:write()
    end
end

--
-- Actors
--
local function genActorsPages()
    local page = Page('actors', 'Actors')

    -- Generate actor list page
    local actors_table = [[
        <table border="1" cellpadding="2" cellspacing="0" style="border-collapse:collapse;">
        <tr>
            <th>Name</th>
        </tr>
    ]]
    for _, actor_id in ipairs(game.actors.list()) do
        local actor_link = page:a(f'actor/{actor_id}', actor_id)
        if actor_id:sub(1,1) ~= '_' then
            actors_table = actors_table .. f[[<tr>
                <td>{actor_link}</a></td>
            </tr>]]
        end
    end
    actors_table = actors_table .. '</table>'
    page:add(actors_table)
    page:write()

    -- Generate actor pages
    sys.mkdir('wiki/actor')
    for _, actor_id in ipairs(game.actors.list()) do
        local actor_page = Page(f'actor/{actor_id}', actor_id)
        actor_page:add(actor_page:a('index', 'home') .. '<br />')
        actor_page:add(actor_id)
        actor_page:write()
    end
end


--
-- Tiles
--
local function genTilesPages()
    local page = Page('tiles', 'Tiles')

    -- Generate tile table
    local tiles_table = [[
        <table border="1" cellpadding="2" cellspacing="0" style="border-collapse:collapse;">
        <tr>
            <th></th>
            <th>Name</th>
            <th>#ID</th>
            <th>Solid</th>
            <th>Req. Solid</th>
            <th>Drops</th>
        </tr>
    ]]
    for _, tile_id in ipairs(game.tiles.list()) do
        local tile = game.tiles.fromID(tile_id)
        local tile_link = page:a(f'tile/{tile_id}', tile.display_name)
        local drops = {}
        for _, item in ipairs(tile.drops) do
            table.insert(drops, page:a(f'item/{item.id}', item.id))
        end
        drops = string.join(',', drops)
        if tile_id:sub(1,1) ~= '_' and #tile_id > 1 then
            local sprite = utils.spriteHTML(page, tile.sprite)
            tiles_table = tiles_table .. f[[<tr>
                <td>{sprite}</td>
                <td>{tile.num_id}</td>
                <td>{tile_link}</td>
                <td>{tile.is_solid}</td>
                <td>{tile.requires_solid_below}</td>
                <td>{drops}</td>
            </tr>]]
        end
    end
    tiles_table = tiles_table .. '</table>'
    page:add(tiles_table)
    page:add("<br/><hr/><br/>")

    -- Generate tile id list
    local tile_list = [[
        <table border="1" cellpadding="2" cellspacing="0" style="border-collapse:collapse;">
        <tr>
            <th>#</th>
            <th>id</th>
        </tr>
    ]]
    for i = 1,255 do
        if game.tiles.exists(i) then
            local tile = game.tiles.fromNumID(i)
            tile_list = tile_list .. f'<tr><td>{i}</td><td>{tile.id}</td></tr>'
        else
            tile_list = tile_list .. f'<tr><td>{i}</td><td></td></tr>'
        end
    end
    tile_list = tile_list .. '</table>'
    page:add(tile_list)



    page:write()

    -- Generate actor pages
    sys.mkdir('wiki/tile')
    for _, tile_id in ipairs(game.tiles.list()) do
        local tile_page = Page(f'tile/{tile_id}', tile_id)
        tile_page:add(tile_page:a('index', 'home') .. '<br />')
        tile_page:add(tile_id)
        tile_page:write()
    end
end

--
-- Workbenches
--

local function listWorkbenches()
    local workbench_ids = {}
    for _, item_id in ipairs(game.items.list()) do
        -- Get workbench list
        local wbs = game.items.findRecipes(item_id)
        wbs = list.map(wbs, function(r) return r.workbench end)
        -- Add to master list
        for _, wb in ipairs(wbs) do
            if not list.contains(workbench_ids, wb) then
                table.insert(workbench_ids, wb)
            end
        end
    end
    return workbench_ids
end

local function listItemsForWorkbench(workbench_id)
    local item_ids = {}
    for _, item_id in ipairs(game.items.list()) do
        local wbs = list.map(game.items.findRecipes(item_id), function(r) return r.workbench end) 
        if list.contains(wbs, workbench_id) then
            table.insert(item_ids, item_id)
        end
    end
    return item_ids
end


local function genWorkbenchPages()
    local page = Page('workbenches', 'Workbench')
    -- Generate table
    local workbench_list = listWorkbenches()
    local workbench_table = [[
        <table border="1" cellpadding="2" cellspacing="0" style="border-collapse:collapse;">
        <tr>
            <th>Name</th>
        </tr>
    ]]
    for _, workbench_id in ipairs(workbench_list) do
        local wb_link = page:a(f'workbench/{workbench_id}', workbench_id)
        if workbench_id:sub(1,1) ~= '_' then
            workbench_table = workbench_table .. f[[<tr>
                <td>{wb_link}</td>
            </tr>]]
        end
    end
    workbench_table = workbench_table .. '</table>'

    -- Workbench index
    page:add(workbench_table)
    page:write()

    -- Workbench pages item pages
    sys.mkdir('wiki/workbench')
    for _, workbench_id in ipairs(workbench_list) do
        local p = Page(f'workbench/{workbench_id}', workbench_id)
        p:add(itemTable(p, listItemsForWorkbench(workbench_id)))
        p:write()
    end
end

--
-- Traits
--


local function listTraits()
    local traits = {}
    for _, item_id in ipairs(game.items.list()) do
        -- Get workbench list
        local item_traits = keys(game.items.makeItem(item_id).traits)
        -- Add to master list
        for _, t in ipairs(item_traits) do
            if not list.contains(traits, t) then
                table.insert(traits, t)
            end
        end
    end
    return traits
end

local function genTraitPages()
    local page = Page('traits', 'Traits')
    -- Generate table
    local all_traits = listTraits()
    local trait_table = [[
        <table border="1" cellpadding="2" cellspacing="0" style="border-collapse:collapse;">
        <tr>
            <th>Name</th>
        </tr>
    ]]
    for _, trait in ipairs(all_traits) do
        local link = page:a(f'trait/{trait}', trait)
        if trait:sub(1,1) ~= '_' then
            trait_table = trait_table .. f[[<tr>
                <td>{link}</td>
            </tr>]]
        end
    end
    trait_table = trait_table .. '</table>'

    -- Trait index
    page:add(trait_table)
    page:write()

    -- Trait pages item pages
    sys.mkdir('wiki/trait')
    for _, trait in ipairs(all_traits) do
        local p = Page(f'trait/{trait}', trait)
        p:add(itemTable(p, game.items.listItemsWithTrait(trait)))
        p:write()
    end
end


local function genwiki()
    sys.mkdir('wiki')
    sys.mkdir('wiki/sprites')

    local index_page = Page('index', 'Wiki')
    index_page:add("<ul>")
    for _, id in ipairs({'items', 'actors', 'tiles', 'workbenches', 'traits'}) do
        local link = index_page:a(id, id)
        index_page:add(f'<li>{link}</li>')
    end
    index_page:add("</ul>")
    index_page:write()

    genItemsPages()
    genActorsPages()
    genTilesPages()
    genWorkbenchPages()
    genTraitPages()
end

return genwiki