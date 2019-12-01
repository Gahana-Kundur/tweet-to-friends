<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix = "c" uri = "http://java.sun.com/jsp/jstl/core" %>    
<%@ page import="com.google.appengine.api.datastore.DatastoreService"%>
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory"%>
<%@ page import="com.google.appengine.api.datastore.PreparedQuery"%>
<%@ page import="com.google.appengine.api.datastore.Query"%>
<%@ page import="com.google.appengine.api.datastore.Entity"%>
<%@ page import="com.google.appengine.api.datastore.FetchOptions"%>
<%@ page import="org.csueb.tweeter.TweetHandler"%>
<%@ page import="org.csueb.tweeter.TweetDao"%>
<%@ page import="java.util.logging.Logger"%>
<%@ page import="java.util.List"%>
<%@ page import="java.time.Instant"%>
<%@ page import="java.time.ZoneId"%>
<%@ page import="java.time.format.DateTimeFormatter"%>
<%@ page import="java.time.format.FormatStyle"%>
<%@ page import="java.util.Locale"%>
<%@ page import="java.util.ArrayList"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">

<title>Home page</title>
</head>
<body>
	<script>
	  window.fbAsyncInit = function() {
	    FB.init({
	      appId      : '443889113226212',
	      cookie     : true,
	      xfbml      : true,
	      version    : 'v5.0'
	    });
	      
	    FB.AppEvents.logPageView();   
	    
	    FB.getLoginStatus(function(response) {
		    statusChangeCallback(response)
	  	});
	  
	  	FB.Event.subscribe('auth.statusChange', function(response) {
		  console.log("Inside event subscribe")
	      console.log(response)
		})
	      
	  };
	 
	  
	
	  (function(d, s, id){
	     var js, fjs = d.getElementsByTagName(s)[0];
	     if (d.getElementById(id)) {return;}
	     js = d.createElement(s); js.id = id;
	     js.src = "https://connect.facebook.net/en_US/sdk.js";
	     fjs.parentNode.insertBefore(js, fjs);
	   }(document, 'script', 'facebook-jssdk'));
	  
	  function checkLoginState() {
		  FB.getLoginStatus(function(response) {
		    statusChangeCallback(response);
		  }, true);
		}
	  
	  function statusChangeCallback(response) {
		  //documentation of response object is in 
		  //https://developers.facebook.com/docs/reference/javascript/FB.getLoginStatus/
		  console.log("Inside  statusChangeCallback")
		  console.log(response)
		  if (response.status === 'connected') {
		    // The user is logged in and has authenticated your
		    // app, and response.authResponse supplies
		    // the user's ID, a valid access token, a signed
		    // request, and the time the access token 
		    // and signed request each expire.
			var uid = response.authResponse.userID;
			var accessToken = response.authResponse.accessToken;
			
			FB.api('/me', function(response) {
				console.log('Logged in for: ' + response.name)
				document.cookie = "user.id=" + response.id
				document.cookie = "user.name=" + response.name
				console.log('Response is ' + response)
			})
		  } else if (response.status === 'not_authorized'){
			// The user hasn't authorized your application.  They
			// must click the Login button, or you must call FB.login
			// in response to a user gesture, to launch a login dialog. 
		  } else {
			    // The user isn't logged in to Facebook. You can launch a
			    // login dialog with a user gesture, but the user may have
			    // to log in to Facebook before authorizing your application.
	      }
	  }
	</script>
		
		
	<fb:login-button 
	  autologoutlink = "true"
	  scope="public_profile,email, publish_actions, user_friends"
	  onlogin="checkLoginState();">
	</fb:login-button>

     <form name="addTweet" action="/tweetHandler" method="post"> 
           <div class="form-group">
           <input type="hidden" name="userName" value="${cookie['user.name'].value}" />
           <input type="hidden" name="userId" value="${cookie['user.id'].value}" />
           <label for="tweetEntry">Enter a tweet</label><br/>
			
			<textarea id="tweetEntry" name="tweetEntry"
			          rows="3" cols="33" >
			</textarea>
			</div>
           
           <input type="submit" class="btn btn-primary" value="Post a new Tweet">

        </form> 
        
        
        <%
        
        DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
        		   
        Query query = new Query("TweetData").addSort("insertedAt", Query.SortDirection.DESCENDING);
		
		List<Entity> userTweets = datastore.prepare(query).asList(FetchOptions.Builder.withChunkSize(100));
		List<TweetDao> tweetObjs = new ArrayList<>();
		request.setAttribute("tweetObjs", tweetObjs);
		
		DateTimeFormatter formatter = DateTimeFormatter.ofLocalizedDateTime( FormatStyle.FULL )
	                .withLocale( Locale.US )
	                .withZone( ZoneId.of( "America/Los_Angeles" ) );
		
		for (Entity tweet : userTweets) {
			TweetDao dao = new TweetDao();
			dao.setTweetText((String)tweet.getProperty("tweet"));
			Instant tweetedAt = Instant.ofEpochMilli((Long)tweet.getProperty("insertedAt"));
			dao.setTweetTime(formatter.format(tweetedAt));
			tweetObjs.add(dao);
		}
		Logger log = Logger.getLogger(TweetHandler.class.getName());
		log.info("Retreived " + userTweets.size());
        		   
        
        %>
        <div class ="container overflow-auto">
        <p class="font-weight-bold">Your previous tweets:</p>
        <br/>
        <ul class="list-group list-group-flush">
            <li class="list-group-item"><c:out value = "Here"/></li>
	        <c:forEach items="${tweetObjs}" var="tweetObj">
	        	<li class="list-group-item">
		        	<c:out value = "${tweetObj.tweetText}"/>
		        	<br/>
		        	<c:out value = "Tweeted at: ${tweetObj.tweetTime}"/>
	        	</li>
	        	<li class="list-group-item"><c:out value = "Hello"/></li>
	        </c:forEach>
		</ul>
        </div>
       
<script src="https://code.jquery.com/jquery-3.4.1.slim.min.js" integrity="sha384-J6qa4849blE2+poT4WnyKhv5vZF5SrPo0iEjwBvKU7imGFAV0wwj1yYfoRSJoZ+n" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>
</body>
</html>