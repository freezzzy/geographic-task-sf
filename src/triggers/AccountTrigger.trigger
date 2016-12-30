trigger AccountTrigger on Account (after insert) {
    Set<Id> newAccountsIds = Trigger.newMap.keySet();
    AccountHandler.setCoordinates(newAccountsIds);
}