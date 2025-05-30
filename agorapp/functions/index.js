const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();
const db = admin.firestore();

const categoryToTopicMap = {
  "Environment": "Environment",
  "Cooking": "Cooking",
  "Culture": "Culture",
  "Film & TV Series": "Film",
  "Books": "Books",
  "Gossip": "Gossip",
  "Music": "Music",
  "Politics": "Politics",
  "Health & Wellness": "Health",
  "School & Education": "School",
  "Sports": "Sports",
  "Technology": "Technology",
  "Volunteering": "Volunteering"};

const categories = ["Environment",
  "Cooking",
  "Culture",
  "Film & TV Series",
  "Books",
  "Gossip",
  "Music",
  "Politics",
  "Health & Wellness",
  "School & Education",
  "Sports",
  "Technology",
  "Volunteering"];

const NEWS_API_KEY = "b7481c07197e4c23adb0d826b421fe82";
const NEWS_API_URL1 = "https://newsapi.org/v2/everything?q=";
const NEWS_API_URL2 = `&apiKey=${NEWS_API_KEY}`;

exports.checkCategoryNewsUpdate = functions.pubsub.schedule("every 4 hours").onRun(async (context) => {
  try {
    for (let i = 0; i < categories.length; i++) {
      console.log("Checking for news in category " + categories[i]);

      const response = await axios.get(NEWS_API_URL1+categories[i]+NEWS_API_URL2);

      const latestArticles = response.data.articles.slice(0, 20);

      // Get the last saved articles from Firestore
      const articlesRef = db.collection("news").doc(categories[i]);
      const doc = await articlesRef.get();
      if (doc == undefined || !doc.exists) {
        await articlesRef.set({articles: latestArticles});
      } else {
        const previousArticles = doc.data().articles;
        const isDifferent = !areArticlesEqual(latestArticles, previousArticles);
        if (isDifferent) {
          // If there's a difference, send a notification
          await sendNotification(categories[i]);
          await articlesRef.set({articles: latestArticles});
        }
      }
    }
  } catch (error) {
    console.error("Error fetching news or sending notification:", error);
  }
  return null;
});

/**
 * Compares two lists of articles to check if they are equal.
 * @param {Array} articles1 - The first list of articles.
 * @param {Array} articles2 - The second list of articles.
 * @return {boolean} True if the lists are equal, otherwise false.
 */
function areArticlesEqual(articles1, articles2) {
  if (articles1.length !== articles2.length) {
    return false;
  }
  for (let i = 0; i < articles1.length; i++) {
    if (articles1[i].title !== articles2[i].title) {
      return false;
    }
  }
  return true;
}

/**
 * Sends a notification to the specified topic.
 * @param {string} category - The category of the news.
 * @return {Promise<void>} A promise that resolves when the notification is sent.
 */
async function sendNotification(category) {
  const body = "There are new articles in the " + category + " category.";
  const topic = categoryToTopicMap[category];
  const message = {
    notification: {
      title: "News Update",
      body: body,
    },
    data: {
      type: "news",
      category: category,
    },
    topic: topic,
  };
  console.log("Sending notification for category:" + category);
  // Send a notification to all devices subscribed to the "news" topic
  await admin.messaging().send(message);
}
