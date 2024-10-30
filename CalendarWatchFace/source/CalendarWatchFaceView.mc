import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Background;
import Toybox.ActivityMonitor;
import Toybox.SensorHistory;

public class CalendarWatchFaceView extends WatchUi.WatchFace {

    private var apiResponse as Dictionary = {}; // Change to Dictionary
    private var heartRate as Number = 0;
    private var steps as Number = 0;
    private var batteryPercent as Number = 0;
    private var notificationIcon as Boolean = false;
    private var alarmIcon as Boolean = false;
    private var blueToothStatus = "N";

    function initialize() {
        apiResponse = {
        "events" => [
            {
                "timeStart" => "0100PM",
                "eventName" => "TeamMeeting"
            },
            {
                "timeStart" => "0615PM",
                "eventName" => "HangoutSesh"
            },
            {
                "timeStart" => "0400AM",
                "eventName" => "Workout"
            }
        ]
    };
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onShow() as Void {
        requestApiData();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Top half
        drawTopHalf(dc);

        // Bottom half
        drawBottomHalf(dc);
    }

    function drawTopHalf(dc as Dc) {
        var clockTime = System.getClockTime();
        var hour = clockTime.hour % 12;
        if (hour == 0) {
            hour = 12;
        }
        var timeString = Lang.format("$1$:$2$", [hour, clockTime.min.format("%02d")]);
        
        // Time
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() * 0.1, Graphics.FONT_NUMBER_HOT, timeString, Graphics.TEXT_JUSTIFY_CENTER);

        
        var smallFont = Graphics.FONT_XTINY;

        // Date
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dateString = Lang.format("$1$/$2$", [today.month.format("%02d"), today.day.format("%02d")]);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() * 0.05, smallFont, dateString, Graphics.TEXT_JUSTIFY_CENTER);

        // Heart Rate
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        var hrIterator = ActivityMonitor.getHeartRateHistory(1, true);
        var hrSample = hrIterator.next();
        if (hrSample != null && hrSample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
            heartRate = hrSample.heartRate;
        }
        dc.drawText(dc.getWidth() / 2, dc.getHeight() * 0.11, smallFont, heartRate.toString() , Graphics.TEXT_JUSTIFY_CENTER);

        // // Steps
        dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_TRANSPARENT);
        steps = ActivityMonitor.getInfo().steps;
        steps = 11999;
        dc.drawText(dc.getWidth() / 2 - 50, dc.getHeight() * 0.11, smallFont, steps.toString() , Graphics.TEXT_JUSTIFY_CENTER);

        // Battery
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        batteryPercent = Math.floor(System.getSystemStats().battery).toNumber();
        dc.drawText(dc.getWidth() / 2 + 50, dc.getHeight() * 0.11, smallFont, batteryPercent.toString() , Graphics.TEXT_JUSTIFY_CENTER);

        // Bluetooth
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        if(System.getDeviceSettings().phoneConnected)
        {
            blueToothStatus = 'Y';
        }
        else
        {
            blueToothStatus = 'N';
        }
        dc.drawText(dc.getWidth() / 2 - 50, dc.getHeight() * 0.40, smallFont, "B:"+blueToothStatus , Graphics.TEXT_JUSTIFY_CENTER);

        // Alarm Count
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2 , dc.getHeight() * 0.40, smallFont, "A:"+System.getDeviceSettings().alarmCount.toString() , Graphics.TEXT_JUSTIFY_CENTER);
        // Notification Count
        dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2 + 50, dc.getHeight() * 0.40, smallFont, "N:"+System.getDeviceSettings().notificationCount.toString() , Graphics.TEXT_JUSTIFY_CENTER);

        // // Icons
        // var iconSize = 20;
        // var iconY = dc.getHeight() * 0.4;
        // if (notificationIcon) {
        //     dc.drawText(dc.getWidth() * 0.4, iconY, smallFont, "🔔", Graphics.TEXT_JUSTIFY_CENTER);
        // }
        // if (alarmIcon) {
        //     dc.drawText(dc.getWidth() * 0.5, iconY, smallFont, "⏰", Graphics.TEXT_JUSTIFY_CENTER);
        // }
        // if (bluetoothIcon) {
        //     dc.drawText(dc.getWidth() * 0.6, iconY, smallFont, "🔵", Graphics.TEXT_JUSTIFY_CENTER);
        // }
    }

    function drawBottomHalf(dc as Dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var smallFont = Graphics.FONT_XTINY;
        var yStart = dc.getHeight() * 0.55;
        var yIncrement = dc.getHeight() * 0.1;

        if (apiResponse.hasKey("events") && apiResponse["events"] instanceof Array) {
            var events = apiResponse["events"] as Array<Dictionary>;
            for (var i = 0; i < 3 && i < events.size(); i++) {
                var event = events[i];
                if (event.hasKey("timeStart") && event.hasKey("eventName")) {
                    var timeStart = event["timeStart"] as String;
                    var eventName = event["eventName"] as String;
                    var displayText = Lang.format("$1$ - $2$", [timeStart, eventName]);
                    dc.drawText(dc.getWidth() / 2, yStart + (i * yIncrement), smallFont, displayText, Graphics.TEXT_JUSTIFY_CENTER);
                }
            }
        } else {
            dc.drawText(dc.getWidth() / 2, yStart, smallFont, "No events data", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
        requestApiData();
    }

    function onEnterSleep() as Void {
    }

    function requestApiData() as Void {
        Background.registerForTemporalEvent(new Time.Duration(5 * 60));
    }

    public function onBackgroundData(data as Dictionary or String) as Void {
        // Hardcoded payload
    data = {
        "events" => [
            {
                "timeStart" => "0100PM",
                "eventName" => "TeamMeeting"
            },
            {
                "timeStart" => "0615PM",
                "eventName" => "HangoutSesh"
            },
            {
                "timeStart" => "0400AM",
                "eventName" => "Workout"
            }
        ]
    };
        if (data instanceof Dictionary) {
            apiResponse = data;
        } else if (data instanceof String) {
            // Handle the case where data is a String (e.g., error message)
            apiResponse = {"error" => data};
        }
        WatchUi.requestUpdate();
    }
}