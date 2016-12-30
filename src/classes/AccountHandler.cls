public class AccountHandler {

    @future(callout = true)
    public static void setCoordinates(Set<Id> accountsIds) {
        List<Account> forUpdate = new List<Account>();
        for (Account acc : [SELECT Id, BillingCountry, BillingState, BillingCity, BillingStreet, BillingPostalCode FROM Account WHERE Id IN :accountsIds]) {
            String addressString = createAddressString(acc);
            AddressHandler.RequestWrapper reqWrapper = new AddressHandler.RequestWrapper(addressString, null);
            List<AddressHandler.ResultWrapper> result = AddressHandler.getCoordinates(reqWrapper);
            System.debug('AddressHandler result ' + result);

            if (result.size() > 0) {
                Double latitude = result[0].latitude;
                Double longitude = result[0].longitude;

                acc.BillingLatitude = Double.valueOf(latitude);
                acc.BillingLongitude = Double.valueOf(longitude);

                forUpdate.add(acc);
            }
        }
        System.debug('forUpdate ' + forUpdate);
        if (forUpdate.size() > 0) {
            update forUpdate;
        }
    }

    private static String createAddressString(Account acc) {
        List<String> addressFields = new List<String>();
        addressFields.add(acc.BillingCountry);
        addressFields.add(acc.BillingState);
        addressFields.add(acc.BillingCity);
        addressFields.add(acc.BillingStreet);
        addressFields.add(acc.BillingPostalCode);
        String res = String.join(addressFields, ' ');
        System.debug('Address String ' + res);
        return res;
    }

}