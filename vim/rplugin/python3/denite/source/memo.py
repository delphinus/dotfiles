import subprocess
from distutils.spawn import find_executable
import denite.util
from .base import Base

SEPARATOR = '{0}:{0}'.format(chr(0xa0))

class Source(Base):

    def __init__(self, vim):
        super().__init__(vim)

        self.name = 'memo'
        self.kind = 'file'

    def gather_candidates(self, context):
        memo = find_executable('memo')
        if not memo:
            return []

        command = [memo, 'list', '--format',
                   '{{.Fullpath}}\t{{.File}}\t{{.Title}}']

        try:
            cmd = subprocess.run(command, stdout=subprocess.PIPE, check=True)
        except subprocess.CalledProcessError as err:
            denite.util.error(self.vim,
                              'command returned invalid response: ' + str(err))
            return []
        rows = cmd.stdout.decode('utf-8').splitlines()
        opt = self.vim.options
        col = opt['column'] if 'column' in opt else 20

        def make_candidates(row):
            [fullpath, file, title] = row.split('\t')
            cut = self._stdwidthpart(file, col)
            return {
                'word': '{0}{1}{2}'.format(cut, SEPARATOR, title),
                'action__path': fullpath,
                }
        return list(map(make_candidates, rows))

    def _stdwidthpart(self, string, col):
        slen = self.vim.funcs.strwidth(string)
        if slen < col:
            return string + ' ' * (col - slen)
        result = ''
        i = 0
        while True:
            char = string[i:i+1]
            next_r = result + char
            nlen = self.vim.funcs.strwidth(next_r)
            if nlen > col - 3:
                rlen = self.vim.funcs.strwidth(result)
                return result + ('....' if rlen < col - 3 else '...')
            elif nlen == col - 3:
                return next_r + '...'
            result = next_r
            i += 1

    def highlight(self):
        self.vim.command(
            'syntax match {0}_File /{1}/ contained containedin={0}'
            .format(self.syntax_name, r'\v.*({0})@='.format(SEPARATOR)))
        self.vim.command('highlight default link {0}_File String'
                         .format(self.syntax_name))
        self.vim.command(
            'syntax match {0}_Title /{1}/ contained containedin={0}'
            .format(self.syntax_name, r'\v({0})@<=.*'.format(SEPARATOR)))
        self.vim.command('highlight default link {0}_Title Todo'
                         .format(self.syntax_name))
