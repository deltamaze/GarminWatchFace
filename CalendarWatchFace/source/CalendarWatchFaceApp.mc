import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Background;

class CalendarWatchFaceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new CalendarWatchFaceView() ];
    }

    // New method to handle background events
    function getServiceDelegate() {
        return [new BackgroundService()];
    }

    // New method to pass background data to the view
    function onBackgroundData(data) {
        var view = WatchUi.getCurrentView();
        if (view[0] instanceof CalendarWatchFaceView) {
            //(view[0] as CalendarWatchFaceView).apiResponse = data;
            (view[0] as CalendarWatchFaceView).onBackgroundData(data);
        }
    }
}

class AppState {

}

function getApp() as CalendarWatchFaceApp {
    return Application.getApp() as CalendarWatchFaceApp;
}