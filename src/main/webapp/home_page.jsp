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
 <meta name="viewport" content="width=device-width, initial-scale=1.0">

    
        
<script src="./js/jquery-1.7.2.min.js"></script>
<script src="./js/bootstrap.min.js"></script>
<script src="./js/charcounter.js"></script>
<script src="./js/app.js"></script>   

    <link href="./css/bootstrap.min.css" media="all" type="text/css" rel="stylesheet">
    <link href="./css/bootstrap-responsive.min.css" media="all" type="text/css" rel="stylesheet">
    <link href="./css/font-awesome.css" rel="stylesheet" >
    <link href="./css/nav-fix.css" media="all" type="text/css" rel="stylesheet">
    
    <style>
      .artwork {
        margin-top:30px;
        margin-bottom: 30px;
      }

    </style>

<title>Home page</title>
</head>
<body>
<div id="fb-root"></div>
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
	      statusChangeCallback(response)
		})
	      
	  };
	 
	  
	
	  (function(d, s, id){
	     var js, fjs = d.getElementsByTagName(s)[0];
	     if (d.getElementById(id)) {return;}
	     js = d.createElement(s); js.id = id;
	     js.src = "https://connect.facebook.net/en_US/sdk.js";
	     fjs.parentNode.insertBefore(js, fjs);
	   }(document, 'script', 'facebook-jssdk'));
	  
	  var post = function() {
			var text = document.getElementById('tweet_text').value;
			console.log("value of text is " + text);
			var url = "https://www.facebook.com/dialog/share?app_id=443889113226212&href=https%3A%2F%2Fdevelopers.facebook.com%2Fdocs%2F"
	        url = url + "&quote=" + text;
			window.open(url);
	  }

		// Here we run a very simple test of the Graph API after login is
		// successful. See statusChangeCallback() for when this call is made.
		function share() {
			console.log("Inside share function")
			var tweet_text = document.getElementById('tweetEntry').value;
			var userid = document.getElementById('userId').value;
			var username = document.getElementById('userName').value;
			var picture = document.getElementById('picture').value;
			var msg_tweet = "true";

			var post_data = {
				  tweet_text: tweet_text,
				  userid: userid  , 
				  username: username,
				 picture: picture,
				 msg_tweet : "true"
			};
			console.log('In share + ' + post_data)
			$.post("Tweet", post_data, function(data) {
				console.log(data);
				var key = data;
				var url = window.location.href ;
				if (url.search("localhost")!==-1) {
					url = "https://facebook.com/";
				}
				var share_url = url + "view_tweet.jsp?tweet_key=" + key ;
				var url = "https://www.facebook.com/dialog/send?app_id=443889113226212";
			    url = url + "&link=" + share_url;
			    url = url + "&redirect_uri=https://apps.facebook.com/443889113226212/?fb_source=feed";
			    window.open(url);
			});
	  }		
	  
	  function checkLoginState() {
		  FB.getLoginStatus(function(response) {
			console.log("Inside  checkLoginState")  
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
		    console.log('Fetching info.... ');
			var uid = response.authResponse.userID;
			var accessToken = response.authResponse.accessToken;
			setVarsAPI();
		  } else if (response.status === 'not_authorized'){
			// The user hasn't authorized your application.  They
			// must click the Login button, or you must call FB.login
			// in response to a user gesture, to launch a login dialog. 
			alert('Please login to the app using FB login button')
		  } else {
			    // The user isn't logged in to Facebook. You can launch a
			    // login dialog with a user gesture, but the user may have
			    // to log in to Facebook before authorizing your application.
	      }
	  }
	  var profile_url = "";
	  function setVarsAPI() {

		  FB.api('/me', function(response) {
				console.log('Logged in for: ' + response.name + " having user id: " + response.id)
				console.log('Response is' + response)
				document.cookie = "user.id=" + response.id
				document.cookie = "user.name=" + response.name
				document.cookie = "profile=" + "https://facebook.com/" + response.id;
				document.cookie = "picture=" + "http://graph.facebook.com/" + response.id + "/picture?type=large";
				
				console.log('P1')
				document.getElementById('profile_pic').innerHTML = '<a href="#" class="thumbnail"><img src="http://graph.facebook.com/' + response.id + '/picture?type=large" /></a>';
				console.log('D1')
				document.getElementById('fullname').innerText = response.name;
				console.log('F1')
				document.getElementById('fullname_head').innerText = response.name;
				console.log('W1')
				document.getElementById('whatsup').innerText = 'What\'s happening ' + response.name;
				console.log('P2')
				document.getElementById('profile_link').href = 'https://facebook.com/' + response.id;
				console.log('Pic1')
				document.getElementById('picture').value = 'http://graph.facebook.com/' + response.id + '/picture';
				console.log('U1')
				document.getElementById('userId').value =  response.id;
				console.log('U2')
				document.getElementById('userName').value =  response.name.split(" ")[0];
	        });  
	}		  
	  
	</script>
		


<div id ="status" class="well" style="width:800px; margin:0 auto;">
  <h1 class="lead"><strong></strong> </h1>
  <p>Send tweets to your FB friends :) </p>
		
	<fb:login-button 
	  autologoutlink = "true"
	  scope="public_profile, email,manage_pages,publish_pages,user_friends"
	  onlogin="checkLoginState();">
	</fb:login-button>
	</div>
	
	<% Cookie[] cookies = request.getCookies();
		String userId="", userName="",picture="";
		if (cookies != null) {
			for (int i = 0; i < cookies.length; i++) {
				Cookie cookie = cookies[i];
				if (cookie.getName().equals("user.id")) {
					userId = cookie.getValue();
				}

				if (cookie.getName().equals("user.name")) {
					userName = cookie.getValue();
				}

				if (cookie.getName().equals("picture")) {
					picture = cookie.getValue();
				}
			}
		}
		
		%>
		
    
     <div class="navbar navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container-fluid">
          <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </a>
          <a class="brand" href="#">FB Tweeter </a>
          <div class="btn-group pull-right" id="welcome">
           Welcome, <strong><a id="fullname"> </a> </strong> 
                <fb:login-button size="large" autologoutlink="true" scope="public_profile,email,manage_pages,publish_pages,user_friends" onlogin="checkLoginState();">
				</fb:login-button>                      
           </div>
          <div class="nav-collapse">
            <ul class="nav">
              <li class="active"><a href="#">Home</a></li>
              <li><a id="profile_link" target="_blank" href="#">Profile</a> </li>
              <li><a id="friends_tweet" href="./friends.jsp">Friends Tweet</a> </li>
              <li><a id="friends_top_tweets" href="./friends_top_tweets.jsp">Top Tweets of Friends</a> </li>
            </ul>
          </div><!--/.nav-collapse -->
        </div>
      </div>
    </div>
    
    <div class="container">
      <div class="row">
        <div class="span8 offset2">
     <div class="row artwork hidden-phone" style="font-size:80px; text-align: center;">
		<div class="span2"><i class="icon-group"></i></div>
		<div class="span2"><i class="icon-comments-alt"></i></div>
		<div class="span2"><i class="icon-globe"></i></div>
		<div class="span2"><i class="icon-thumbs-up"></i></div>
	</div>
	</div>
	</div>
	</div>
     
     <div id="main_tweet_db" class="container">
     	<div class="row">
		   <div class="span4 offset4">
		    <p id="whatsup" class="lead"> </p>
		    <div class="row">
		      <div class="span4 well">
			     <form name="addTweet" action="/tweetHandler" method="post"> 
			           <div class="form-group">
			           <input type="hidden" name="userName" id="userName" value="${cookie['user.name'].value}" />
			           <input type="hidden" name="userId" id="userId" value="${cookie['user.id'].value}" />
			           <input type="hidden" name="picture" id="picture" value=""/>     
			           <label for="tweetEntry" class="font-weight-bold">Enter a tweet</label><br/>
						
						<textarea id="tweetEntry" name="tweetEntry"
						          rows="3" cols="33" >
						</textarea>
						</div>
			           
			           <input type="submit" class="btn btn-primary" value="Post a new Tweet">
			           <input type="button" name="share_btn" value="Share with friends" class="btn btn-primary" onclick="share()"/>
			
			        </form>
			</div>
		</div> 
		
	  <div class="row">
      <div class="span4 well">
        <div class="row">
          <div id="profile_pic" class="span1"><a href="#" class="thumbnail"><img src="./img/user.jpg" alt=""></a></div>
          <div class="span3">
            <h3><a id="fullname_head"> </a></h3>
            <span id="num_tweets" class=" badge badge-warning">0 tweets</span> <span class=" badge badge-info">0 followers</span>          
           </div>
        </div>
      </div>
    </div>

    <div class="container">
    	<div class="row">
   			<div class="span4 well" style="overflow-y: scroll; height:101%;">
      			  <p class="lead"> Previously Tweeted:</p>
            		  <hr />
	         
        
        <%
        
        DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
	    Logger log = Logger.getLogger(TweetHandler.class.getName());
	        		   
	    log.info("Filtering for user Id:  " + userId);			        		   
        		   
        Query query = new Query("TweetData").addSort("insertedAt", Query.SortDirection.DESCENDING);
	    //query.addFilter("userId", Query.FilterOperator.EQUAL, userId);
		
		List<Entity> userTweets = datastore.prepare(query).asList(FetchOptions.Builder.withChunkSize(100));
		log.info("Retreived " + userTweets.size());
		int num_tweets = userTweets.size();
		
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
        %>
        <hr />
         </div>
    </div>
    </div>
        
        
        <script type="text/javascript"> document.getElementById("num_tweets").innerText = "<%=num_tweets%> tweets";</script>
        <br/>
        
        <div class ="container overflow-auto">
	        <div class="card" style="width: 18rem;">
		        <div class="card-header">
				    Your previous tweets
				</div>
		        <ul class="list-group list-group-flush">
			        <c:forEach items="${tweetObjs}" var="tweetObj">
			        	<li class="list-group-item">
				        	<c:out value = "${tweetObj.tweetText}"/>
				        	<br/><br/>
				        	<p class="text-secondary">
				        		<c:out value = "Tweeted at: ${tweetObj.tweetTime}"/>
				        	</p>
				        	
			        	</li>
			        </c:forEach>
				</ul>
			</div>	
        </div>     
</body>
</html>