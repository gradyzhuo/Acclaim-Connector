# Acclaim
Acclaim is an easily solution to make API connects to backend to fetch the result data.

Acclaim use a ACAPICaller class to construct the connector what you need.
You can do 'addResponse:' to create response handler to fetch the deserialized object.

Here is the sample code to try make a caller to do a API path called getName, and expect to fetch the json object and original data to continue the app task.

    let caller = ACAPICaller(API: "getName", params: [:])
     caller.addResponse(ACResponse.JSON(handler: { (json, response) -> Void in
         //hanle the json object in here.
     })).addResponse(ACResponse.OriginalData(handler: { (data, response) -> Void in
         //hanle the original data in here.
     })).addResponse(ACResponse.Failed(handler: { (data, response, error) -> Void in
         //handle the error with Failed handler, also can use the original data to fix or debug.
     })).run()


