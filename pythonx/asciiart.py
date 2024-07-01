# vim:set et fileencoding=utf8 sts=0 sw=4 ts=4:

"""Helper methods used in UltiSnips snippets."""

import string
import vim
import re

# use like this:
#
# py3 << EOF
# import vim
# import asciiart
# vimsnippets.print_hello()
# EOF


class Point:
    def __init__(self, x: int = 0, y: int = 0):
        self.x = x
        self.y = y

class Box:

    def __init__(self):
        self.origin: Point = Point(x=0, y=0)
        self.height: int = 0
        self.width: int = 0

    @property
    def minX(self) -> int:
        return self.origin.x

    @property
    def maxX(self) -> int:
        return self.origin.x + self.width

    @property
    def minY(self) -> int:
        return self.origin.y

    @property
    def maxY(self) -> int:
        return self.origin.y + self.height

    def is_contain_point(self, point: Point) -> bool:
        return point.x >= self.minX and point.x <= self.maxX and point.y >= self.minY and point.y <= self.maxY

def lookupContainerBox():
    current_cursor: tuple = vim.current.window.cursor
    print(current_cursor)
    current_point = Point(x=current_cursor[1], y=current_cursor[0])

    return [current_point.x, current_point.y]

















def print_hello():
    print("hello1")


def current_buffer():
    print(dir(vim.current.buffer))


def current_line():
    print(vim.current.line)


def append_line():
    b = vim.current.buffer
    b.append("hello world")


def set_lines():
    b = vim.current.buffer
    b[39:40] = ["hello", "world"]


def return_int():
    return 123
