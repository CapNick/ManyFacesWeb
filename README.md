# ManyFaces Admin Website

This web application can be used to update the content and layout of the ManyFaces digital staff board.

### Setup

**Install Rails**

To start the web server, Rails must be installed. All of the necessary steps for installing Rails are listed in section 3.1 of [this page](http://guides.rubyonrails.org/getting_started.html).

**Install libraries**

Once Rails has been installed, navigate into the application's file directory using a terminal, e.g.

    $ cd C://.../ManyFacesWeb
    
Then run the following command to install all of the libraries that the application depends on:

    $ bundle install
    
**Create the database**

To create the database, run the following commands from inside the application's file directory:

    $ rails db:migrate
    $ rails db:seed
    
Note that this only has to be done **once**, before the web server is launched for the first time.
    
**Launch the web server**

To launch the web server, run the following command from inside the application's file directory:

    $ rails server
    
The web application can then be accessed at [localhost:3000](http://localhost:3000) using a web browser. The application has been tested for compatibility with Google Chrome, Mozilla Firefox and Microsoft Edge.
    
To shut down the web server, press CTRL+C inside the same terminal window.    
    
### FAQ
    
**How do I add a user account?**    

All database updates that cannot be performed using the web application will require use of the Rails console.

To open the Rails console, navigate into the application's file directory using a terminal, then run the command:

    $ rails console
    
From the console, run the following command to create new login credentials:
    
    $ User.create!(email: 'new_email_here', password: 'new_password_here')    
    
Note that passwords must be at least 6 characters long.

To close the Rails console, run the ``quit`` command.

**How do I change my password?**

To change your password, first open the Rails console (see previous question), then run the following commands:

    $ temp = User.where(email: 'your_email_here').first
    $ temp.password = 'new_password_here'
    $ temp.save
    
These commands will create a reference to your user record, update the password, and apply the change.

**How do I add more grid dimensions to the 'Reorder Faces' screen?**

To add a new set of dimensions, first open the Rails console (see first question), then run the following commands:

    $ Layout.create!(width: 'new_width_here', height: 'new_height_here', selected: 'false')     
    
This set of dimensions can then be selected from the 'Reorder Faces' screen.    