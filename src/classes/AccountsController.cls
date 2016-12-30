public class AccountsController {

    private static final Integer ACCOUNTS_LIMIT = 10;

    public class AccountWrapper {
        public Boolean isChecked {get; set;}
        public Account acc {get; set;}

        public AccountWrapper(Account acc, Boolean isChecked) {
            this.acc = acc;
            this.isChecked = isChecked;
        }
    }

    public Map<Id, Account> selectedAccountsMap = new Map<Id, Account>();
    public List<AccountWrapper> accounts {get; set;}

    public ApexPages.StandardSetController con {
        get {
            if (con == null) {
                con = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id FROM Account LIMIT 100]));
                con.setPageSize(10);
            }
            return con;
        }
        set;
    }

    public List<AccountWrapper> getAccount() {
        getSelectedAccount();
        accounts = new List <AccountWrapper>();
        for (Account cc : (List<Account>)con.getRecords()) {
            if ( selectedAccountsMap.ContainsKey(cc.id)) {
                accounts.add (new AccountWrapper(cc, true));
            } else {
                accounts.add(new AccountWrapper(cc, false));
            }
        }
        return accounts;
    }

    public void getSelectedAccount() {
        if (accounts != null) {
            for (AccountWrapper wr : accounts) {
                if (wr.isChecked == true) {
                    selectedAccountsMap.put(wr.acc.Id, wr.acc);
                } else {
                    selectedAccountsMap.remove(wr.acc.Id);
                }
            }
        }
    }

    public PageReference process() {
        getSelectedAccount();
        if (selectedAccountsMap.keySet().size() > ACCOUNTS_LIMIT) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'SELECT < 10 ITEMS'));
            return null;
        }
        String idsJSON = JSON.serialize(selectedAccountsMap.keySet());
        PageReference pageRef = new PageReference('https://' + ApexPages.currentPage().getHeaders().get('Host') + '/apex/AccountCasePage');
        pageRef.getParameters().put('ids', idsJSON);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }

    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }

    public void first() {
        con.first();
    }

    public void last() {
        con.last();
    }

    public void previous() {
        con.previous();
    }

    public void next() {
        con.next();
    }

    public void cancel() {
        con.cancel();
    }

}