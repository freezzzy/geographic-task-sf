@isTest
public class AccountCasePageControllerTest {

    @testSetup
    public static void setup() {
        Test.setMock(HttpCalloutMock.class, new GeocodeHttpMock());

        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingPostalCode = '221701';
        acc.BillingCountry = 'Беларусь';
        acc.BillingState = 'Минск';
        acc.BillingCity = 'Минск';
        acc.BillingStreet = 'ул. Козлова, 5';
        insert acc;

        Case c = new Case();
        c.Country__c = 'Беларусь';
        c.City__c = 'Минск';
        c.State__c = 'Минск';
        c.Postal_Code__c = '221702';
        c.Address__c = 'Янки Мавра, 30';
        c.AccountId = acc.Id;
        insert c;
    }

    @isTest
    public static void getAccountsAndCasesTest() {
        Test.startTest();
        String result = AccountCasePageController.getAccountsAndCases('[]');
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @isTest
    public static void getDistansesTest() {
        Test.setMock(HttpCalloutMock.class, new DistanceHttpMock());

        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<String> forJSON = new List<String>();
        forJSON.add(acc.Id);
        String input = JSON.serialize(forJSON);
        Test.startTest();
        String result = AccountCasePageController.getDistanses(input);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @isTest
    public static void getSubListTest() {
        List<String> inputList = new List<String>();
        for (Integer i = 0; i < 10; i++) {
            inputList.add(String.valueOf(i));
        }
        Test.startTest();
        List<String> res = AccountCasePageController.getSubList(inputList, 5);
        Test.stopTest();
        System.assertEquals(5, res.size());
    }

}