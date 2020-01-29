public without sharing class ExamController {
	public List<SelectOption> examCategories {set;}
	public String selectedExamCategory {get; set;}
	public String selectedQuestionSet {get; set;}
	public List<SelectOption> questions = new List<SelectOption>();

	public List<SelectOption> getExamCategories(){
		List<SelectOption> examCategoryList = new List<SelectOption>();
		examCategoryList.add(new SelectOption('--None--', '--None--'));
		for(AggregateResult result : [SELECT Type__c FROM Exam__c GROUP BY Type__c]) {
			String option = (String)result.get('Type__c');
			examCategoryList.add(new SelectOption(option, option));
		}
		return examCategoryList;
	}

	public PageReference getQuestionList(){
		System.debug('selectedExamCategory ' + selectedExamCategory);
		
		List<SelectOption> questionList = new List<SelectOption>();
		if (selectedExamCategory != null) {
			for(Exam__c exam : [SELECT Title__c FROM Exam__c WHERE Type__c =: selectedExamCategory]) {
				String option = exam.Title__c;
				questionList.add(new SelectOption(option, option));
			}
		} else  {
			questionList.add(new SelectOption('--None--', '--None--'));
		}
		questions.clear();
		questions.addAll(questionList);
		return null;
	}

	public List<SelectOption> getQuestions(){
		return questions;
	}

	public String getSelectedQuestionSet(){
		if (selectedQuestionSet == null || selectedQuestionSet == '') {
			selectedQuestionSet = '--None--';
		}
		return selectedQuestionSet;
	}

	public void submit(){
		
	}
}
