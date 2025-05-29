# 📱 AgorApp

This repository contains the project developed for the **Design and Implementation of Mobile Applications (DIMA)** course at *Politecnico di Milano* (A.Y. 2023–2024).
The goal of the project is to design and implement a cross-platform mobile application using one of the technologies introduced during the course. For this project, we chose **Flutter**, a framework developed by Google to create cross-platform applications.
Course Instructor: Prof. Luciano Baresi


[![Flutter](https://img.shields.io/badge/flutter-%2302569B.svg?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/firebase-ffca28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Firebase Authentication](https://img.shields.io/badge/Firebase%20Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/products/auth)
[![NewsAPI](https://img.shields.io/badge/NewsAPI-0080FF?style=for-the-badge&logo=news&logoColor=white)](https://newsapi.org/)
[![OpenStreetMap](https://img.shields.io/badge/OpenStreetMap-7EBC6F?style=for-the-badge&logo=openstreetmap&logoColor=white)](https://www.openstreetmap.org/)
[![GraphHopper](https://img.shields.io/badge/GraphHopper-DD3333?style=for-the-badge&logo=graphhopper&logoColor=white)](https://www.graphhopper.com/)





## 📌 Concept

AgorApp is a versatile social application designed to bring together individuals with common interests across different categories. Users can join groups focused on specific topics, facilitating meaningful interactions and exchanges of ideas. Beyond its chat functionalities, AgorApp offers comprehensive event management features and keeps users informed by providing news updates related to their areas of interest.



## 📂 Repository Organization

This repository includes:

    The dima_project folder, containing all the source code for the project.

    The docs folder, which includes the Design Document detailing every phase of the project, along with the project presentation.



## 🚀 Features

    🔐 Login and Registration: Sign in with email or Google SSO.

    📰 Search News: Enter keywords to find news articles.

    👥 Create/Edit Groups: Add group names, descriptions, categories, and images.

    📅 Create/Edit Events: Organize and manage events.

    📤 Share News & Events: Share directly with your groups or followers.

    ➕➖ Follow/Unfollow Users: Stay connected or manage your network.

    👥 Join/Leave Groups: Join communities or leave when needed.

    📬 Subscribe/Unsubscribe Events: Stay updated or opt out.

    💬 Chatting: Group & private messaging supported.

    🖼️ View Content: Display news, events, images in chats.

    🛠️ Message Actions: Delete, copy, view read receipts.

    🔔 Manage Notifications: Enable/disable as you prefer.

    📆 View Calendar: See events you've joined or created.

    🙋 User Profiles: View and update your own profile, or explore other profiles.

    ⚙️ Profile Settings: Manage info or delete your account.

    🗞️ Push News Notifications: Get alerts for preferred topics.

## 🏗️ Architectural Design

AgorApp is developed with Flutter, an open-source framework created by Google that allows for the development of natively compiled, cross-platform applications using a single codebase. The application follows a Model-View-Controller (MVC) design pattern, which provides a clear separation of concerns between different components of the application.

### 🗄️ Data Management

- 🔥 **Cloud Firestore**: A scalable, document-based database designed to store and manage the application's data efficiently.
- ☁️ **Cloud Storage**: Used to store and deliver user-generated images, including profile pictures, event photos, group profile images, and chat images.

### 🔌 External Services

- 🔐 **Firebase Authentication + Google Sign-In**: For user authentication.
- 📩 **Firebase Cloud Function**: For delivering push notifications.
- 📰 **News API**: For accessing curated news stories.
- 🗺️ **OpenStreetMaps API + GraphHopper API**: For map functionality and location information.
- 🔔 **Firebase Cloud Messaging**: For sending push notifications.

## 🖥️ User Interface Design

The user interface of AgorApp is designed to be intuitive and user-friendly. The application adapts to different screen sizes to enhance usability and improve the overall look and feel. Key screens include:

- 🔑 **Login**: The first screen displayed when the application is opened.
- 📰 **News Page**: Features the most recent news and allows users to search for news articles.
- 💬 **Chat Page**: Displays the chat interface, featuring a list of group and private chats.
- 📅 **Calendar Page**: Features a calendar that allows users to view events.
- ➕ **Create Event Page**: Allows users to create events by providing event details.
- 🔍 **Search Page**: Allows users to search for other users, groups, and events.
- 🙍‍♂️ **User Profile Page**: Displays the user profile, including the username, full name, and preferred categories.
- 📍 **Event Page**: Displays the event details, including the name, description, and location.
- 📄 **Detail Page**: Provides detailed information about an event.
- ⚙️ **Setting Page**: Allows users to manage their profile settings.

## ✅ Requirements

The application satisfies the following requirements:

- Support user login and registration.
- Allow registered users to edit their personal information.
- Allow registered users to send messages in both group chats and private chats.
- Send push notifications for chat messages if enabled by the user.
- Allow users to create and delete groups.
- Allow registered users to create and delete events.
- Allow registered users to view a list of joined and created events.
- Allow registered users to follow and unfollow other registered users.
- Send push notifications to registered users for new news items related to their categories of interest.
- Allow users to log out from the application.
- Allow users to permanently delete their accounts.

## 🧪 Testing Campaign

The testing strategy for the application comprises three distinct types:

-  **Unit Testing**: Verifies that individual software components function according to the specific requirements.
-  **Widget Testing**: Focuses on the user interface and interaction of widgets within the application.
-  **Integration Testing**: Ensures that the combined components of the system work together as intended.

## 🔮 Future Developments

Planned improvements for AgorApp include:

- Implement a recommender system to suggest relevant news to users.
- Replace the current Firebase-based backend with a custom solution.
- Expand Android support to leverage Flutter's cross-platform capabilities.
- Integrate bots into group chats to act as moderators.



### 🔐 API Keys


The development of the application required the use of some APIs. The keys used are not present in the repository and they need to be regenerated. The APIs key can be generated from the following links:

-   [https://www.graphhopper.com/](https://www.graphhopper.com/)
-   [https://newsapi.org/](https://newsapi.org/)

The backend of the application is hosted on [Firebase](https://firebase.google.com/). The configuration file is not present in the repository and it needs to be regenerated.


## Authors

| Name               | Email                                                              | GitHub                                                                 |
|--------------------|--------------------------------------------------------------------|------------------------------------------------------------------------|
| Luca Lain          | [luca.lain@mail.polimi.it](mailto:luca.lain@mail.polimi.it)        | [@lucalain](https://github.com/lucalain)                               |
| Sergio Lupo        | [sergio.lupo@mail.polimi.it](mailto:sergio.lupo@mail.polimi.it)    | [@sergiolupo](https://github.com/sergiolupo) |
