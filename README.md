# Transit Feeds

This app does not use storyboards.

One main view controller that shows a map with pins corresponding to each feed from the "https://api.transitapp.com/v3/feeds?detailed=1" (unfortunately this is hard coded at the moment).

Tests are extremely limited - just validating decoding of the json data into Swift data models.