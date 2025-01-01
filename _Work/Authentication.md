---
layout: post
title:  "7. Authentication"
category: tech
permalink: /tech/work/auth
order: 7
---
# JWT Token
A user sends his login credential(e.g. username and password) to authenication server(backend API), the server auhenticates user by verifying credentials. Once success, generates a JWT token containing header, payload(expiration time...metadata), token string. Client stores the token in differen ways, when make requests to the server, it includes JWT in the Authorization header of HTTP request as `Authorization: Bearer <JWT>`

The client can refresh the token when previous token comes to the end.

## Sample Implementation(Java Spring boot)
Assuming I would like to send email by application, and I need to use caching JWT token to ensure safety and reduce latency.
1. Token.java
    ```
    String accessToken;
    String ExpiresIn;
    ...
    getters and setters
    ```
2. FetchTokenManager.java
    ```
    @Component
    Token cachedToken;
    ReentranLock lock = new ReentrantLock();
    class{
        getToken - call API to get token response back, assigned to cachedToken

        fetchToken(){
            if(cachedToken  == null || cachedToken almost expires){
                lock.lock();
                try{
                    if(cachedToken  == null || cachedToken almost expires){
                        getToken();
                        return cachedToken.getToken();
                    }
                }finally{
                    lock.unlock()
                }
            }
            return cachedToken.getToken();
        }
    }
    ```
3. EmailController.java
    ```
    @Conroller
    FetchTokenManager fetchTokenManager;
    public(@Autowired FetchTokenManager fetchTokenManager){
        this.fetchTokenManager = fetchTokenManager;
    }

    sendEmail(...){
        String tokenInfo = fetchTokenManager.fetchToken();
        ...
    }
    ```