trigger CaseTrigger on Case (after insert) {
    Set<Id> newCasesIds = Trigger.newMap.keySet();
    CaseHandler.setCoordinates(newCasesIds);
}