if !( has('gui_running') || &t_Co==256 ) | finish | endif

call css_color#init('hex', 'extended', 'plantumlColor,plantumlClassProtected')
