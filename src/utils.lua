local utils = {}


local function visualName(visual)
    return (visual.sprite .. 
            visual.color.r ..
            visual.color.g ..
            visual.color.b ..
            visual.overlay_sprite ..
            visual.overlay_color.r ..
            visual.overlay_color.g ..
            visual.overlay_color.b)
end

function utils.spriteHTML(page, visual, scale, tags)
    tags = tags or ''
    scale = scale or 1
    if type(visual) == 'number' then
        local s = visual -- sprite id
        visual = Visual.new()
        visual.sprite = s
    end

    local sprite_id = visual.sprite
    
    local sprite = game.sprites.getName(sprite_id)
    if sprite == '' then
        if sprite_id < 256 then
            sprite = '<b><code>' .. string.char(sprite_id) .. '</code></b>'
        else
            sprite = tostring('<code>' .. sprite_id .. '</code>')
        end
    else
        -- Copy the sprite image over
        sprite = visualName(visual)
        local sprite_img = game.sprites.compile(visual)
        local fname = f'{sprite}.png'
        fname = string.join('-', string.split(fname, '/'))
        local path = 'sprites/' .. fname
        sprite_img:write('wiki/' .. path)

        local link = page:link(path)
        local size = scale * 16
        sprite = f'<img src="{link}" width="{size}" height="{size}" />'
    end
    return sprite
end



return utils