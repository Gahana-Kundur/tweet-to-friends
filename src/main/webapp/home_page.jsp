<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix = "c" uri = "http://java.sun.com/jsp/jstl/core" %>    

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
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
           <input type="hidden" name="userName" value="${cookie['user.name'].value}" />
           <input type="hidden" name="userId" value="${cookie['user.id'].value}" />
           <label for="tweetEntry">Enter a tweet</label><br/>
			
			<textarea id="tweetEntry" name="tweetEntry"
			          rows="3" cols="33" >
			</textarea>
           
           <input type="submit" value="Publish Tweet">

        </form> 
       

</body>
</html>