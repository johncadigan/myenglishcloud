## base.mako
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>${next.page_title()}|My English Cloud</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="My English Cloud is one site for all your English learning needs. We have free English lessons, English quizzes, and English flashcards to help you learn English.">
    <meta name="author" content="">

    <!-- Le styles -->

   <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
   
   <link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
    <link href="${request.static_url('english:/static/css/master.css')}" media="screen" rel="stylesheet" type="text/css">
     ${next.styleSheetIncludes()} 

    <style type="text/css">
      body {
        padding-top: 60px;
        padding-bottom: 40px;
	background:#F8F8F8;
      }
     ${next.styleSheet()}
    </style>

    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
    <script src="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
    ${next.javascriptIncludes()} 
  
     <script type="text/javascript">
	$('.dropdown-toggle').dropdown();
      </script>
      <script type="text/javascript">
	$(document).ready(function (){

              ${next.documentReady()} 
            
          });
      </script>
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-45525143-1', 'myenglishcloud.com');
  ga('send', 'pageview');

</script>

</head>
    <body>
          ${next.body()}
   </body>


  </html>
