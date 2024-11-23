return {
  has_plugin=function(name)
    return not not require'lazy.core.config'.plugins[name]
  end,
}
