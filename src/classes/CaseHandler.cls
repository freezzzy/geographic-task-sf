public class CaseHandler {

    @future(callout = true)
    public static void setCoordinates(Set<Id> casesIds) {
        List<Case> forUpdate = new List<Case>();
        for (Case c : [SELECT Id, Address__c, City__c, Country__c, Postal_Code__c, State__c FROM Case WHERE Id IN :casesIds]) {
            String addressString = createAddressString(c);
            AddressHandler.RequestWrapper reqWrapper = new AddressHandler.RequestWrapper(addressString, null);
            List<AddressHandler.ResultWrapper> result = AddressHandler.getCoordinates(reqWrapper);
            System.debug('AddressHandler result ' + result);

            if (result.size() > 0) {
                Double latitude = result[0].latitude;
                Double longitude = result[0].longitude;

                c.Location__latitude__s = Double.valueOf(latitude);
                c.Location__longitude__s = Double.valueOf(longitude);

                forUpdate.add(c);
            }
        }
        System.debug('forUpdate ' + forUpdate);
        if (forUpdate.size() > 0) {
            update forUpdate;
        }
    }

    private static String createAddressString(Case c) {
        List<String> addressFields = new List<String>();
        addressFields.add(c.Address__c);
        addressFields.add(c.City__c);
        addressFields.add(c.Country__c);
        addressFields.add(c.Postal_Code__c);
        addressFields.add(c.State__c);
        String res = String.join(addressFields, ' ');
        System.debug('Address String ' + res);
        return res;
    }

}