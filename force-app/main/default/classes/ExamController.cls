public without sharing class ExamController {
	public List<SelectOption> examCategories {set;}
	public List<SelectOption> questions = new List<SelectOption>();
	public List<SelectOption> answerVariants {get; set;}

	public String selectedExamCategory {get; set;}
	public String selectedQuestionSet {get; set;}
	public String selectedAnswers {get; set;}
	public String questionTitle {get; set;}

	public Boolean displayExamSelectionBlock {get; set;}
	public Boolean displayExamBlock {get; set;}

	public Integer currentQuestionNumber = 0;

	public List<String> questionsList = new List<String>();
	public Map<String, List<Answer__c> > answersToQuestionsMap = new Map<String, List<Answer__c> >();

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

	public void startExam(){
		List<Answer__c> answerList = [SELECT Id,
		                              Answers__c,
		                              Name,
		                              IsCorrect__c,
		                              Text__c,
		                              Question__r.Id,
		                              Question__r.Text__c
		                              FROM Answer__c
		                              WHERE Question__r.Exam__r.Title__c =: selectedQuestionSet];
		for(Answer__c answer : answerList) {
			if(!answersToQuestionsMap.containsKey(answer.Question__r.Text__c)) {
				answersToQuestionsMap.put(answer.Question__r.Text__c, new List<Answer__c> {answer});
			} else {
				answersToQuestionsMap.get(answer.Question__r.Text__c).add(answer);
			}
		}

		questionsList.addAll(answersToQuestionsMap.keySet());
		refreshQuestion();
	}

	public void refreshQuestion(){
		if(currentQuestionNumber < questionsList.size()) {
			questionTitle = questionsList.get(currentQuestionNumber);
			for(Answer__c answer : answersToQuestionsMap.get(questionTitle)) {
				answerVariants.add(new SelectOption(answer.Text__c, answer.Text__c));
			}
		}
		currentQuestionNumber++;
	}

	public void submitAnswer(){
		refreshQuestion();
	}
}
