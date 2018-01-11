import webbrowser
from denite.kind.base import Base

class Kind(Base):

    def __init__(self, vim):
        super().__init__(vim)

        self.name = 'uri'
        self.default_action = 'open'

    def action_open(self, context):
        for target in context['targets']:
            webbrowser.open(target['action__uri'])
