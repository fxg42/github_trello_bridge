A script that synchronizes github issues to a trello board.

## Setting up

### github

Setting up the github access is requires that the `GITHUB_USERNAME` and
`GITHUB_PASSWORD` environment variables be setup.

### trello

Setting up the trello access is a little more involved.

1. **Get your API key.** Log in to trello and go to the following URL:
   [https://trello.com/1/appKey/generate](https://trello.com/1/appKey/generate)
   Set the value of the `TRELLO_API_KEY` environment variable with the value of
   the "Key" field found at the top of the page.
1. **Get your access token.** We need to generate an everlasting access token
   with write privileges. Insert your API key in the following link as well as
   your application name (any name will do):
   [https://trello.com/1/authorize?key=YOUR_API_KEY&scope=read%2Cwrite&name=SOME_NAME&expiration=never&response_type=token](https://trello.com/1/authorize?key=YOUR_API_KEY&scope=read%2Cwrite&name=SOME_NAME&expiration=never&response_type=token) 
   Set the value of the `TRELLO_WRITE_ACCESS_TOKEN` with the value found on the
   resulting page.

### Finding the board and list ids

Run the following command to print all your trello boards and lists with their
ids:

    $ coffee board_lists.coffee -u YOUR_TRELLO_USERNAME

Finally, you need to find what the trello board id is as well as the list id
where new cards will be created.

## Running the command

    $ coffee index.coffee -b TRELLO_BOARD_ID -l TRELLO_LIST_ID -o GITHUB_REPO_OWNER_USERNAME -r GITHUB_REPO_NAME
