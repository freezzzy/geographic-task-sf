@isTest
public class DataGeneratorTest {

    @isTest
    public static void generateDataTest() {
        Test.setMock(HttpCalloutMock.class, new GeocodeHttpMock());

        Test.startTest();
        DataGenerator.generateData();
        Test.stopTest();

        List<Account> accounts = [SELECT Id FROM Account];
        List<Case> cases = [SELECT Id FROM Case];

        System.assertEquals(10, accounts.size());
        System.assertEquals(90, cases.size());
    }

}