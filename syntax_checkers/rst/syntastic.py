# File:        syntastic.py
# Description: Dummy builder  for Sphinx
# Maintainer:  LCD 47 <lcd047 at gmail dot com>
# License:     This program is free software. It comes without any warranty,
#              to the extent permitted by applicable law. You can redistribute
#              it and/or modify it under the terms of the Do What The Fuck You
#              Want To Public License, Version 2, as published by Sam Hocevar.
#              See http://sam.zoy.org/wtfpl/COPYING for more details.

from __future__ import (unicode_literals)

from sphinx.builders import Builder


class DummyBuilder(Builder):

    name = 'dummy'

    def get_target_uri(self, docname, typ=None):
        return ''

    def get_outdated_docs(self):
        return 'all files'
        # return self.env.found_docs
        # for docname in self.env.found_docs:
        #     yield docname

    def prepare_writing(self, docnames):
        pass

    def write(self, *ignored):
        pass


def setup(app):
    app.add_builder(DummyBuilder)
