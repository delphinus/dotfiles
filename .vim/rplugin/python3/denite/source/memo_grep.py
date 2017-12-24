from .grep import Source as Grep
import subprocess
from .memo import Memo, CommandNotFoundError


class Source(Grep):

    def __init__(self, vim):
        super().__init__(vim)

        self.name = 'memo/grep'

    def on_init(self, context):
        try:
            memo_dir = Memo().get_memo_dir()
        except CommandNotFoundError as err:
            self.error_message(context, str(err))
        except subprocess.CalledProcessError as err:
            self.error_message(
                context, 'command returned invalid response: ' + str(err))
        context['args'].insert(0, memo_dir)
        super().on_init(context)
