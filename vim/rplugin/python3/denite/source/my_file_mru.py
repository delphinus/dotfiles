# ============================================================================
# FILE: my_file_mru.py
# AUTHOR: delphinus <delphinus@remora.cx>
# License: MIT license
# ============================================================================

from .file_mru import Source as Base


class Source(Base):

    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'my_file_mru'

    def highlight(self):
        self.vim.command(
            r'syntax match {0}_Icon /[^/ \[\]]\+\s/ contained containedin={0}'.
            format(self.syntax_name))
        self.vim.command('highlight default link {0}_Icon Function'.
                         format(self.syntax_name))
