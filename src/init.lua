function require_pkg(path)
    return require_abs(PKG_DIR .. '/src/' .. path)
end

genwiki = require_pkg('genwiki.lua')