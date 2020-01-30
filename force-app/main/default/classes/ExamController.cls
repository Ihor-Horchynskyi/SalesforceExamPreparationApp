public without sharing class ExamController {
	public List<SelectOption> examCategories {set;}
	public List<SelectOption> questions = new List<SelectOption>();
	public List<SelectOption> answerVariantsOptions = new List<SelectOption>();

	public String selectedExamCategory {get; set;}
	public String selectedQuestionSet {get; set;}
	public String questionTitle {get; set;}
	public String previousAnswerTable {get; set;}

	public Boolean displayExamSelectionBlock {get; set;}
	public Boolean displayExamSessionBlock {get; set;}
	public Boolean displayExamAnswerBlock {get; set;}

	public Integer currentQuestionNumber = 0;

	public List<String> selectedAnswers {get; set;}
	public List<Answer__c> answerVariants = new List<Answer__c>();
	public List<String> htmlAnswerTableList = new List<String>();
	public List<String> questionsList = new List<String>();
	public Map<String, List<Answer__c> > answersToQuestionsMap = new Map<String, List<Answer__c> >();

	public ExamController() {
		displayExamSelectionBlock = true;
		selectedAnswers = new List<String>();
	}

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
		displayExamSelectionBlock = false;
		displayExamSessionBlock = true;
		List<Answer__c> answerList = [SELECT Id,
		                              Answers__c,
		                              Name,
		                              IsCorrect__c,
		                              Text__c,
		                              Question__r.Id,
		                              Question__r.Text__c
		                              FROM Answer__c
		                              WHERE Question__r.Exam__r.Title__c =: selectedQuestionSet];
		System.debug('selectedQuestionSet ' + selectedQuestionSet);
		System.debug('answerList ' + answerList);

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

	public List<SelectOption> getAnswerVariantsOptions(){
		return answerVariantsOptions;
	}

	public void refreshQuestion(){
		if(currentQuestionNumber < questionsList.size()) {
			answerVariants.clear();
			answerVariantsOptions.clear();
			questionTitle = questionsList.get(currentQuestionNumber);
			for(Answer__c answer : answersToQuestionsMap.get(questionTitle)) {
				answerVariants.add(answer);
				answerVariantsOptions.add(new SelectOption(answer.Text__c, answer.Text__c));
			}
		}
		currentQuestionNumber++;
		System.debug('Question ' + currentQuestionNumber + ' ' + questionTitle);
	}

	public void submitAnswer(){
		displayExamAnswerBlock = true;
		Boolean fail = false;
		List<String> previousAnswerList = new List<String>();
		List<String> correctAnswerList = new List<String>();
		List<String> failAnswerList = new List<String>();
		List<String> selectedAnswersList = new List<String>(selectedAnswers);
		for(Answer__c answer : answerVariants) {
			if(answer.IsCorrect__c && selectedAnswersList.contains(answer.Text__c)) {
				previousAnswerList.add('<th>&#9989</th><th>' + answer.Text__c + '</th><th>&#10004</th>');
			} else
			if(answer.IsCorrect__c && !selectedAnswersList.contains(answer.Text__c)) {
				previousAnswerList.add('<th></th><th>' + answer.Text__c + '</th><th>&#10004</th>');
				fail = true;
			} else if(selectedAnswersList.contains(answer.Text__c)) {
				previousAnswerList.add('<th>&#10060</th><th>' + answer.Text__c + '</th><th></th>');
				fail = true;
			} else{
				previousAnswerList.add('<th></th><th>' + answer.Text__c + '</th><th></th>');
			}
		}
		String columns = '';
		for(String answerString : previousAnswerList) {
			columns += '<tr>' + answerString +'</tr>';
		}
		previousAnswerTable = '<p><h1>' + (fail ? '&#10060 ' : '&#9989 ') +
		                      questionTitle + '</h1><br/></p><table style="width:100%" border="1">' +
		                      '<tr><th>Selected answer</th><th>Answer</th><th>Correct answer</th></tr>' +
		                      columns + '</table>';
		System.debug('previousAnswerTable ' + previousAnswerTable);

		htmlAnswerTableList.add(previousAnswerTable);
		refreshQuestion();
	}

	public String getPreviousAnswerTable(){
		return previousAnswerTable;
	}
}
