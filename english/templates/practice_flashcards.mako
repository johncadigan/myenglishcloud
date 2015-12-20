<%inherit file="unilayout.mako"/>


<%def name="page_title()">
  
</%def>

  <%def name="styleSheetIncludes()">
   <link href="${request.static_url('english:/static/css/drill.css')}" rel="stylesheet">
  </%def>

  <%def name="styleSheet()">

/* Individual styles for each color: */

.countdown .bg.left{ background:url(${request.static_url('english:/static/images/sm_blue.png')}) no-repeat left top; }


/* The right part of the background: */
.clock .bg.right{ left:50px; }
.countdown .bg.right{ background:url(${request.static_url('english:/static/images/sm_blue.png')}) no-repeat right top; }


  </%def>

  <%def name="javascriptIncludes()">
	<!--/AJAX form-->
	<script src="${request.static_url('english:/static/js/jquery.form.js')}"></script>  
  </%def>

  <%def name="javascript()">

	  
  </%def>

  <%def name="documentReady()">
(function($){
    $.fcardDrill = function(element, options) {
        var $element = $(element),
             element = element;

        var plugin = this;
        
        var defaults = {
            checkAnswerText:  'Check',
            nextQuestionText: 'Next &raquo;',
	    quitText: 'Save and Quit',
            randomSort: false,
            randomSortQuestions: false,
            randomSortAnswers: false,
            preventUnanswered: false,
        };
        
        plugin.config = $.extend(defaults, options);
	
	var cdVars = {'interval': false, 'count' : 1, 'final_score' : 0};

        var selector = $(element).attr('id');
        
        var triggers = {
            starter:         '#' + selector + ' .startDrill',
            checker:         '#' + selector + ' .checkAnswer',
            next:            '#' + selector + ' .nextFCard',
	    nextCard:        '#' + selector + ' .nextCard',
            pause:           '#' + selector + ' .pause',
	    continueDrill:   '#' + selector + ' .continue',
	    incorrect:       '#' + selector + ' .incorrectButton',
	    correct:         '#' + selector + ' .correctButton',
	    save: 	     '#' + selector + ' .saveButton',
	    
        }

        var targets = {
            drillArea:        '#' + selector + ' .drillArea',
            drillResults:     '#' + selector + ' .drillResults',
            drillResultsCopy: '#' + selector + ' .drillResultsCopy',
            drillHeader:      '#' + selector + ' .drillHeader',
            drillScore:       '#' + selector + ' .drillScore',
	    drillForm: '#point-form',

        }
        // Set via json option or drillJSON variable
       var drillValues = (plugin.config.json ? plugin.config.json : typeof drillJSON != 'undefined' ? drillJSON : null);
       
       var flashcards = plugin.config.randomSort || plugin.config.randomSortQuestions ?
                        drillValues.flashcards.sort(function() { return (Math.round(Math.random())-0.5); }) :
                        drillValues.flashcards;
        var flashcardCount = flashcards.length;
	
	if(flashcardCount > 0){
	$('#start_button').html('Start!');
	$('#start_button').removeClass('invisible');
	$('#start_button').addClass('startDrill');
	}
	var flashcardsTobe = [];
	var flashcardsTochange = [];
	var flashcardIdentity = [];
	var points = [];
	var levels = [];

        plugin.method = {

	     expandDrill : function(flashcardnum){

		drill = $('#drill');
		form = $(targets.drillForm);
		count = cdVars['count'];
		
                cardHTML = '';
                
		       if(flashcardsTobe[flashcardnum] == true && cdVars[flashcardnum]=='Show'){            
                       		cardHTML = plugin.method.setupCard(flashcardnum,count, cdVars[flashcardnum]);
		        }
		       	else if(flashcardsTobe[flashcardnum] == true && count <= flashcardCount) {
			cardHTML = plugin.method.setupCard(flashcardnum,count, cdVars[flashcardnum]);
			}
			
  		    response_input = '<input type="hidden" id="response'+(count - 1)+'" name="response'+(count - 1)+'" value="None">';
  		    score_input = '<input type="hidden" class="score_holder" id="score'+(count - 1)+'" name="score'+(count - 1)+'" value=0>';
  		    time_input = '<input type="hidden" class="time_holder" id="time'+(count - 1)+'" name="time'+(count - 1)+'" value=20>';
level_input = '<input type="hidden" class="level_holder" id="level'+(count - 1)+'" name="level'+(count - 1)+'" value="'+levels[flashcardnum]+'">'
card_input = '<input type="hidden" class="card_holder" id="card'+(count - 1)+'" name="card'+(count - 1)+'" value="'+flashcardIdentity[flashcardnum]+'">';
correct_input = '<input type="hidden" class="correct_holder" id="correct'+(count - 1)+'" name="correct'+(count - 1)+'" value="None">';
		    form_input = response_input + score_input + time_input + level_input + card_input + correct_input;
                      

              	   
		   drill.append(cardHTML);
            	   form.append(form_input);     
		   cdVars['count'] += 1;  	    

	    },

            translateLevel: function(level){

if(level=='Flashcard1'||level=='Flashcard2'||level=='Flashcard3'||level=='Flashcard4'||level=='Flashcard5'||level=='Flashcard6'||level=='Flashcard7'||level=='Flashcard8'){
	    return 'Flashcard';
	    }
	    else{
	    return level;
	    }


	    },
	    calculateLength: function(fcards) {
	     
	     drillLength = 0;

	     for(i in fcards)
		{
			level = fcards[i].level;
			pnts = fcards[i].points;
			position = fcards[i].position;
			levels[position] = level;
			points[position] = pnts;
if(level=='Flashcard1'||level=='Flashcard2'||level=='Flashcard3'||level=='Flashcard4'||level=='Flashcard5'||level=='Flashcard6'||level=='Flashcard7'||level=='Flashcard8'){
			number = level.replace(/(Flashcard)/, '');
			points[position]*= number
			level = 'Flashcard';
			}
			switch(level)
				{
				case 'Show': 
				drillLength+=6;
				cdVars[position] = 'Show';
				break;
				case '4Source':
				drillLength+=5;
				cdVars[position] = '4Source';
				break;
				case '8Source':
				cdVars[position] = '8Source';
				drillLength+=4;
				break;
				case '4Target':
				cdVars[position] = '4Target';
				drillLength+=3;
				break;
				case '8Target':
				cdVars[position] = '8Target';
				drillLength+=2;
				break;
				case 'Flashcard':
				drillLength+=1
				cdVars[position] = 'Flashcard';
				break;
				}
		  }		
		return drillLength;
		
	    },

             setupDrill: function() {               

                // Setup flashcards
                var drill  = $('<div class="drillCards" id ="drill"></div>'),
                    form = $(targets.drillForm),
		    count = 1;
   		$(targets.drillArea).append(drill);
	        // Add the flashcard content to the page
  		$(targets.drillArea).append(drill);
                form.append('<input type="hidden" class="current_card" id="current_card" name="current_card" value="0">'); 

              // Add the form which records the results
		$('#saveAndquit').hide()
		flashcardCount = plugin.method.calculateLength(flashcards);
		for (i in flashcards) {
                    if (flashcards.hasOwnProperty(i)){
			position = flashcards[i].position;
			level = flashcards[i].level;
			identity = flashcards[i].cid
			flashcardIdentity[position] = identity;
			flashcardsTobe[position] = true;
			cdVars[position] = plugin.method.translateLevel(level);			
			a = position-1;
			b = position;			
			if(position % 2 == false && cdVars[a] == 'Show' && cdVars[b] == 'Show'){			
			plugin.method.expandDrill(a);
			plugin.method.expandDrill(b);
			flashcardsTobe[a] = true;
			cdVars[a]='4Source';
			levels[a]= '4Source';
			flashcardsTobe[b] = true;
			cdVars[b]='4Source';
			levels[b]= '4Source';
			plugin.method.expandDrill(a);
			plugin.method.expandDrill(b);
			flashcardsTobe[a] = false;			
			flashcardsTobe[b] = false;							    	
			}
			else if(b == flashcards.length && b % 2  && cdVars[b] == 'Show'){
			plugin.method.expandDrill(b);
			flashcardsTobe[b] = true;
			cdVars[b]='4Source';
			levels[b] = '4Source';
			plugin.method.expandDrill(b);
			flashcardsTobe[b] = false;
			}
			else if(cdVars[b] != 'Show'){
			plugin.method.expandDrill(b);
			flashcardsTobe[b] = false;
			}
		    }
		};
				            
		plugin.bindButtons();
 	
                // Toggle the start button
               $(triggers.starter).fadeIn(500);
            },


	    setupCard : function(flashcardnum, count, cardType) {
			

		
			flashcard = flashcards[flashcardnum-1];
				    	
			var flashcardHTML = $('<div class="flashcard row-fluid '+cardType+'" id="flashcard' + (count - 1) + '"></div>');

  			var flashcardmain = $('<div class="flashcardmain col-lg-9 col-md-9 col-sm-9 col-xs-9"></div>');

                        flashcardHTML.append('<div class="progress col-lg-12 col-md-12 col-sm-12 col-xs-12"><div class="bar" style="width:'+(100*cdVars['count']/flashcardCount)+'%;"></div></div><div class="col-lg-4 col-md-4 col-sm-4 col-xs-4"></div>');

                        var pictureHTML = '<div class="flashcard-picture col-lg-3 col-md-3 col-sm-3 col-xs-3"><img class="img-responsive" src="'+flashcard.picture+'"></div>';
                        

			var score = '<span class="score lead"></span><br>'
			var scoreMessage = '<span class="score-message"></span>'
                        var fcardinfoHTML = $('<div class="flashcard-info col-lg-6 col-md-6 col-sm-6 col-xs-6"></div>');
                        var translationHTML = $('<ul class="translations list-inline lead"></ul>');
                        var drillControls = $('<div class="drill-controls col-lg-2 col-md-2 col-sm-2 col-xs-2"></div>');
                        var clock = '<div id="blue-clock"></div>';
                        var pause = '<br><a href="" class="btn btn-default btn-lg pause"><i class="icon-pause"></i></a>';
			var continueDrill = '<br><a href="" class="btn btn-default btn-lg continue"><i class="icon-play"></i></a>'
                        drillControls.append(score);
			drillControls.append(scoreMessage);
			drillControls.append(clock);
			drillControls.append(pause);
			drillControls.append(continueDrill);                                                
                        drillControls.append('<input type="submit" class="saveButton btn btn-default btn-lg" class="offset9" name="Report" value="'+plugin.config.quitText+'">');
			if(cardType!='4Source' && cardType!='8Source'){                        
                        for (i in flashcard.translations) {
                            if (flashcards.hasOwnProperty(i)) {
                                var translation = flashcard.translations[i]
                        translationHTML.append('<li><h2>' + translation + '</h2></li>');
                            }
                        };
                        translationHTML.append('<li class="answer green lead pull-right"><h2 id="answer">'+flashcard.answer+'</h2></li>');
                        }
			else if(cardType=='4Source' || cardType=='8Source'){
			translationHTML.append('<li><h2>' + flashcard.answer + '<h2></li>');
			translationHTML.append('<li id="answer" class="green answer lead pull-right"><h2>'+flashcard.translations[0]+'</h2></li>');
			}

			fcardinfoHTML.append(translationHTML);
			fcardinfoHTML.append('<span class="label label-large label-info ">'+flashcard.pos+'</span>');

			if(cardType=='Show'){
			sentence = flashcard.sentence;
			newSentence = sentence.replace('____', '<strong>'+flashcard.answer+'</strong>');
			fcardinfoHTML.append('<div class="row-fluid sentence"><h2>'+newSentence+'</h2></div>');
			}
			else{
			fcardinfoHTML.append('<div class="row-fluid sentence"><h2>'+flashcard.sentence+'</h2></div>');
			}

			
                        
                        
			var fcardcontrols = $('<span class="row block"></span>');
			var inputName  = 'flashcard' + (count - 1);
                        
			if(cardType=='Flashcard'){
                        var input = '<input class="row-fluid input" id="' + inputName + '" name="' + inputName
                                    + '" type="text"/><br>';
                        fcardinfoHTML.append(input);
                        fcardcontrols.append('<a href="" id="'+flashcard.position+'"class="btn btn-default btn-lg checkAnswer offset1">' + plugin.config.checkAnswerText + '</a>');
			}
			
			else if(cardType=='4Source'||cardType=='8Source'||cardType=='4Target'||cardType=='8Target')
			{
			var distractorArray = [];
			if(cardType=='4Source')
				{
				distractorArray = flashcard.sourceDistractors.slice(0,3);
				orderArray = [0,1,2,3];
				answer = flashcard.translations[0];				
				panel = plugin.method.setupBPanel(distractorArray, orderArray, answer);
				fcardcontrols.append(panel);
				}
			else if(cardType=='8Source')
				{
				distractorArray = flashcard.sourceDistractors;
				orderArray = [0,1,2,3,4,5,6,7];
				answer = flashcard.translations[0];
				panel = plugin.method.setupBPanel(distractorArray, orderArray, answer);
				fcardcontrols.append(panel);
				}
			else if(cardType=='4Target')
				{
				distractorArray = flashcard.targetDistractors.slice(0,3);
				orderArray = [0,1,2,3];
				answer = flashcard.answer
				panel = plugin.method.setupBPanel(distractorArray, orderArray, answer);
				fcardcontrols.append(panel);
				}
			else if(cardType=='8Target')
				{
				distractorArray = flashcard.targetDistractors;
				orderArray = [0,1,2,3,4,5,6,7];
				answer = flashcard.answer
				panel = plugin.method.setupBPanel(distractorArray, orderArray, answer);
				fcardcontrols.append(panel);
				}
			
			}
				
                        
			if(cardType!='Show'){
			flashcardmain.append('<a href="" class="btn btn-default btn-lg nextFCard offset1" id="' +flashcard.position+ '" >' + plugin.config.nextQuestionText + '</a>');			
			}
			else if(cardType=='Show'){
			flashcardmain.append('<a href="" class="btn btn-default btn-lg nextCard offset1" id="' +flashcard.position+ '" >' + plugin.config.nextQuestionText + '</a>');			
			}


                        fcardinfoHTML.append(fcardcontrols);
			flashcardmain.append(pictureHTML);
                        flashcardmain.append(fcardinfoHTML);
			
			
			flashcardHTML.append(flashcardmain);
			flashcardHTML.append(drillControls);


			return '<div class="flashcard row-fluid '+cardType+'" id="flashcard' + (count - 1) + '">'+flashcardHTML.html()+'</div>';


            },

	    setupBPanel: function(distractorArray, orderArray, answer){

			panel = $('<div class="selection-panel absolute-centered col-lg-12 col-md-12 col-sm-12 col-xs-12 container"></div>')
			var selectionArray = {};
			for (i in distractorArray){
				response = '<a href="" id="'+flashcard.position+'"class="btn btn-default btn-lg col-lg-5 col-md-5 col-sm-5 col-xs-5 incorrectButton">' + distractorArray[i] + '</a>';
				selectionArray[i] = response;
			   }
selectionArray[distractorArray.length] ='<a href="" id="'+flashcard.position+'"class="btn btn-default btn-lg col-lg-5 col-md-5 col-sm-5 col-xs-5 correctButton">'+answer+'</a>';			
			
			RorderArray = plugin.method.shuffle(orderArray);
			for (i in RorderArray){
				indx = new Number(i);
				num = new Number(indx+1);
				if(num %2){
				c = RorderArray[indx];
				d = RorderArray[num];;
				buttonLayer=$('<span class="col-lg-12 col-md-12 col-sm-12 col-xs-12 row-fluid"><span><br>');
				Abutton = selectionArray[c];
				Bbutton = selectionArray[d]
				//Abutton = $(Abutton).addClass('pull-left');
				//Bbutton = $(Bbutton).addClass('pull-right');
				buttonLayer.append(Abutton);
				buttonLayer.append(Bbutton);
				panel.append(buttonLayer);
				}
			     }
		panelHTML =  panel;
		return panelHTML;

	    },

                        
            setupClock : function(clock) {
        
			var tmp    = $(clock).attr('class','countdown clock').html(
				'<div class="display"></div>'+
				
				'<div class="front left"></div>'+
				
				'<div class="rotate left">'+
					'<div class="bg left"></div>'+
				'</div>'+
				
				'<div class="rotate right">'+
					'<div class="bg right"></div>'+
				'</div>'
			);
			
			$(clock).append(tmp);
                	
			// Assigning some of the elements as variables for speed:
			tmp.rotateLeft = tmp.find('.rotate.left');
			tmp.rotateRight = tmp.find('.rotate.right');
			tmp.display = tmp.find('.display');
			
			if(cdVars.interval){
			clearInterval(cdVars.intervalID);
			}

			cdVars['clock'] = tmp;
			cdVars['timeLeft']= 19;
			cdVars['pause'] = false;
			cdVars['interval'] = true;

		    cdVars['intervalID'] = setInterval(function(){
			
			if(cdVars.timeLeft <= -1){
			$(cdVars.clock).hide();
			$(cdVars.clock).siblings('.pause').hide();
			flashcardDIV = $($(cdVars.clock).parents('div.flashcard')[0]);
			fcardnum = flashcardDIV.attr('id').replace(/(flashcard)/, '');
			plugin.method.noAnswer(fcardnum);		
			}

			if(!cdVars.pause){
			plugin.method.animation(cdVars.clock, cdVars.timeLeft, 20);
			cdVars.timeLeft -= .25;
			}

	    	    },250);  

            },
            
		animation: function(clock, current, total)
	    {
        // Calculating the current angle:
        var angle = (360/total)*(current+1);

        var element;
        if(current==0)
        {
            // Hiding the right half of the background:
            clock.rotateRight.hide();
            // Resetting the rotation of the left part:
            plugin.method.rotateElement(clock.rotateLeft,0);        
	}

        if(angle<=180)
        {
            // The left part is rotated, and the right is currently hidden:
            clock.rotateRight.hide();
	    element = clock.rotateLeft;
								
        }
        else
        {
            // The first part of the rotation has completed, so we start rotating the right part:
            clock.rotateRight.show();
            clock.rotateLeft.show();

            plugin.method.rotateElement(clock.rotateLeft,180);
            element = clock.rotateRight;

            angle = angle-180;
        }
		plugin.method.rotateElement(element,angle);

        // Setting the text inside of the display element, inserting a leading zero if needed:
        //clock.display.html(current+1);

	},
            rotateElement: function(element,angle)
	{
		// Rotating the element, depending on the browser:
		var rotate = 'rotate('+angle+'deg)';
		
		if(element.css('MozTransform')!=undefined)
			element.css('MozTransform',rotate);
			
		else if(element.css('WebkitTransform')!=undefined)
			element.css('WebkitTransform',rotate);
	
		// A version for internet explorer using filters, works but is a bit buggy (no surprise here):
		else if(element.css("filter")!=undefined)
		{
			var cos = Math.cos(Math.PI * 2 / 360 * angle);
			var sin = Math.sin(Math.PI * 2 / 360 * angle);
			
			element.css("filter","progid:DXImageTransform.Microsoft.Matrix(M11="+cos+",M12=-"+sin+",M21="+sin+",M22="+cos+",SizingMethod='auto expand',FilterType='nearest neighbor')");
	
			element.css("left",-Math.floor((element.width()-100)/2));
			element.css("top",-Math.floor((element.height()-100)/2));
		}
	
	},
            
            startDrill: function(startButton) {
                $(startButton).fadeOut(300, function()
               {var firstFCard = $('#' + selector + ' .drillCards div').first();
                    if (firstFCard.length) {
                        firstFCard.fadeIn(500);
                    }
		plugin.method.setupClock('#blue-clock');
		$('#saveAndquit').show()

		});


            },

	    pauseDrill: function(pauseButton) {

		cdVars['pause'] = true;
		$(pauseButton).siblings('.continue').show();
		$(pauseButton).parents('.drill-controls').siblings('.flashcardmain').hide();
		$(pauseButton).parents('.drill-controls').addClass('offset9');				
		$(pauseButton).hide();

		

	    },

	    continueDrill: function(continueButton) {
		
		cdVars['pause'] = false;
		$(continueButton).siblings('.pause').show();
		$(continueButton).hide();
		$(continueButton).parents('.drill-controls').removeClass('offset9');	
		$(continueButton).parents('.drill-controls').siblings('.flashcardmain').show();



            },

            clickAnswer: function(checkButton) {

		flashcardDIV = $($(checkButton).parents('div.flashcard')[0]);
		plugin.method.checkAnswer(flashcardDIV);
	     
            },
	    
	  moveUp: function(ctype){

	    if(ctype=='Show'){
		return '4Source';
		}
	    else if(ctype=='4Source'){	
		return '8Source';
		}
	    else if(ctype=='8Source'){		
		return '4Target';
		}
	    else if(ctype=='4Target'){
		return '8Target';
		}
	    else if(ctype=='8Target'){		
		return 'Flashcard1';
		}
	    else if(ctype=='Flashcard1'){		
		return 'Flashcard2';
		}
	    else if(ctype=='Flashcard2'){		
		return 'Flashcard3';
		}
	    else if(ctype=='Flashcard3'){		
		return 'Flashcard4';
		}
	    else if(ctype=='Flashcard4'){		
		return 'Flashcard5';
		}
	    else if(ctype=='Flashcard5'){		
		return 'Flashcard6';
		}
	    else if(ctype=='Flashcard6'){		
		return 'Flashcard7';
		}
	    else if(ctype=='Flashcard7'){		
		return 'Flashcard8';
		}
	    else{
		return ctype;
		}
	    },

	    reportScore: function(flashcardnum, score){
	    
	    scoreHTML = '';
            scoreHTML = '<br><h1 class=" blue">+'+score+' points</h1>';
	    flashcard = $('#flashcard'+flashcardnum);
	    flashcard.find('.drill-controls').find('.score').html(scoreHTML).fadeOut(1500);

	    },

            writeRecord: function(flashcardnum, response, score, time, correct){

	    $(targets.drillForm).find('#response'+flashcardnum).val(response);
	    $(targets.drillForm).find('#score'+flashcardnum).val(score);
	    $(targets.drillForm).find('#time'+flashcardnum).val(time);
	    $(targets.drillForm).find('#correct'+flashcardnum).val(correct);

	    },

	    endCard: function(flashcardnum){

            flashcard = $('#flashcard'+flashcardnum)
	    flashcard.find('.answer').show();	    
	    
	    if(flashcard.hasClass('4Source')||flashcard.hasClass('8Source')||flashcard.hasClass('4Target')||flashcard.hasClass('8Target')){	    
	    flashcard.find('.incorrectButton').addClass('btn-danger');
	    flashcard.find('.correctButton').addClass('btn-success');
	    }
            	    
	    flashcard_time = $(targets.drillForm).find('#current_card').val(flashcardnum);
	    $(cdVars.clock).siblings('.pause').hide();
	    $(cdVars.clock).hide();
	    flashcard.find('.nextFCard').fadeIn(300);

	    },
	    
	    noAnswer: function(flashcardnum){
	    
	    plugin.method.writeRecord(flashcardnum, 0, 0, 0, 'False');
	    plugin.method.endCard(flashcardnum);
	    
	    },

	   clickIncorrect : function(IncorrectButton) {
			
		//Get card information
		flashcardDIV = $($(IncorrectButton).parents('div.flashcard')[0]);
		flashcardnum = flashcardDIV.attr('id').replace(/(flashcard)/, '')
		
		//Log answer
		plugin.method.reportScore(flashcardnum, 0);
		plugin.method.writeRecord(flashcardnum, IncorrectButton.innerHTML, 0, cdVars.timeLeft, 'False');
		plugin.method.endCard(flashcardnum);

		//Prepare for next version of this card
		fposition = IncorrectButton.id;
		flashcardsTobe[fposition] = true;
		flashcardsTochange[fposition] = false;

	    },

	    clickCorrect : function(CorrectButton) {
		
		//Get card information
		flashcardDIV = $($(CorrectButton).parents('div.flashcard')[0]);
		flashcardnum = flashcardDIV.attr('id').replace(/(flashcard)/, '')		
		fposition = CorrectButton.id;
		
		//Log answer
		plugin.method.reportScore(flashcardnum, 20);		
		plugin.method.endCard(flashcardnum);
		plugin.method.writeRecord(flashcardnum, CorrectButton.innerHTML, 20, cdVars.timeLeft, 'True');

		//Prepare for next version of card
		flashcardsTobe[fposition] = true;
		flashcardsTochange[fposition] = true;

	    },
           
            checkAnswer: function(flashcardDIV) {
            
 	    //Get card information              
            checkButton = flashcardDIV.find('.checkAnswer');
	    fposition = checkButton.attr('id')
	    flashcardnum = flashcardDIV.attr('id').replace(/(flashcard)/, '');


	    //Score card
	    answer = flashcardDIV.find('#answer').html();
            response = flashcardDIV.find('input:text').val();
            lscore = plugin.method.modLevenshtein(response, answer);
            basescore = points[fposition];
            result_score = Math.round(lscore * basescore)
	    correct = 'False'
	    if(result_score < 0){
            result_score=0;
            }
            if(result_score >= Math.round(basescore*1)){
                var result_text = '<span class="green lead">'+response+"<br>Correct!</span>";
		correct = 'True'

		}
	    else if(Math.round(basescore * 1) > result_score && result_score > Math.round(basescore * .9)){
		var result_text = '<span class="gree lead">'+response+"<br>So close!</span>";

		}
            else if(Math.round(basescore *.9) > result_score && result_score > Math.round(basescore *.5)){
                var result_text = '<span class="orange lead">'+response+"<br>Almost!</span>";

                }
            if(Math.round(basescore*.5) > result_score){
                var result_text = '<span class="red lead">'+response+"<br>Incorrect!</span>";
                }
                if(response==''){
                var result_text = '<span class="red lead">No answer</span>';
                }

	    flashcardDIV.find('.input').hide();
	    flashcardDIV.find('.checkAnswer').hide();

	    flashcardDIV.find('.drill-controls').find('.score-message').html(result_text);
	    
	    //Log answer
            plugin.method.writeRecord(flashcardnum, answer, result_score, cdVars.timeLeft, correct);
            plugin.method.endCard(flashcardnum);
            plugin.method.reportScore(flashcardnum, result_score);
            },
            
            nextFlashcard: function(nextButton) {
                var currentFlashcard = $($(nextButton).parents('div.flashcard')[0]),
                    nxtFlashcard    = currentFlashcard.next('.flashcard');
                plugin.method.setupClock($(nxtFlashcard).find('#blue-clock'));    
             if (nxtFlashcard.length) {
                 currentFlashcard.fadeOut(300, function(){
                 nxtFlashcard.find('.backToFlashcard').show().end().fadeIn(500);
		if(flashcardsTochange[nextButton.id] == true){
		levels[fposition]= plugin.method.moveUp(levels[nextButton.id]);
		cdVars[fposition]= plugin.method.translateLevel(levels[nextButton.id]);
		flashcardsTochange[nextButton.id] = false;
		}
		if(flashcardsTobe[nextButton.id]==true && levels[fposition] !='Show'){
		plugin.method.expandDrill(nextButton.id);
		plugin.bindButtons();
		flashcardsTobe[nextButton.id] = false;
		}
		});
                } else {
                 plugin.method.completeDrill();
                }   
                
            },
            
            completeDrill: function() {

	    final_score = plugin.method.calculateTotalscore(targets.drillForm);
            $(targets.drillScore + ' span').html(final_score+' points');
            $(targets.drillArea).fadeOut(300);
            $(targets.drillResults).fadeIn(1000);
	    $(targets.drillForm).submit();
	    

            },
            
 	    shuffle: function(array) {
  		var currentIndex = array.length, 
		temporaryValue, 
		randomIndex;

  		// While there remain elements to shuffle...
  		while (0 !== currentIndex) {
    			// Pick a remaining element...
    			randomIndex = Math.floor(Math.random() * currentIndex);
    			currentIndex -= 1;

    			// And swap it with the current element.
    			temporaryValue = array[currentIndex];
    			array[currentIndex] = array[randomIndex];
   			array[randomIndex] = temporaryValue;
  		}
	
  	return array;
	},

	removeItem : function(array, item) {
	
	for(var i = array.length - 1; i >= 0; i--) {
    		if(array[i] === item) {
       		array.splice(i, 1);
    		}
	}
	
	return array;
	
	},
	calculateTotalscore: function (form) {
            var sum = 0,
            frm = $(form)
    frm.find('input.score_holder').each(function( index, elem ) {
            var val = parseFloat($(elem).val());
            if(!isNaN(val)){
                sum += val;
            }
           });
            return (sum.toFixed(2));
        },
            
            
            modLevenshtein: function (s1, s2) {
            if (s1 == s2) {
            return 1;
            }
 
            var s1_len = s1.length;
            var s2_len = s2.length;
            if (s1_len === 0) {
            return 0;
            }
            if (s2_len === 0) {
            return 0;
            }
 
            // BEGIN STATIC
            var split = false;
            try{
            split=!('0')[0];
            } catch (e){
            split=true; // Earlier IE may not support access by string index
            }
            // END STATIC
            if (split){
            s1 = s1.split('');
            s2 = s2.split('');
            }
 
            var v0 = new Array(s1_len+1);
            var v1 = new Array(s1_len+1);
 
            var s1_idx=0, s2_idx=0, cost=0;
            for (s1_idx=0; s1_idx<s1_len+1; s1_idx++) {
            v0[s1_idx] = s1_idx;
            }
            var char_s1='', char_s2='';
            for (s2_idx=1; s2_idx<=s2_len; s2_idx++) {
            v1[0] = s2_idx;
            char_s2 = s2[s2_idx - 1];
 
            for (s1_idx=0; s1_idx<s1_len;s1_idx++) {
            char_s1 = s1[s1_idx];
            cost = (char_s1 == char_s2) ? 0 : 1;
            var m_min = v0[s1_idx+1] + 1;
            var b = v1[s1_idx] + 1;
            var c = v0[s1_idx] + cost;
            if (b < m_min) {
            m_min = b; }
            if (c < m_min) {
            m_min = c; }
            v1[s1_idx+1] = m_min;
            }
            var v_tmp = v0;
            v0 = v1;
            v1 = v_tmp;
            }
            return 1.0-(v0[s1_len]/s2.length);
            }
            
        }
        
	plugin.bindButtons = function(){

	// Bind "start" button
            $(triggers.starter).on('click', function(e) {
                e.preventDefault();
                plugin.method.startDrill(this);
            });
            
	    $(triggers.next).on('click', function(e) {
                e.preventDefault();
                plugin.method.nextFlashcard(this);
            });

            $(triggers.checker).on('click', function(e) {
                e.preventDefault();
                plugin.method.clickAnswer(this);
            });

            $(triggers.incorrect).on('click', function(e) {
                e.preventDefault();
                plugin.method.clickIncorrect(this);
            });

            $(triggers.correct).on('click', function(e) {
                e.preventDefault();
                plugin.method.clickCorrect(this);
            });


	    $(triggers.nextCard).on('click', function(e) {
                e.preventDefault();
                plugin.method.nextFlashcard(this);
            });

            $(triggers.pause).on('click', function(e) {
                e.preventDefault();
                plugin.method.pauseDrill(this);
            });


	    $(triggers.continueDrill).on('click', function(e) {
                e.preventDefault();
                plugin.method.continueDrill(this);
            });

	   $(triggers.save).on('click', function(e) {
                e.preventDefault();
                plugin.method.completeDrill(this);
            });


	}


        plugin.init = function(){
            
            plugin.method.setupDrill();
            
          
        }
         
        plugin.init();

    }

    $.fn.fcardDrill = function(options) {
        return this.each(function() {
            if (undefined == $(this).data('fcardDrill')) {
                var plugin = new $.fcardDrill(this, options);
                $(this).data('fcardDrill', plugin);
            }
        });
    }
})(jQuery);



