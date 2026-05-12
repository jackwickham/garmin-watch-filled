import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

class FilledWatchFaceView extends WatchUi.WatchFace {

    private var _lastSec as Number = -1;
    private const TIME_FONT = Application.loadResource( Rez.Fonts.NunitoSans80 ) as FontResource;
    private const CHARGING_TIME_FONT = Application.loadResource( Rez.Fonts.NunitoSans60 ) as FontResource;
    private const BATTERY_WIDTH = 20;
    private const BATTERY_SPACER = 6;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;
        var cy = height / 2;

        // Clear screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var clockTime = System.getClockTime();
        _lastSec = clockTime.sec;

        // Seconds arc
        drawSecondsArc(dc, cx, cy, width, clockTime.sec);

        if (System.getSystemStats().charging) {
            // Hours
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx - 5, cy - 34, CHARGING_TIME_FONT, clockTime.hour.format("%02d"),
                Graphics.TEXT_JUSTIFY_RIGHT);

            // Minutes
            dc.setColor(0x00AA00, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx + 5, cy - 34, CHARGING_TIME_FONT, clockTime.min.format("%02d"),
                Graphics.TEXT_JUSTIFY_LEFT);
        } else {
            // Hours
            var hoursHeight = dc.getFontHeight(TIME_FONT);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy - hoursHeight + 2, TIME_FONT, clockTime.hour.format("%02d"),
                Graphics.TEXT_JUSTIFY_CENTER);

            // Minutes
            dc.setColor(0x00AA00, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy - 34, TIME_FONT, clockTime.min.format("%02d"),
                Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Date + battery
        var dateFont = Graphics.FONT_TINY;
        var info = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateStr = info.day_of_week + " " + info.day;
        var dateDimensions = dc.getTextDimensions(dateStr, dateFont);

        drawBattery(dc, cx - (dateDimensions[0] + BATTERY_WIDTH + BATTERY_SPACER) / 2, cy + 54 + 8);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - (dateDimensions[0] - BATTERY_WIDTH - BATTERY_SPACER) / 2, cy + 54, dateFont, dateStr,
            Graphics.TEXT_JUSTIFY_LEFT);

    }

    function onPartialUpdate(dc as Dc) as Void {
        var clockTime = System.getClockTime();
        if (clockTime.sec == _lastSec) {
            return;
        }

        var width = dc.getWidth();
        var cx = width / 2;
        var cy = dc.getHeight() / 2;
        var radius = width / 2 - 6;

        if (_lastSec > clockTime.sec) {
            // Erase old arc
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
            dc.setPenWidth(5);
            dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, 0, 360);
        }

        drawSecondsArc(dc, cx, cy, width, clockTime.sec);
    }

    function drawSecondsArc(dc as Dc, cx as Number, cy as Number, size as Number, seconds as Number) as Void {
        if (seconds == 0) {
            return;
        }
        var radius = size / 2 - 4;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        // 90deg is the top, and increases anticlockwise
        var startAngle = 90;
        var endAngle = 90 - (seconds * 6);
        if (endAngle < 0) {
            endAngle += 360;
        }
        dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, startAngle, endAngle);
        dc.setPenWidth(1);

        _lastSec = seconds;
    }

    function drawBattery(dc as Dc, left as Number, top as Number) as Void {
        var stats = System.getSystemStats();
        var battery = stats.battery;

        var tip_width = 2;
        var width = BATTERY_WIDTH - tip_width;
        var height = 12;

        // Outline
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(left, top, width, height);
        dc.fillRectangle(left + width, top + height / 2 - 2, tip_width, 4);

        // Fill level
        var fillWidth = ((width - 4) * battery / 100).toNumber();
        if (battery > 20) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(left + 2, top + 2, fillWidth, height - 4);
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
        WatchUi.requestUpdate();
    }

    function onEnterSleep() as Void {
        WatchUi.requestUpdate();
    }
}
