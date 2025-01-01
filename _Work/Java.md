---
layout: post
title:  "8. Java"
category: tech
permalink: /tech/work/java
order: 8
---
# Autowire Injection
As the sample JWT token caching implementation included in Authentication part, since we want the fechTokenManager attribute in email controller to be singleton, which means that throughout the running of application, here will only be one fetchokenManager instance, then we will use autowire injection to ensure that, therefore the cachedToken will keep he same throughout the lifecycle of application.

# ReentrantLock
To ensure the JWT token is fectched in single thread, we need to lock to ensure that.
Please read [doc](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/concurrent/locks/ReentrantLock.html#tryLock()) to understand how Reentrentlock works.

Barging behavior means that mutiple threads try to acquire a lock, with some threads "barging" ahead of others. This can lead to unfairness, since some thread will always ge the lock in advance.

Using tryLock(0, TimeUnit.SECONDS) on a ReentrantLock in Java is a way to respect the fairness setting while attempting to acquire the lock immediately without waiting. 

1. Fairness: A fair ReentrantLock grants access to threads in the order they requested it, which means threads wait in a queue. An unfair lock does not guarantee any particular order, allowing threads to "jump" the queue if they can acquire the lock right away.

2. tryLock with 0 Timeout: When you call tryLock(0, TimeUnit.SECONDS), the method will attempt to acquire the lock without waiting:

    * If the lock is available, it acquires it immediately and returns true.
    * If the lock is unavailable, it fails immediately (returns false) instead of waiting for it to become available.
    * Interruptibility: Unlike tryLock() with no arguments, tryLock(0, TimeUnit.SECONDS) is interruptible. This means that if the current thread is interrupted while trying to acquire the lock, it will throw an InterruptedException rather than ignoring the interruption. This can be useful when you want to handle interrupted threads promptly.

3. Honor Fairness: In fair mode, tryLock(0, TimeUnit.SECONDS) respects the fairness setting by ensuring that if multiple threads are competing for the lock, they’ll acquire it in the order they called tryLock(). This is especially relevant in multi-threaded scenarios where predictable access is important.
