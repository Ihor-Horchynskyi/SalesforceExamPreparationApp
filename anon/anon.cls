class anon {
	public void doStuff(){
		delete [SELECT Id FROM Exam__c];
		delete [SELECT Id FROM Answer__c];
		delete [SELECT Id FROM Question__c];
	}
}