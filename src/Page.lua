local sys = game.sys
local Page = Object:extend()

function Page:new(path, name)
    self.path = path
    self.name = name
    self.depth = path:count('/')
    self.content = ''
    self.nav_items = {}
end

function Page:add(content)
    self.content = self.content .. content
end

function Page:link(abspath)
    if self.depth == 0 then
        return './' .. abspath
    else
        return string.join('/', list.dup('..', self.depth)) .. '/' .. abspath
    end
end

function Page:a(abspath, text, custom_tags)
    custom_tags = custom_tags or ''
    local link = self:link(abspath)
    return '<a ' .. custom_tags .. ' href="' .. link .. '.html">' .. text .. '</a>'
end

function Page:write()
    local style = [[
        img {
            image-rendering: pixelated;
            image-rendering: -moz-crisp-edges;
            image-rendering: crisp-edges;
        }
        .center {
            text-align: center;
        }

        .hlist { padding: 0; margin: 0; }
        .hlist li { list-style-type: none; }
        .hlist { display: inline-block; }

        ul.navlist {
            list-style: none;
            color: white;
            display: inline-block;
            /*padding: 1rem 2rem;*/
            margin-top: 0.5rem;
        }

        ul.navlist li {
            display: inline-block;
            padding: 0 0.5rem;
            min-width: 5rem;
            text-align: center;
            cursor: pointer;
        }

        ul.navlist li:not(:last-child) {
            border-right: 1px solid #444444;
        }
    ]]

    local navbar = [[
        <div style="width: 100%; height: 32pt; background-color: #dddddd">
        <span style="margin-left: 0.5rem; font-weight: bold; font-size: 24pt;">Valo Wiki</span>
        <ul class="navlist">
    ]]
    navbar = navbar .. '<li>' .. self:a('index', 'Home') .. '</li>'
    for _, navitem in ipairs(self.nav_items) do
        navbar = navbar .. '<li>' .. navitem .. '</li>\n'
    end
    navbar = navbar .. [[</ul></div>]]

    local text = f[[
        <head>
            <title>{self.name}</title>
            <!--<meta content='width=device-width, initial-scale=1' name='viewport'/>-->

            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
            <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/popper.js@1.12.9/dist/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>

        </head>
        <body>
            <style>{style}</style>
            {navbar}
            <div class="content" style="margin: 30px">
                        {self.content}
            </div>
        </body>
    ]]
    sys.write(f'wiki/{self.path}.html', text)
end

return Page
