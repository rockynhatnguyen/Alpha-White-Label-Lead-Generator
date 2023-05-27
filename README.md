# TLG1: Serverless APIs for White Label Lead Generator App.
## Solution Description: Alpha White Label Lead Generator
### Industry: Fin-Tech

This is **Part-1** of *Through the Looking Glass*, that contains working and deployable code and final software package for APIs built and deployed using modern serverless paradigm on GCP.

### Tech Stack
The Alpha White Label Lead Generation APIs utilizes the following technologies and frameworks:
- GCP API Gateway: A Fully managed gateway for serverless workloads offered by GCP. Visit https://cloud.google.com/api-gateway to learn more.
- GCP Cloud Functions: Helps run code as FaaS in a serverless environment. Visit https://cloud.google.com/functions to learn more.
- GitHub: A web-based platform for version control and collaboration that allows developers to host and review code, manage projects, and build software alongside millions of other developers.

### Requirement Specifications:
- [ ] User Info API (POST): 
  - URL: https://{fqdn}/user/
  - METHOD: POST
  - BODY: *User Info:* User Provides Following Information
    - First name... (Input) **Mandatory
    - Last name... (Input) **Mandatory
    - Email... (Input) **Mandatory
    - Country Code... (Valid Country Code)
    - Mobile Number... (Input)
    - Twitter handle... (Input) **Mandatory if Opt-in is true.
    - Discord handle... (Input) **Mandatory if Opt-in is true.
    - Checkbox 
    - [ ] Opt in for updates. 
    *Note: If yes, Twitter and Discord are mandatory.*
    *Use any secure and reliable third party api to get valid country codes*
    The sample payload in the body is as follows:
    ```
    {
      "firstName": "Manish",
      "lastName": "Andankar",
      "email": "user@domain.com"
      "countryCode": "+1",
      "countryName":"United States",
      "mobileNumber":"+1XXXXXXXXXXXX",
      "twitterHandle":"@twitter_handle",
      "discordHandle":"DiscordName#XXXX",
      "optIn":true,
      "solAddress":"xxxxxxxxxxxxxxxxxxxxxxxxx"
    }
    ```
    SUCCESSFUL RESPONSE: HTTP 200 - OK
    ```
    {
      "message": "success",
      "id": "a6b947cc-fc90-11ed-be56-0242ac120002",
    }
    ```
    The userid is a universally unique identifier: Visit https://www.uuidgenerator.net/ to learn more about uuid.
    
- [ ] User Info API (GET): 
  - URL: https://{fqdn}/user/{id}
  - PARAMETER:
    - id (uuid)   
  - METHOD: GET
  - SUCCESSFUL RESPONSE: HTTP 200 - OK
  ```
    {
      "id":"a6b947cc-fc90-11ed-be56-0242ac120002",
      "firstName": "Manish",
      "lastName": "Andankar",
      "email": "user@domain.com"
      "countryCode": "+1",
      "countryName":"United States",
      "mobileNumber":"+1XXXXXXXXXXXX",
      "twitterHandle":"@twitter_handle",
      "discordHandle":"DiscordName#XXXX",
      "optIn":true,
      "solAddress":"xxxxxxxxxxxxxxxxxxxxxxxxx"
    }
    ```

- [ ] Offer API (GET) - For Countdown Timer in [THJ](https://github.com/manish-andankar/Alpha-White-Label-Lead-Generator/blob/THJ/README.md): 
  - URL: https://{fqdn}/offer/{id}
  - METHOD: GET,
  - SUCCESSFUL RESPONSE: *Offer Info:* Information about the offer and when its going to end.
    - Offer End Date Time
    - Until {Offer Message}. A relevant message for the given offer {id} 
  - The sample response in the body is as follows:
    ```
    {
      "offerEndDateTime": "2012-07-09T19:22:09.1440844Z",
      "offerMessage": "Until {Offer Message}",
    }
    ```

### Solution Constraints:
  - Deployable on GCP Serverless Environment.
  - Performance: Response time, Load Time, Resource Utilization, No Errors or Warnings.
  - Passes all test cases in the test suite.
  - Passes all the automated integration tests.
  - Secured apis to protect from malacious attacks.

### Tools to use/avoid
  - Use: GCP Serverless Platform ONLY.
  - use: Best practices and Recommendations from GCP Serverless.

### Test Cases
- [ ] User Info API (POST): 
- METHOD: POST
  | Test No | Test Name | Test Description | Test Data |  Test Steps | Expected Results |
  | ----------- | ----------- |----------- | ----------- | ----------- | ----------- |
  | 1 | Capture New User Info | New lead generated by posting new user information | Use sample data | Post the UserInfo payload on https://{fqdn}/user  | User Info is posted successfully. A random user id is returned |
  | 2 | Validations | Validate all fields | User Info | Post the UserInfo payload on https://{fqdn}/user  | The user input is validated as per the requirements, and relevant error messages are returned with HTTP response as BAD_REQUEST (400). |
  | 3 | Opt-In | Twitter and Discord Mandatory for Opt-In | User Info with any or both Twitter and Discord handles as empty, and optIn as true | Post the UserInfo payload on https://{fqdn}/user | BAD_REQUEST (400) with a message suggesting that both the social handles are required. |

- [ ] User Info API (GET): 
- METHOD: GET
  | Test No | Test Name | Test Description | Test Data |  Test Steps | Expected Results |
  | ----------- | ----------- |----------- | ----------- | ----------- | ----------- |
  | 1 | Ger User Info | Get the User Info by unique id of the user | id="a6b947cc-fc90-11ed-be56-0242ac120002" | Open https://{fqdn}/user/{id} on the browser | User Info retrieved successfully. |
  | 2 | Validations | Validate user exists | id="random_value_that_other_than_a6b947cc-fc90-11ed-be56-0242ac120002" | Open https://{fqdn}/user/{id} on the browser | Error message "User not found" is returned in the response body with HTTP response as BAD_REQUEST (400). |

- [ ] Offer API (GET): 
- METHOD: GET
  | Test No | Test Name | Test Description | Test Data |  Test Steps | Expected Results |
  | ----------- | ----------- |----------- | ----------- | ----------- | ----------- |
  | 1 | Ger Offer Info | Get the Offer Info by unique offer id | id="b695ff8a-fc92-11ed-be56-0242ac120002" | Open https://{fqdn}/offer/{id} on the browser | Offer Info retrieved successfully. |
  | 2 | Validations | Validate offer exists | id="random_value_that_other_than_b695ff8a-fc92-11ed-be56-0242ac120002" | Open https://{fqdn}/offer/{id} on the browser | Error message "Offer not found" is returned in the response body with HTTP response as BAD_REQUEST (400). |

### Deliverables
  - Completed Code checked in to the repository with a *unique folder name* that indicates your contribution. It is the *parent* folder for all deliverables.
  - APIs deployed on GCP and api links https://{fqdn}/user/ and https://{fqdn}/offer/ shared in a text file checked in with the name *api_references* under the folder *deliverables* within the *unique folder*.
  - Deployment instructions for with supporting materials and assets in the *deployment guide* folder.
  - Documentation & Video Demo under the folder *documentation* within your *unique folder*. 
