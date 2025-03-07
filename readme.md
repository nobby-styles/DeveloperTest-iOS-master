# Atomic Media iOS Developer Test

## Instructions for candidates

Your task is to create a simple news reader application. The app will contain two screens. The first
will be a list of news article headlines, tapping on one of those headlines will open up the full
news story.

The project provides you with a mock API layer (find this in the `API` package). This API layer
contains two methods, `getHeadlines` which will return a list of news headlines,
and `getStory` which takes an ID for a news headline, and returns the full article.  Each of these
has 3 implementations - one using async/await, one using completion callbacks, and one using 
Combine.  Use your preferred implementation.

You may use whatever external resources or websites you like to help you, and feel free to import
3rd party libraries where appropriate. You can also create, modify or delete any
classes and files within the project that you want to. You're not restricted to only working within
the given files - they should only be used as a guide/quick start point. The only restriction here is
please do not modify the files within the `API` package. Feel free to take a look at how they work
though!

We're looking for a concise and readable solution, so please spend no more than 1 hour on this test. 
We are not expecting you to finish every task, but please be prepared to discuss how you would 
approach any non-complete tasks on a follow up call. 

When you have finished, please ZIP up the project folder and either email it back to us, or upload
it somewhere for us to download.

Your tasks are as follows, we recommend you read them all in full before you start the first task.
Good luck!

# Task 1

Implement the Headlines View. This screen should display a scrollable list of headlines to the
user. Each item should contain the headline title, and the author's name. The headlines should be
populated from the API as the view appears.

The view should also have a loading state, and an error state.

It is up to you to define the path the data takes on it's way to the UI. The UI design of the app is
not important, as long as the content is readable regardless of screen size and orientation.

# Task 2

Implement the Stories View. The stories screen should show the title, author, content, and the 
published-at date.

Again, this view should have a loading state and an error state.

# Task 3

Implement an in-memory cache to show the last fetched results when the API call fails. Both headlines and stories should be
stored in the cache.
