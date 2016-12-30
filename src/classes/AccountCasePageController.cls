public class AccountCasePageController {

    private static final Integer ACCOUNTS_LIMIT = 10;

    public String accountsIdsJSON {get; set;}

    public class ResultWrapper {
        public Account acc {get; set;}
        public List<Case> cases {get; set;}

        public ResultWrapper(Account acc) {
            this.cases = new List<Case>();
            this.acc = acc;
        }
    }

    private class CaseDistanceWrapper implements Comparable {
        public String caseId {get; set;}
        public Double distance {get; set;}

        public CaseDistanceWrapper(String id, Double distance) {
            this.caseId = id;
            this.distance = distance;
        }

        public Integer compareTo(Object compareTo) {
            CaseDistanceWrapper compareToWrap = (CaseDistanceWrapper) compareTo;
            Double dist1 = this.distance == null ? 0 : this.distance;
            Double dist2 = compareToWrap.distance == null ? 0 : compareToWrap.distance;
            Double diff = dist1 - dist2;
            return diff.intValue();
        }
    }

    public AccountCasePageController() {
        accountsIdsJSON = ApexPages.currentPage().getParameters().get('ids');
    }

    private class DistanceResponse {
        public String accId {get; set;}
        public List<CaseDistanceWrapper> matrix {get; set;}
        public List<CaseDistanceWrapper> soql {get; set;}

        public DistanceResponse(String id) {
            this.accId = id;
            this.matrix = new List<CaseDistanceWrapper>();
            this.soql = new List<CaseDistanceWrapper>();
        }
    }

    @RemoteAction
    public static String getAccountsAndCases(String accountsIdsJSON) {
        Map<Id, Account> accountsMap;
        if (accountsIdsJSON.equals('')) {
            accountsMap = new Map<Id, Account>([SELECT Id, BillingStreet, BillingCity, BillingLatitude, BillingLongitude FROM Account LIMIT 10]);
        } else {
            List<String> idsList = (List<String>) JSON.deserialize(accountsIdsJSON, List<String>.class);
            if (idsList.size() > ACCOUNTS_LIMIT) {
                idsList = getSubList(idsList, ACCOUNTS_LIMIT);
            }
            accountsMap = new Map<Id, Account>([SELECT Id, BillingStreet, BillingCity, BillingLatitude, BillingLongitude FROM Account WHERE Id IN :idsList]);
        }
        Set<Id> accountsIds = accountsMap.keySet();
        List<Case> casesList = [SELECT Id, AccountId, Location__latitude__s, Location__longitude__s FROM Case WHERE AccountId IN :accountsIds];
        List<ResultWrapper> result = new List<ResultWrapper>();
        for (Account acc : accountsMap.values()) {
            ResultWrapper resWrapper = new ResultWrapper(acc);
            for (Case c : casesList) {
                if (c.AccountId == acc.Id) {
                    resWrapper.cases.add(c);
                }
            }
            result.add(resWrapper);
        }
        return JSON.serialize(result);
    }

    @RemoteAction
    public static String getDistanses(String input) {
        List<String> accountsIds = (List<String>) JSON.deserialize(input, List<String>.class);
        List<Account> accountsList = [SELECT Id, BillingCountry, BillingState, BillingCity, BillingStreet, BillingPostalCode, BillingLatitude, BillingLongitude FROM Account WHERE Id IN :accountsIds];
        List<Case> casesList = [SELECT Id, AccountId, Address__c, City__c, Country__c, Postal_Code__c, State__c, Location__c, CaseNumber FROM Case WHERE AccountId IN :accountsIds];
        List<DistanceResponse> resultList = new List<DistanceResponse>();
        for (Account acc : accountsList) {
            DistanceResponse distanceRes = new DistanceResponse(acc.Id);
            List<CaseDistanceWrapper> caseDistanceListSOQL = new List<CaseDistanceWrapper>();
            String accAddress = createAddressString(acc);
            AddressHandler.RequestWrapper reqWr = new AddressHandler.RequestWrapper(accAddress);
            List<Case> casesForAccount = new List<Case>();
            for (Case c : casesList) {
                if (c.AccountId == acc.Id) {
                    if (c.Location__c != null) {
                        Double tmpDistance = Location.getDistance(Location.newInstance(acc.BillingLatitude, acc.BillingLongitude), c.Location__c, 'km');
                        caseDistanceListSOQL.add(new CaseDistanceWrapper(c.CaseNumber, tmpDistance));
                        reqWr.destinations.add(createAddressString(c));
                        casesForAccount.add(c);
                    }
                }
            }
            List<AddressHandler.ResultWrapper> res = AddressHandler.findNearest(reqWr);
            System.debug('Address Handler Resp : ' + res);
            List<CaseDistanceWrapper> caseDistanceList = new List<CaseDistanceWrapper>();
            for (Integer i = 0; i < res.size(); i++) {
                CaseDistanceWrapper tmp = new CaseDistanceWrapper(casesForAccount.get(i).CaseNumber, res.get(i).distance);
                caseDistanceList.add(tmp);
            }
            caseDistanceList.sort();
            distanceRes.matrix = caseDistanceList;
            caseDistanceListSOQL.sort();
            distanceRes.soql = caseDistanceListSOQL;
            resultList.add(distanceRes);
        }
        System.debug('getDistance ' + JSON.serialize(resultList));
        return JSON.serialize(resultList);
    }

    @testVisible
    private static List<String> getSubList(List<String> input, Integer limitCount) {
        if (input.size() <= limitCount) {
            return input;
        }
        List<String> res = new List<String>();
        for (Integer i = 0; i < limitCount; i++) {
            res.add(input.get(i));
        }
        return res;
    }

    private static String createAddressString(Account acc) {
        List<String> addressFields = new List<String>();
        addressFields.add(acc.BillingCountry);
        addressFields.add(acc.BillingState);
        addressFields.add(acc.BillingCity);
        addressFields.add(acc.BillingStreet);
        addressFields.add(acc.BillingPostalCode);
        String res = String.join(addressFields, ' ');
        return res;
    }

    private static String createAddressString(Case c) {
        List<String> addressFields = new List<String>();
        addressFields.add(c.Address__c);
        addressFields.add(c.City__c);
        addressFields.add(c.Country__c);
        addressFields.add(c.Postal_Code__c);
        addressFields.add(c.State__c);
        String res = String.join(addressFields, ' ');
        return res;
    }

}