import enum


class TimeWindow(enum.IntEnum):
    Minute = 60
    Hour = 60 * Minute
    Day = 24 * Hour
