# Acclaim
Acclaim is an easily solution to make API connects to backend to fetch the result data.

Acclaim use a ACAPICaller class to construct the connector what you need.
You can do 'addResponse:' to create response handler to fetch the deserialized object.

Here is the sample code to try make a caller to do a API path called getName, and expect to fetch the json object and original data to continue the app task.

#### Simply for calling Server-API by method `GET`, through `RestfulAPI`.
##### Sample 1 -
![YouBike 臺北市公共自行車即時資訊 RID] http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=ddb80380-f1b3-4f8e-8016-7ed9cba571d5
<br />
```swift
Acclaim.call(API: "http://data.taipei/opendata/datalist/apiAccess",  params: ["scope":"resourceAquire","rid":"ddb80380-f1b3-4f8e-8016-7ed9cba571d5"])
.addJSONResponseHandler { (JSONObject, connection) in
    //do something        
}
```


