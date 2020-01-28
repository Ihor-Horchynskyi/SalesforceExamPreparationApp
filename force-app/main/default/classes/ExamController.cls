public without sharing class ExamController {
	public List<SelectOption> examCategories {get; set;}
	public String selectedExamCategory {get; set;}
	public List<SelectOption> questions {get;set;}

	public List<SelectOption> getExamCategories(){
		examCategories = new List<SelectOption>();
		for(AggregateResult result : [SELECT Type__c FROM Exam__c GROUP BY Type__c]) {
			String option = (String)result.get('Type__c');
			examCategories.add(new SelectOption(option, option));
		}
        return examCategories;
	}


	public List<SelectOption> getQuestions(){
		if (selectedExamCategory != null) {
			questions = new List<SelectOption>();
			for(Exam__c exam : [SELECT Title__c FROM Exam__c WHERE Type__c =: selectedExamCategory]) {
				String option = exam.Title__c;
				questions.add(new SelectOption(option, option));
			}
		}
		return questions;
	}
}
