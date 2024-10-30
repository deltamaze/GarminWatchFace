import Toybox.Background;
import Toybox.Communications;
import Toybox.System;
import Toybox.Lang;

(:background)
class BackgroundService extends System.ServiceDelegate {
    function initialize() {
        ServiceDelegate.initialize();
    }

    function onTemporalEvent() as Void {
        var url = "https://httpbin.org/get";
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        var responseCallback = method(:onReceive);    

        Communications.makeWebRequest(url, {}, options, responseCallback);
    }

    function onReceive(responseCode as Number, data as Dictionary) as Void{
        if (responseCode == 200) {
            if (data instanceof Dictionary && data.hasKey("origin")) {
                Background.exit(data.get("origin"));
            } else {
                Background.exit("Invalid response format");
            }
        } else {
            Background.exit("Error: " + responseCode.toString());
        }
    }
}