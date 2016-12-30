public class AddressHandler {

    private final static String RESULTS = 'results';
    private final static String GEOMETRY = 'geometry';
    private final static String LOCATION = 'location';
    private final static String LAT = 'lat';
    private final static String LNG = 'lng';
    private final static String ADDRESS_COMPONENTS = 'address_components';
    private final static String DESTINATION_ADDRESSES = 'destination_addresses';
    private final static String ROWS = 'rows';
    private final static String ELEMENTS = 'elements';
    private final static String DISTANCES = 'distance';
    private final static String VALUE = 'value';
    private final static String STATUS = 'status';
    private final static String OK = 'OK';

    public class RequestWrapper {
        public String address {get; set;}
        public List<String> destinations {get; set;}

        public RequestWrapper(String address) {
            this.address = address;
            this.destinations = new List<String>();
        }

        public RequestWrapper(String address, List<String> destinations) {
            this.address = address;
            this.destinations = destinations;
        }
    }

    public class ResultWrapper {
        public String address {get; set;}
        public Double latitude {get; set;}
        public Double longitude {get; set;}
        public Double distance {get; set;}

        public ResultWrapper(Double latitude, Double longitude) {
            this.latitude = latitude;
            this.longitude = longitude;
        }

        public ResultWrapper(String address, Double distance) {
            this.address = address;
            this.distance = distance;
        }
    }

    private static List<ResultWrapper> parseGeocodeResp(String body) {
        List<ResultWrapper> res = new List<ResultWrapper>();
        Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(body);
        List<Object> items = (List<Object>) root.get(RESULTS);
        for (Object item : items) {
            Map<String, Object> i = (Map<String, Object>)item;
            List<Object> p = (List<Object>) i.get(ADDRESS_COMPONENTS);
            Map<String, Object> g = (Map<String, Object>) i.get(GEOMETRY);
            Map<String, Object> l = (Map<String, Object>) g.get(LOCATION);
            res.add(new ResultWrapper(Double.valueOf(l.get(LAT)), Double.valueOf(l.get(LNG))));
        }
        return res;
    }

    private static String createGeocodeRequestString(String address) {
        GMaps_Settings__c settings = GMaps_Settings__c.getOrgDefaults();
        String apiKey = settings.API_Key__c;
        String geocodeURL = settings.Geocode_Endpoint_URL__c;
        String placeholder = geocodeURL + 'address={0}&key={1}';
        List<String> fillers = new List<String>();
        fillers.add(address.replaceAll(' ', '+'));
        fillers.add(apiKey);
        String formatted = String.format(placeholder, fillers);
        return formatted;
    }

    private static HttpResponse getResponse(RequestWrapper reqWrapper, String endpoint) {
        System.debug('reqWrapper ' + JSON.serialize(reqWrapper));
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        HTTPResponse res = http.send(req);
        return res;
    }

    public static List<ResultWrapper> getCoordinates(RequestWrapper reqWrapper) {
        String endpoint = createGeocodeRequestString(reqWrapper.address);
        System.debug('endpoint ' + endpoint);
        HttpResponse res = getResponse(reqWrapper, endpoint);
        List<ResultWrapper> result = parseGeocodeResp(res.getBody());
        return result;
    }

    private static List<ResultWrapper> createNearestSolicitorsList(List<String> req, List<ResultWrapper> res) {
        List<ResultWrapper> result = new List<ResultWrapper>();
        for (Integer i = 0; i < res.size(); i++) {
            ResultWrapper item = res.get(i);
            item.address = req.get(i);
            result.add(item);
        }
        return result;
    }

    private static String createDistanceRequestString(String origin, List<String> destinations) {
        GMaps_Settings__c settings = GMaps_Settings__c.getOrgDefaults();
        String apiKey = settings.API_Key__c;
        String distanceURL = settings.Distance_Endpoint_URL__c;
        String placeholder = distanceURL + 'origins={0}&destinations={1}{2}';
        List<String> fillers = new List<String>();
        fillers.add(origin.replaceAll(' ', '+'));
        List<String> tmp = new List<String>();
        for (String str : destinations) {
            tmp.add(str.replaceAll(' ', '+'));
        }
        String destinationsStr = EncodingUtil.urlEncode(String.join(tmp, '|'), 'UTF-8');
        fillers.add(destinationsStr);
        if (String.isNotBlank(apiKey)) {
            fillers.add('&key=' + apiKey);
        }
        String formatted = String.format(placeholder, fillers);
        return formatted;
    }

    private static Double metresToKm(Double metres) {
        return metres / 1000.0;
    }

    private static List<ResultWrapper> parseDistanceResp(String body) {
        if (String.isBlank(body)) {
            return null;
        }
        List<ResultWrapper> res = new List<ResultWrapper>();
        Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(body);
        List<Object> destinations = (List<Object>) root.get(DESTINATION_ADDRESSES);
        List<Object> items = (List<Object>) root.get(ROWS);
        for (Object item : items) {
            Map<String, Object> i = (Map<String, Object>)item;
            List<Object> g = (List<Object>) i.get(ELEMENTS);
            for (Integer index = 0; index < g.size(); index++) {
                Map<String, Object> z = (Map<String, Object>)g.get(index);
                if (((String)z.get(STATUS)).equals(OK)) {
                    Map<String, Object> t = (Map<String, Object>) z.get(DISTANCES);
                    Double dist = (Double) t.get(VALUE);
                    res.add(new ResultWrapper((String) destinations.get(index), metresToKm(dist)));
                }
            }
        }
        return res;
    }

    public static List<ResultWrapper> findNearest(RequestWrapper reqWrapper) {
        String endpoint = createDistanceRequestString(reqWrapper.address, reqWrapper.destinations);
        HttpResponse res = getResponse(reqWrapper, endpoint);
        List<ResultWrapper> distanceResp = parseDistanceResp(res.getBody());
        System.debug('findNearestResult ' + distanceResp);
        List<ResultWrapper> result = createNearestSolicitorsList(reqWrapper.destinations, distanceResp);
        System.debug('After Merge: ' + result);
        return result;
    }

}