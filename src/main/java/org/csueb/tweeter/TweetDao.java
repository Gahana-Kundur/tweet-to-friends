package org.csueb.tweeter;

public class TweetDao {
	private String userName;
	private String tweetText;
	private String tweetTime;
	private String userPhotoLink;
	
	public String getUserName() {
		return userName;
	}
	public void setUserName(String userName) {
		this.userName = userName;
	}
	public String getTweetText() {
		return tweetText;
	}
	public void setTweetText(String tweetText) {
		this.tweetText = tweetText;
	}
	public String getTweetTime() {
		return tweetTime;
	}
	public void setTweetTime(String tweetTime) {
		this.tweetTime = tweetTime;
	}
	public String getUserPhotoLink() {
		return userPhotoLink;
	}
	public void setUserPhotoLink(String userPhotoLink) {
		this.userPhotoLink = userPhotoLink;
	}
}
