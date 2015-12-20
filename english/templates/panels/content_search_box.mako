##content_search_box.mako

<%page args="user, search, action"/>

<%def name='search_content(user, search, action)'>

<form id='search' class='col-lg-offset-3 col-md-offset-3 col-sm-offset-3 form-inline' method='GET' action=${action}>


<legend class='lead'>Search</legend>


<label for="content_type" class="control-label">Filter: </label>
<select name = 'content_type' class="form-control">
  %for ctype,word in [('all', 'Any'),('lesson','Lessons'), ('reading','Readings')]:
      %if search['content_type'] == ctype:
	<option value=${ctype} selected='selected'>${word}</option>          
       %else:
	<option value=${ctype}>${word}</option>
       %endif
  %endfor
</select>

<label for="results_limit" class="control-label">Results: </label>
<select name = 'results_limit' class="form-control">
  %for num in ['15', '30', '45']:
      %if search['results_limit'] == num:
	<option value=${num} selected='selected'>${num}</option>          
       %else:
	<option value=${num}>${num}</option>
       %endif
  %endfor
</select>


<label for="upload_date" class="control-label">Upload Date: </label>
<select name = 'upload_date' class="form-control">
  %for word,num in [('Any time', "100000"), ('This week', '7'), ('This month', '30'), ('This year', '365')]:
      %if search['upload_date'] == num:
	<option value=${num} selected='selected'>${word}</option>          
       %else:
	<option value=${num}>${word}</option>
       %endif
  %endfor
</select>



%if user:
  <label for="completed" class="control-label">Uncompleted</label>
  %for word, value in [('Yes', "true"), ('No', "false")]:
      %if search['completed'] == value:
	<input type='radio' name='completed' value=${value} selected='selected'>${word}</option>          
       %else:
	<input type ='radio' name='completed' value=${value}>${word}</option>
       %endif
  %endfor

%endif

<label for="order_by" class="control-label">Order by: </label>
<select name = 'order_by' class="form-control">
  %for word, value in [('Newest', "created"), ('Highest quality', 'quality'), ('Easiest', 'easy'), ('Hardest', 'hard'), ('Most viewed', 'views')]:
      %if search['order_by'] == value:
	<option value=${value} selected='selected'>${word}</option>          
       %else:
	<option value=${value}>${word}</option>
       %endif
  %endfor
</select>


<input type="submit" name="submit" class="btn btn-primary" value="Search" />
</form>
<br>
</%def>

${search_content(user, search, action)}

