public class DataGenerator {

    private static final Integer ACCOUNTS_LIMIT = 10;

    private static List<String> generateStreets() {
        List<String> streets = new List<String>();
        streets.add('улица Воронянского');
        streets.add('улица Шаранговича');
        streets.add('улица Прушинских');
        streets.add('улица Голодеда');
        streets.add('Логойский тракт ');
        streets.add('улица Орловская');
        streets.add('улица Шугаева');
        streets.add('улица Ландера');
        streets.add('улица Притыцкого');
        streets.add('проспект Победителей');
        streets.add('проспект Партизанский');
        return streets;
    }

    private static Integer randomWithLimit(Integer upperLimit) {
        Integer rand = Math.round(Math.random() * 1000);
        return Math.mod(rand, upperLimit);
    }

    public static void generateData() {
        //clearAll();
        List<Account> accounts = generateAccounts();
        generateCases(accounts);
    }

    private static void clearAll() {
        List<Case> cases = [SELECT Id FROM Case LIMIT 1000];
        delete cases;

        List<Account> accs = [SELECT Id FROM Account LIMIT 1000];
        delete accs;
    }

    private static List<Account> generateAccounts() {
        List<String> streetsList = generateStreets();
        List<Account> newAccounts = new List<Account>();
        for (Integer i = 1; i <= ACCOUNTS_LIMIT; i++) {
            Integer streetIndex = randomWithLimit(10);
            Account acc = new Account();
            acc.Name = String.valueOf(i);
            acc.BillingPostalCode = '221701';
            acc.BillingCountry = 'Беларусь';
            acc.BillingState = 'Минск';
            acc.BillingCity = 'Минск';
            acc.BillingStreet = streetsList.get(streetIndex) + ', ' + i;
            newAccounts.add(acc);
        }
        insert newAccounts;
        return newAccounts;
    }

    private static List<Case> generateCases(List<Account> accounts) {
        List<Case> newCases = new List<Case>();
        for (Account acc : accounts) {
            newCases.addAll(createCase(acc.Id));
        }
        insert newCases;
        return newCases;
    }

    private static List<Case> createCase(Id accId) {
        List<String> streetsList = generateStreets();
        List<Case> newCases = new List<Case>();
        for (Integer i = 1; i <= 9; i++) {
            Integer streetIndex = randomWithLimit(10);
            Case c = new Case();
            c.Country__c = 'Беларусь';
            c.City__c = 'Минск';
            c.State__c = 'Минск';
            c.Postal_Code__c = '221702';
            c.Address__c = streetsList.get(streetIndex) + ', ' + (i + 1);
            c.AccountId = accId;
            newCases.add(c);
        }
        return newCases;
    }

}