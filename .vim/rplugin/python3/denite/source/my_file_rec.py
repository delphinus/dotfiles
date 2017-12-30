# ============================================================================
# FILE: my_file_rec.py
# AUTHOR: delphinus <delphinus@remora.cx>
# License: MIT license
# ============================================================================

from denite.source.file_rec import Source as Base
from .my_buffer import word, abbr, highlight


class Source(Base):

    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'my_file_rec'

    def gather_candidates(self, context):
        return [{
            'word': word(self.vim, x['action__path']),
            'abbr': abbr(self.vim, x['action__path']),
            'action__path': x['action__path'],
        } for x in super().gather_candidates(context)]

    def highlight(self):
        highlight(self.vim, self.syntax_name)
