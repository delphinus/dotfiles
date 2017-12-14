from distutils.spawn import find_executable
import re
import subprocess
from .base import Base

SEPARATOR = '{0}:{0}'.format(chr(0xa0))
MEMO_DIR = re.compile(r'^memodir = "(.*?)"$', re.M)

class Source(Base):

    def __init__(self, vim):
        super().__init__(vim)

        self.name = 'memo'
        self.kind = 'memo'

    def gather_candidates(self, context):
        if context['args'] and context['args'][0] == 'new':
            return self._is_new(context)

        args = ['list', '--format', '{{.Fullpath}}\t{{.File}}\t{{.Title}}']
        txt = self._cmdrun(context, args, 'command returned invalid response')
        if not txt:
            return []
        rows = txt.splitlines()

        opt = self.vim.options
        col = opt['column'] if 'column' in opt else 20

        def make_candidates(row):
            [fullpath, filename, title] = row.split('\t')
            cut = self._stdwidthpart(filename, col)
            return {
                'word': filename,
                'abbr': '{0}{1}{2}'.format(cut, SEPARATOR, title),
                'action__path': fullpath,
                }
        return list(map(make_candidates, rows))

    def _is_new(self, context):
        if 'memo_dir' not in self.vars or not self.vars['memo_dir']:
            txt = self._cmdrun(context, ['config', '--cat'],
                               'command returned invalid response')
            if not txt:
                return []
            match = MEMO_DIR.search(txt)
            if not match:
                return []
            self.vars['memo_dir'] = match.group(1)

        context['is_interactive'] = True
        title = context['input']
        if not title:
            return []
        return [{
            'word': title,
            'abbr': '[new title] ' + title,
            'action__memo_dir': self.vars['memo_dir'],
            'action__title': title,
            'action__is_new': True,
            }]

    def _cmdrun(self, context, args, errmsg):
        if 'command' not in self.vars or not self.vars['command']:
            self.vars['command'] = find_executable('memo')
            if not self.vars['command']:
                self.error_message(context, 'memo command not found')
                return ''

        command = [self.vars['command'], *args]
        try:
            cmd = subprocess.run(command, stdout=subprocess.PIPE, check=True)
            return cmd.stdout.decode('utf-8')
        except subprocess.CalledProcessError as err:
            self.error_message(context, errmsg + ': ' + str(err))
            return ''

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
            'syntax match {0}_Prefix /{1}/ contained containedin={0}'
            .format(self.syntax_name, r'\[new title\]'))
        self.vim.command('highlight default link {0}_Prefix String'
                         .format(self.syntax_name))

        self.vim.command(
            'syntax match {0}_File /{1}/ contained containedin={0}'
            .format(self.syntax_name, r'\v.*({0})@='.format(SEPARATOR)))
        self.vim.command('highlight default link {0}_File String'
                         .format(self.syntax_name))
        self.vim.command(
            'syntax match {0}_Title /{1}/ contained containedin={0}'
            .format(self.syntax_name, r'\v({0})@<=.*'.format(SEPARATOR)))
        self.vim.command('highlight default link {0}_Title Function'
                         .format(self.syntax_name))
