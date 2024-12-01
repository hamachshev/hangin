# README

To start the application run
`rails s`
and then `bin/rails` and then `ngrok start hangin` (if you want to use ngrok, but you must add config in ngrok config and change `ENV[base-domain]`-- todo)

Base url = `base_url`
# API

## Request OTP
* **POST** to `base_url/create?number=` with the number to send the OTP code to
* Receive 204 no content if successful


## Confirm OTP
* **POST** to `base_url/oauth/token`
	* Content-Type header is equal to application/json	
	* Body of request is: 
	
```json
{  
    "client_id":"insert_client_id",    
    "client_secret": "insert_client_secret",
    "grant_type": "password",
    "number": "insert_number",
    "code": "insert_code"
}
```

* Success - 200 OK - receive below: (**make sure to save the access token and the refresh token and the uuid of the user**)

```json
{
    "access_token": "Uf4_O36vvM5e0GVFnEgLl_gSfVM5SXrpi_t1cUcOwy8",
    "token_type": "Bearer",
    "expires_in": 7200,
    "refresh_token": "23nkgxeBgSM7uBYzNXnxZse2qpvot4yadWvJq3iadYo",
    "created_at": 1732748324,
    "uuid": "91e7744b-35f5-4384-849a-2aa0e26301ee"
}
```

**The access token will expire after 7200 seconds, ie 2 hrs.** 

* After the token expires, if you try to verify the user with the expired access token, you will receive:

```json
{
	"type":"disconnect",
	"reason":"unauthorized",
	"reconnect":false
}
```
You will then need to request a new token using the refresh token.

## Getting a New Access Token Using The Refresh Token 

* **POST** to `base_url/oauth/token`
	* Content-Type header is equal to application/json	
	* Body of request is: 
	
```json
{  
    "client_id":"insert_client_id",    
    "client_secret": "insert_client_secret",
    "grant_type": "refresh_token",
    "refresh_token": "insert_refresh_token"
}
```

* Success - 200 OK - receive below: (**make sure to save the access token and the *new* refresh token and the uuid of the user**)

```json
{
    "access_token": "3n9620J3ilpOeysz75s8wuE-TKCIgVd6l3t6ozOTnxI",
    "token_type": "Bearer",
    "expires_in": 7199,
    "refresh_token": "bjqfaU5lpzWJI3nFdAqdG4JjgS43OzMSTwmlpf2yAAM",
    "created_at": 1732891510
}
```
## Send Friends

* **POST** to `base_url/friends`
	* Content-Type header is equal to application/json
	* Authorization header is set to `Bearer insert_access_token_here`
	* Body of request:

```json
{
	"friends": [
		{
			"first_name": "George",
			"last_name": "Washington",
			"number": "8009998888"
		}
	]
}

```

* Friend objects must include all fields and number must be 10 digit US number
* Response (Successful) **201 Created**


```json
[
    {
        "id": 29,
        "first_name": "George",
        "last_name": "Washington",
        "number": "8009998888",
        "user_id": 1,
        "created_at": "2024-11-27T23:24:50.993Z",
        "updated_at": "2024-11-27T23:24:50.993Z"
    }
]
```
* This is an array of all the friends created

## Get Contacts and Friends for Invite to chat
* Friend = contact that is not on hangin and Contact = friend that has a hangin account

* **GET** to `base_url/friends`
* Authorization header is set to `Bearer insert_access_token_here`
* Sucessful response

```json
{
	"friends":[
		{
			"first_name": "george",
			"last_name": "washington",
			"number": "9883338899"
		}
	],
	"contacts": [
					{
					            "uuid": "flkjajklfdsafsdjkl898u",
					            "first_name": "George",
					            "last_name": "Washington",
					            "number": "8997777777",
					            "profile_pic":"https://www.afjklds.com/profilepic.jpeg"
					}
	
	]
}
```

## Invite contacts to a chat


* **POST** to `base_url/notifications/invite`
* Content-Type header is equal to application/json
* Authorization header is set to `Bearer insert_access_token_here`
* Body of request:

