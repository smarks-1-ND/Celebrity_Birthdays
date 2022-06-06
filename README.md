# README

This is an app I built for myself and the amusement of my friends. It is live here: https://celeb-bday.herokuapp.com

I have plans to make incremental improvements along the way.
The code could be further DRY'd.
I would like to add some humor while waiting on the API's to load and parse the data.
I would also like to add an age differencial so that it lists how much older or younger a celebrity is from the birthdate entered. 

About the code:
This uses Ruby on Rails, IMDb public API's, Postgresql, Javescript, and Heroku
After inputting an address, the code looks in the database for the information.
If it is there, the data is displayed.
If it is not in the database, it calls the API to get the list of celebrities.
This list is parced and fed to a second API the retrieves the bio information.
This information is parced and written to the database. 
Finally, the site displays the bio info of each celebrity read from the database. 

Please contact me with any comments, suggestions that you might have. 

Thanks. 
