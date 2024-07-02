# vim:set et fileencoding=utf8 sts=0 sw=4 ts=4:

import string
import vim
import re
from enum import Enum

# use like this:
#
# py3 << EOF
# import vim
# import asciiart
# vimsnippets.print_hello()
# EOF

boxCharacters = ['-', '|', '+']


class CornerType(Enum):
    topleft = 0
    topright = 1
    bottomleft = 2
    bottomright = 3


class Direction(Enum):
    up = 0
    down = 1
    left = 2
    right = 3


class Point:
    """x y 均从 0 开始"""

    def __init__(self, x: int = 0, y: int = 1):
        self.x = x
        self.y = y

    def __str__(self):
        return f"Point info ==> Line: {self.y + 1}, Column: {self.x + 1}"

    @property
    def attachingBox(self):
        """The box whose current point is alongside its border"""
        # ensure current point is at border of box!
        if self.underChar not in boxCharacters:
            return None

        if self.underChar == '-':
            leftCorner = self.relativeLeftCorner
            if not leftCorner:
                return None
            if leftCorner.cornerType == CornerType.topleft:
                topleftCorner = leftCorner
            else:
                topleftCorner = leftCorner.relativeUpCorner
        elif self.underChar == '|':
            upCorner = self.relativeUpCorner
            if not upCorner:
                return None
            if upCorner.cornerType == CornerType.topright:
                topleftCorner = upCorner.relativeLeftCorner
            else:
                topleftCorner = upCorner.relativeLeftCorner.relativeUpCorner
        elif self.underChar == '+':
            if self.cornerType == CornerType.topleft:
                topleftCorner = self
            elif self.cornerType == CornerType.topright:
                topleftCorner = self.relativeLeftCorner
            elif self.cornerType == CornerType.bottomleft:
                topleftCorner = self.relativeUpCorner
            elif self.cornerType == CornerType.bottomright:
                topleftCorner = self.relativeLeftCorner.relativeUpCorner
            else:
                return None
        else:
            return None

        if topleftCorner is None:
            return None
        # print(topleftCorner)

        toprightCorner = topleftCorner.relativeRightCorner
        bottomleftCorner = topleftCorner.relativeDownCorner
        bottomrightCorner = bottomleftCorner.relativeRightCorner if bottomleftCorner else None

        if toprightCorner is None or bottomleftCorner is None or bottomrightCorner is None:
            return None

        if toprightCorner.x == bottomrightCorner.x:
            return Box(origin=topleftCorner, width=toprightCorner.x - topleftCorner.x + 1, height=bottomleftCorner.y - topleftCorner.y + 1)
        else:
            return None

    @property
    def underChar(self) -> str:
        b = vim.current.buffer
        return b[self.y][self.x]

    def nearbyPoint(self, direct: Direction):

        if direct == Direction.up and self.y > 0:
            target_point = Point(x=self.x, y=self.y - 1)
        elif direct == Direction.down and self.y < len(vim.current.buffer) - 1:
            target_point = Point(x=self.x, y=self.y + 1)
        elif direct == Direction.left and self.x > 0:
            target_point = Point(x=self.x - 1, y=self.y)
        elif direct == Direction.right and self.x < len(vim.current.line) - 1:
            target_point = Point(x=self.x + 1, y=self.y)
        else:
            return None

        b = vim.current.buffer
        if target_point.y <= len(b) - 1 and target_point.x <= len(b[target_point.y]):
            return target_point
        else:
            return None

    @property
    def upPoint(self):
        return self.nearbyPoint(Direction.up)

    @property
    def downPoint(self):
        return self.nearbyPoint(Direction.down)

    @property
    def leftPoint(self):
        return self.nearbyPoint(Direction.left)

    @property
    def rightPoint(self):
        return self.nearbyPoint(Direction.right)

    def relativeCorner(self, direct: Direction):
        target_point = self.nearbyPoint(direct=direct)
        while target_point:
            if target_point.underChar not in boxCharacters:
                return None
            if target_point.underChar == '+':
                return target_point
            target_point = target_point.nearbyPoint(direct=direct)

        return None

    @property
    def relativeUpCorner(self):
        return self.relativeCorner(Direction.right)

    @property
    def relativeDownCorner(self):
        return self.relativeCorner(Direction.down)

    @property
    def relativeLeftCorner(self):
        return self.relativeCorner(Direction.left)

    @property
    def relativeRightCorner(self):
        return self.relativeCorner(Direction.right)

    @property
    def cornerType(self) -> CornerType:
        if self.underChar == '+':
            upChar = self.upPoint.underChar if self.upPoint is not None else None
            rightChar = self.rightPoint.underChar if self.rightPoint is not None else None
            # print(self.downPoint)
            downChar = self.downPoint.underChar if self.downPoint is not None else None
            leftChar = self.leftPoint.underChar if self.leftPoint is not None else None
            if rightChar == '-' and downChar == '|':
                return CornerType.topleft
            elif leftChar and downChar == '|':
                return CornerType.topright
            elif rightChar == '-' and upChar == '|':
                return CornerType.bottomleft
            elif leftChar == '-' and upChar == '|':
                return CornerType.bottomright
            else:
                return None
        else:
            return None


class Box:
    def __init__(self, origin: Point = Point(x=0, y=0), width: int = 0, height: int = 0):
        self.origin: Point = origin
        self.height: int = height
        self.width: int = width

    def __str__(self):
        return f"Box info ==> Line: {self.origin.y + 1}, Column: {self.origin.x + 1}, width: {self.width}, height: {self.height}"

    @property
    def minX(self) -> int:
        return self.origin.x

    @property
    def minY(self) -> int:
        return self.origin.y

    @property
    def maxX(self) -> int:
        return self.origin.x + self.width - 1

    @property
    def maxY(self) -> int:
        return self.origin.y + self.height - 1

    def is_contain_point(self, point: Point) -> bool:
        return point.x >= self.minX and point.x <= self.maxX and point.y >= self.minY and point.y <= self.maxY

    @property
    def rawData2Vim(self) -> list[int]:
        """format: `[line, column, width, height]`"""
        return [self.minY + 1, self.minX + 1, self.width, self.height]


def lookupContainerBox() -> list:
    # 这里记住, vim 的光标列从 1 开始, python 中的光标列从 0 开始, 因此构造 Point时, 行数要减 1, 列数不用减
    current_cursor: tuple = vim.current.window.cursor
    current_point = Point(x=current_cursor[1], y=current_cursor[0] - 1)

    target_y = current_point.y
    while target_y > 0:
        target_point = Point(x=current_point.x, y=target_y)
        if target_point.underChar in boxCharacters:
            # print(target_point.y, target_point.x)
            box = target_point.attachingBox
            if box is not None and box.is_contain_point(current_point):
                # print(box)
                return box.rawData2Vim

        target_y -= 1

    return []