var drillJSON = {'flashcards':
    ${flashcard_json | n}
};

$(function () {
    $('#fcardDrill').fcardDrill();
});




var drillJSON = {'flashcards':
    ${flashcard_json | n}
};

$(function () {
    $('#fcardDrill').fcardDrill();
});



  </%def>

<%def name="navbar()">
<%include file="toolbar.mako" args="groupname=group, current='tag_index', user='${username}', flashcard_deck=flashcards"/>
</%def>

<%def name="sidebar()">

</%def>


<%def name="body()">

<div id="fcardDrill">
        <div class="drillArea">
            <div class="drillHeader">
                <!-- where the quiz main copy goes -->

                <div class="centerDiv"><a id="start_button" class=" btn btn-default btn-lg text-center" href="${request.route_url('my_flashcards')}">No flashcards!</a></div>
            </div>

            <!-- where the quiz gets built -->
        </div>
	<div id="formArea"></div>
        <div class="drillResults">
            <h3 class="drillScore">You Scored <span><!-- where the quiz score goes --></span></h3>

            <div class="drillResultsCopy">
                <!-- where the quiz result copy goes -->
            </div>
        </div>
</div>

<div class="invisible" id="point-results">
<form id="point-form" method=POST action=${request.route_url('report_drill_results')}>
<input type="hidden" name="activity_type" value='drill'>
<input type="text" name="activity_id" value=${drill}>
<input type="submit" name="Report" value="My flashcards">
</form>
</div>

<script>
$(window).resize(function(){

    $('.centerDiv').css({
        position:'absolute',
        left: ($(window).width() - $('.className').outerWidth())/2,
        top: ($(window).height() - $('.className').outerHeight())/2
    });

});

// To initially run the function:
$(window).resize();
</script>

</%def>