```json
{
	"chat_id": "insert_chat_id_here",
	"users_to_invite" [
		"user_uuid_one0945809853409834059",
		"user_uuid_two9084238095234"
	]
	
}
```

* Sucessful response -- is a 204 response with with no body

## Connect to the websocket

* URL is `wss://base_url/cable`
* Either use the Authorization header and set it to `Bearer insert_access_token_here` like before or send it in with query params like `wss://base_url/cable?access_token=` and supply access token
* Response: Your client should be able to tell that you are connected but if not, you should recieve a response like 

```json
{
    "type": "welcome"
}
```

## Subscribe to get chats (Ongoing chats)
* The command must be typed **exactly** like this: (Yes including the weird slashes)


```json
{
	 "command":"subscribe",
	 "identifier":"{\\"channel\\":\\"ChatsChannel\\"}"
}
```
* This should be in a triple quoted string (ie the " does not need to be escaped, only the / do. If not, you need to escape the " and the slashes so the command would need to look like: (I think)

```json
{
	 \"command\":\"subscribe\",
	 \"identifier\":"{\\\"channel\\\":\\\"ChatsChannel\\\"}"
}
```
* ie the message that the server sees needs to be like this: 
 
```json
{
	 "command":"subscribe",
	 "identifier":"{\"channel\":\"ChatsChannel\"}"
}
```

* Response: **ProfilePic may be null (ie blank)**

```json
 {
	"identifier": "{\"channel\":\"ChatsChannel\"}",
   	"message": {
    		"chats": [
    			{ 
    				"id": 123,
    		  		"name": "BEST CHAT EVER!",
    		  		"users": [
    		  			{
	    		  			"uuid": "flkjajklfdsafsdjkl898u",
	    		  			"first_name": "George",
	    		  			"last_name": "Washington",
	    		  			"number": "8997777777",
	    		  			"profile_pic":"https://www.afjklds.com/profilepic.jpeg"
    		  			}
    		  		]
    			}
    		]
    }
}

```

## Types of websocket messages

### Chat messages (ie messages about chats -- new, update, delete etc)
### Own Chat Message
* This is the message you receive after you send a message to create a chat 


```json
{
	"message" : {
		"own_chat": {
			"id": 6,
			"name": "The best chat in the world!",
			"users": [
							{
		                        "uuid": "flkjajklfdsafsdjkl898u",
		                        "first_name": "George",
		                        "last_name": "Washington",
		                        "number": "8997777777",
		                        "profile_pic":"https://www.afjklds.com/profilepic.jpeg"
	                        }
	                    ]
	                 }
	}
}
```

### New Chat Message
* This is the message you receive after someone else (your contact) creates a chat 


```json
{
	"message" : {
		"chat": {
			"id": 6,
			"name": "The best chat in the world!",
			"users": [
							{
		                        "uuid": "flkjajklfdsafsdjkl898u",
		                        "first_name": "George",
		                        "last_name": "Washington",
		                        "number": "8997777777",
		                        "profile_pic":"https://www.afjklds.com/profilepic.jpeg"
	                        }
	                    ]
	                 }
	}
}
```

### Delete Chat Message
* This is the message you receive after someone else deletes a chat, ie the chat has no more users in it, and you had it on your screen because one of your contacts was in it 


```json
{
	"message" : {
		"delete_chat": 4
	}
}
```

### Update Chat Message
* This is the message you receive when the server wants to update a chat on the front end. This happens when new users join a chat or users leave a chat (I think)

```json
{
	"message" : {
		"update_chat": {
			"id": 6,
			"name": "The best chat in the world!",
			"users": [
							{
		                        "uuid": "flkjajklfdsafsdjkl898u",
		                        "first_name": "George",
		                        "last_name": "Washington",
		                        "number": "8997777777",
		                        "profile_pic":"https://www.afjklds.com/profilepic.jpeg"
	                        }
	                    ]
	                 }
	}
	}
}
```
### Messages messages (ie messages from the server about messages that the user sent)

### Message

* This represents a message sent by another user (or yourself) that the server updates you about

```json
{
	"identifier":"{\"channel\":\"ChatChannel\", \"id\":\"271\"}",
	"message": {
		"message": {
				"user_uuid":"91e7744b-35f5-4384-849a-2aa0e26301ee",
				"kind":"text",
				"first_name":"Aharon",
				"last_name":"Seidman",
				"body":"Hello again"
				}
			}
}

```

### Message Array

* On first connect to chat, you will recive an array with all of the messages in the chat, in chronological order: ie oldest first, newest last

```json
{
	"identifier":"{\"channel\":\"ChatChannel\", \"id\":\"301\"}",
	"message":{ 
		"messages": [
						{
							"user_uuid":"91e7744b-35f5-4384-849a-2aa0e26301ee",
							"kind":"text",
							"first_name":"Aharon",
							"last_name":"Seidman",
							"body":"Hey"
							}
						]
					}
}
```

### Contacts Messages (ie updates on the online status of contacts)

### Contact online message

* Message when contact goes online

```json
{
	"message": {
		"contact_online": {
		                        "uuid": "flkjajklfdsafsdjkl898u",
		                        "first_name": "George",
		                        "last_name": "Washington",
		                        "number": "8997777777",
		                        "profile_pic":"https://www.afjklds.com/profilepic.jpeg"
	                        }	
	              }
}

```
**As an aside, anytime we send a contact it is in the same format as above, so you can create one class for it**
### Contacts online message

* Message when multiple contacts go online (this message is only when you first connect to the chats channel (I think)

```json
{
	"message": {
		"contacts_online": [
								{
			                        "uuid": "flkjajklfdsafsdjkl898u",
			                        "first_name": "George",
			                        "last_name": "Washington",
			                        "number": "8997777777",
			                        "profile_pic":"https://www.afjklds.com/profilepic.jpeg"
		                        }	
		                   ]
	              }
}

```

### Contacts offline message

* Uuid of contact that has gone offline

```json
{
	"message": {
		"contact_offline": "contact_uuid_kjnjkafdsjkhdfshfku88"
	              }
}
```
## Types of messages you can send to the websocket

**Once again, the triple quoted rule applys see above in *Subscribe to Get Chats* above for full rules.**

## Create Chat message
* Fill in name where specified

```json

"""
                      {
                        "command":"message",
                        "identifier":"{\\"channel\\":\\"ChatsChannel\\"}",
                        "data":"{\\"action\\":\\"createChat\\",\\"name\\":\\"fill_in_name_here\\"}"
                      }
""" 
```

## Subscribe to Chat (ie when user clicks on it and wants to see messages)
* Fill in id *as an int* where specified (you should have this in the list of chats when you subbed to the chats chanel

```json
"""
            {
                "command":"subscribe",
                "identifier":"{\\"channel\\":\\"ChatChannel\\", \\"id\\":\\"fill_in_id_here\\"}"
              }
"""
```

## Unsubscribe to Chat (ie when user goes back to main list of chats)
* Fill in id *as an int* where specified

```json
"""
            {
                "command":"unsubscribe",
                "identifier":"{\\"channel\\":\\"ChatChannel\\", \\"id\\":\\"fill_in_id_here\\"}"
              }
"""
```

## Go to background 
*  Use this command right before the app goes to the background (ie closes, the device turns off, the app is still running but the user has switched to another app)to subscribe to push notifcations for 5 minutes

```json
 """
      {
        "command":"message",
        "identifier":"{\\"channel\\":\\"ChatsChannel\\"}",
        "data":"{\\"action\\":\\"go_to_background\\"}"
      }
"""
```

## Send message to chat (ie send text message)
*  when user wants to send a message in a group
*  Make sure to fill in the message (that the user wants to send) and the id of the chat

```json
"""
{
    "command":"message",
    "identifier":"{\\"channel\\":\\"ChatChannel\\", \\"id\\":\\"fill_in_id_here\\"}",
    "data":"{\\"action\\":\\"speak\\",\\"body\\":\\"fill_in_message_here\\", \\"kind\\":\\"text\\", \\"status\\":\\"sent\\"}"
  }
"""
```
