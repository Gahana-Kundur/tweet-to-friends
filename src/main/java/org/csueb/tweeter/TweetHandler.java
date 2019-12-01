package org.csueb.tweeter;

import java.io.IOException;
import java.util.logging.Logger;

import javax.servlet.annotation.WebServlet;
import java.time.Instant;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;

import com.google.appengine.repackaged.com.google.common.base.Throwables;

@WebServlet(
    name = "TweetHandler",
    urlPatterns = {"/tweetHandler"}
)
public class TweetHandler extends HttpServlet{
	
	private static final long serialVersionUID = 1L;
	private static final Logger log = Logger.getLogger(TweetHandler.class.getName());

	@Override
	  public void doPost(HttpServletRequest request, HttpServletResponse response) 
	      throws IOException {
		 String userName = request.getParameter("userName");  
		 String userId = request.getParameter("userId"); 
		 String tweet = request.getParameter("tweetEntry"); 
		 
		 log.info("Obtained userName as " + userName + " and userId as " + userId + 
				 " and tweet as " + tweet);
		 
		 try {
		 long currentTime =	 Instant.now().toEpochMilli();
		 Key entityKey = KeyFactory.createKey("TweetData", userId + "-" + currentTime);	 
	     Entity tweetData = new Entity(entityKey);
	     
		 tweetData.setProperty("userName", userName);
		 tweetData.setProperty("userId", userId);
		 tweetData.setProperty("tweet", tweet);
		 tweetData.setProperty("insertedAt", Long.valueOf(currentTime));
		 
		 DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
		 datastore.put(tweetData);
		 } catch (Exception ex) {
			 log.warning("Encountered error: " + Throwables.getStackTraceAsString(ex));
		 }

	    response.setContentType("text/plain");
	    response.setCharacterEncoding("UTF-8");

	    response.getWriter().print("Saved tweet from " + userName + " \r\n");

	  }
}
