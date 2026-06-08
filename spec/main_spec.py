'''
main spec
'''

from libspec import Spec
from . import app, toolkit, schema, birthday_book

class MainSpec(Spec):
    def modules(self):
        return [app, toolkit, schema, birthday_book]

