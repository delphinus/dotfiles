from datetime import date
import re
import os.path
from .file import Kind as File

INVALID_CHAR = re.compile(r'[ <>:"/\\|?*%#]')
REPLACED_CHAR = re.compile(r'--+')

class Kind(File):

    def __init__(self, vim):
        super().__init__(vim)

        self.name = 'memo'

    def action_open(self, context):
        cwd = self.vim.funcs.getcwd()
        for target in context['targets']:
            if 'action__is_new' in target:
                title = self._escape(target['action__title'])
                today = date.today()
                name = '{0}-{1}.md'.format(today.strftime('%Y-%m-%d'), title)
                path = os.path.join(target['action__memo_dir'], name)
            else:
                path = target['action__path']

            match_path = '^{0}$'.format(path)
            if path.startswith(cwd):
                path = os.path.relpath(path, cwd)
            nr = self.vim.funcs.bufwinnr(match_path)
            if nr <= 0:
                self.vim.call('denite#util#execute_path', 'edit', path)
                if not self.vim.funcs.getline(1):
                    self.vim.funcs.append(
                        0, '# {0}'.format(target['action__title']))
            elif nr != self.vim.current.buffer:
                self.vim.command('buffer' + str(self.vim.funcs.bufnr(path)))

            self.__jump(context, target)

    def _escape(self, title):
        title = INVALID_CHAR.sub('-', title)
        title = REPLACED_CHAR.sub('-', title)
        return title.strip('- ')
