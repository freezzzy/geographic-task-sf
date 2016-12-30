@isTest
public class AccountsControllerTest {

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
    }

    @isTest
    public static void getAccountsTest() {
        Test.startTest();
        AccountsController contr =  new AccountsController();
        List<AccountsController.AccountWrapper> res = contr.getAccount();
        Test.stopTest();
        System.assertNotEquals(null, res);
    }

    @isTest
    public static void processTest() {
        Test.startTest();
        AccountsController contr =  new AccountsController();
        PageReference res = contr.process();
        Test.stopTest();
        System.assertNotEquals(null, res);
    }

    @isTest
    public static void behaviorTest() {
        Test.startTest();
        AccountsController contr =  new AccountsController();
        contr.first();
        contr.last();
        contr.previous();
        contr.next();
        contr.cancel();
        Test.stopTest();
    }

}