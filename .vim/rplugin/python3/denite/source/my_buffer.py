# ============================================================================
# FILE: my_buffer.py
# AUTHOR: delphinus <delphinus@remora.cx>
# License: MIT license
# ============================================================================

from time import localtime, strftime
from denite.source.buffer import Source as Base
from my_util import abbr, highlight


class Source(Base):

    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'my_buffer'

    def _convert(self, buffer_attr, rjust):
        if buffer_attr['name'] == '':
            name = 'No Name'
            path = ''
        else:
            name = self.vim.call('fnamemodify', buffer_attr['name'], ':~:.')
            path = self.vim.call('fnamemodify', buffer_attr['name'], ':p')
        abbr_name = abbr(self.vim, name)
        return {
            'bufnr': buffer_attr['number'],
            'word': name,
            'abbr': '{0}{1} {2}{3} {4}'.format(
                str(buffer_attr['number']).rjust(rjust, ' '),
                buffer_attr['status'],
                abbr_name,
                ' [{}]'.format(
                    buffer_attr['filetype']
                    ) if buffer_attr['filetype'] != '' else '',
                strftime(
                    '(' + self.vars['date_format'] + ')',
                    localtime(buffer_attr['timestamp'])
                    ) if self.vars['date_format'] != '' else ''
            ),
            'action__bufnr': buffer_attr['number'],
            'action__path': path,
            'timestamp': buffer_attr['timestamp']
        }

    def highlight(self):
        super().highlight()
        highlight(self.vim, self.syntax_name)
