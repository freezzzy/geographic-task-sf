global class DistanceHttpMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{ "destination_addresses" : [ "Kiev, Ukraine" ], "origin_addresses" : [ "Minsk, Belarus" ], "rows" : [ { "elements" : [ { "distance" : { "text" : "568 km", "value" : 567857 }, "duration" : { "text" : "6 hours 33 mins", "value" : 23553 }, "status" : "OK" } ] } ], "status" : "OK" }');
        return res;
    }

}