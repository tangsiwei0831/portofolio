---
layout: post
title:  "8. Java"
category: tech
permalink: /tech/work/java
order: 8
---
# Autowire Injection
As the sample JWT token caching implementation included in Authentication part, since we want the fechTokenManager attribute in email controller to be singleton, which means that throughout the running of application, here will only be one fetchokenManager instance, then we will use autowire injection to ensure that, therefore the cachedToken will keep he same throughout the lifecycle of application.

# Lock


