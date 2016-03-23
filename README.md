# Acclaim
Acclaim is an easily solution to make API connects to backend to fetch the result data.

Acclaim use a ACAPICaller class to construct the connector what you need.
You can do 'addResponse:' to create response handler to fetch the deserialized object.

Here is the sample code to try make a caller to do a API path called getName, and expect to fetch the json object and original data to continue the app task.

### Sample: Call Server-API by method `GET`, through DataTask.
```swift
Acclaim.call(API: "[API Path]",  params: ["fling_hash":"dQAXWbcv"])
.addJSONResponseHandler { (JSONObject, connection) in
    //do something        
}
```


